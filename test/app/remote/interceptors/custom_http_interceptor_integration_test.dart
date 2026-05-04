import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/commons/services/token_refresher.dart';
import 'package:oremusapp/app/commons/services/token_store.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/app/modules/signin/data/model/refresh_token_request.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/modules/signin/data/repository/interfaces/interface_signin_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/interceptors/custom_http_interceptor.dart';

class _MockSigninRepository extends Mock implements ISigninRepository {}

class _FakeRefreshTokenRequest extends Fake implements RefreshTokenRequest {}

/// Adapter Dio scripté : renvoie les `ResponseBody` dans l'ordre fourni.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._scripts);
  final List<ResponseBody Function(RequestOptions)> _scripts;
  final List<RequestOptions> calls = [];
  int _idx = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    if (_idx >= _scripts.length) {
      throw StateError('no scripted response for call #$_idx');
    }
    return _scripts[_idx++](options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(int status, Map<String, dynamic> data) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> fakeStorage;

  setUpAll(() async {
    // `LoggerService.initialize` set à la fois LoggerService.talker (utilisé
    // par TalkerDioLogger) et OremusLogger._instance (utilisé par TokenRefresher).
    await LoggerService.initialize(showAppLogs: false);
    registerFallbackValue(_FakeRefreshTokenRequest());
  });

  setUp(() {
    fakeStorage = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'read':
          return fakeStorage[call.arguments['key'] as String];
        case 'write':
          fakeStorage[call.arguments['key'] as String] =
              call.arguments['value'] as String;
          return null;
        case 'delete':
          fakeStorage.remove(call.arguments['key'] as String);
          return null;
        case 'readAll':
          return Map<String, String>.from(fakeStorage);
        case 'deleteAll':
          fakeStorage.clear();
          return null;
        case 'containsKey':
          return fakeStorage.containsKey(call.arguments['key'] as String);
        default:
          return null;
      }
    });
    TokenStore.resetCacheForTesting();
    TokenRefresher.resetForTesting();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  /// Construit un Dio "comme en prod" : validateStatus identique à
  /// `DioUtil`, le `CustomHttpInterceptor` configuré, et un adapter scripté.
  Dio _buildDio({
    required _ScriptedAdapter adapter,
    required Future<Dio> Function() retryDioProvider,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api-test.local',
      validateStatus: (status) {
        if (status == 401 || status == 403) return false;
        return status != null && status < 500;
      },
    ));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(CustomHttpInterceptor(
      baseUrl: 'https://api-test.local',
      retryDioProvider: retryDioProvider,
    ));
    return dio;
  }

  group('Flow 401 → refresh → retry (vertical slice)', () {
    test('requête authentifiée 401 déclenche refresh + retry transparent',
        () async {
      // Le user est connecté avec un refresh token en secure storage.
      fakeStorage['auth.refresh_token'] = 'old-refresh';

      // Le refresh repo retourne une nouvelle paire de tokens.
      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenAnswer(
        (_) async => SigninResponse(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        ),
      );
      TokenRefresher.repositoryBuilder = () => repo;

      late Dio dio;
      // L'adapter renvoie 401 sur le 1er appel, 200 sur le retry.
      final adapter = _ScriptedAdapter([
        (_) => _jsonBody(401, {'message': 'Token expired'}),
        (_) => _jsonBody(200, {'identifier': 42, 'name': 'Sainte Bakhita'}),
      ]);
      dio = _buildDio(
        adapter: adapter,
        retryDioProvider: () async => dio,
      );

      final response = await dio.get(
        '/places-of-worship/42',
        options: Options(headers: {'Authorization': 'Bearer old-access'}),
      );

      // Final response : succès transparent.
      expect(response.statusCode, 200);
      expect(response.data['name'], 'Sainte Bakhita');

      // Le retry a bien eu lieu (2 appels au backend).
      expect(adapter.calls, hasLength(2));
      // Le 1er appel partait avec l'ancien token.
      expect(adapter.calls[0].headers['Authorization'], 'Bearer old-access');
      // Le retry porte le NOUVEAU token + le flag anti-boucle.
      expect(adapter.calls[1].headers['Authorization'], 'Bearer new-access');
      expect(adapter.calls[1].extra['__retried_after_refresh'], true);

      // Une seule invocation du refresh.
      final captured = verify(() => repo.refreshToken(captureAny())).captured;
      expect(captured, hasLength(1));
      expect(
        (captured.single as RefreshTokenRequest).refreshToken,
        'old-refresh',
      );

      // Rotation persistée en secure storage.
      expect(fakeStorage['auth.access_token'], 'new-access');
      expect(fakeStorage['auth.refresh_token'], 'new-refresh');
    });

    test('si le refresh échoue, l\'erreur 401 originale remonte typée', () async {
      fakeStorage['auth.refresh_token'] = 'expired-refresh';

      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenThrow(
        Exception('refresh token rejected'),
      );
      TokenRefresher.repositoryBuilder = () => repo;

      late Dio dio;
      // Une seule entrée scriptée : le 1er 401. Pas de retry attendu.
      final adapter = _ScriptedAdapter([
        (_) => _jsonBody(401, {'message': 'Token expired'}),
      ]);
      dio = _buildDio(
        adapter: adapter,
        retryDioProvider: () async => dio,
      );

      try {
        await dio.get(
          '/places-of-worship/42',
          options: Options(headers: {'Authorization': 'Bearer old-access'}),
        );
        fail('expected DioException');
      } on DioException catch (e) {
        // L'intercepteur a converti le 401 en UnauthorisedException typée.
        expect(e.error, isA<UnauthorisedException>());
        expect((e.error as UnauthorisedException).code, 401);
      }

      // Une seule requête backend (pas de retry).
      expect(adapter.calls, hasLength(1));
    });

    test('requêtes parallèles → 1 seul refresh, toutes retried', () async {
      fakeStorage['auth.refresh_token'] = 'old-refresh';

      var refreshCalls = 0;
      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenAnswer((_) async {
        refreshCalls++;
        // Simule de la latence pour laisser les autres callers démarrer.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return SigninResponse(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
      });
      TokenRefresher.repositoryBuilder = () => repo;

      late Dio dio;
      // 3 requêtes initiales en 401 + 3 retries en 200.
      final adapter = _ScriptedAdapter([
        (_) => _jsonBody(401, {'msg': 'x'}),
        (_) => _jsonBody(401, {'msg': 'x'}),
        (_) => _jsonBody(401, {'msg': 'x'}),
        (_) => _jsonBody(200, {'identifier': 1}),
        (_) => _jsonBody(200, {'identifier': 2}),
        (_) => _jsonBody(200, {'identifier': 3}),
      ]);
      dio = _buildDio(
        adapter: adapter,
        retryDioProvider: () async => dio,
      );

      final headers = {'Authorization': 'Bearer old-access'};
      final responses = await Future.wait([
        dio.get('/r/1', options: Options(headers: headers)),
        dio.get('/r/2', options: Options(headers: headers)),
        dio.get('/r/3', options: Options(headers: headers)),
      ]);

      // Toutes les requêtes ont fini en 200.
      expect(responses.map((r) => r.statusCode).toList(), [200, 200, 200]);
      // Un seul refresh malgré les 3 401 simultanés.
      expect(refreshCalls, 1);
      // 6 appels totaux (3 originaux + 3 retries).
      expect(adapter.calls, hasLength(6));
    });
  });
}
