import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/services/token_refresher.dart';
import 'package:oremusapp/app/modules/signin/data/model/refresh_token_request.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/modules/signin/data/repository/interfaces/interface_signin_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockSigninRepository extends Mock implements ISigninRepository {}

class _FakeRefreshTokenRequest extends Fake implements RefreshTokenRequest {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Channel mock pour flutter_secure_storage : les appels read/write
  // tombent sur une Map en mémoire au lieu du Keychain/EncryptedSharedPrefs.
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> fakeStorage;

  setUpAll(() {
    registerFallbackValue(_FakeRefreshTokenRequest());
    // OremusLogger._instance est `late final` ; sans LoggerService.initialize()
    // les chemins d'erreur du TokenRefresher plantent sur LateInitializationError.
    OremusLogger.setTalkerInstance(Talker());
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
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TokenRefresher.resetForTesting();
  });

  group('TokenRefresher.refreshIfNeeded', () {
    test('retourne null sans appeler le repo si aucun refresh token stocké', () async {
      final repo = _MockSigninRepository();
      TokenRefresher.repositoryBuilder = () => repo;

      final result = await TokenRefresher.refreshIfNeeded();

      expect(result, isNull);
      verifyNever(() => repo.refreshToken(any()));
    });

    test('rafraîchit, sauvegarde la rotation et retourne le nouveau access token', () async {
      fakeStorage['auth.refresh_token'] = 'old-refresh';

      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenAnswer(
        (_) async => SigninResponse(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        ),
      );
      TokenRefresher.repositoryBuilder = () => repo;

      final result = await TokenRefresher.refreshIfNeeded();

      expect(result, 'new-access');
      expect(fakeStorage['auth.access_token'], 'new-access');
      expect(fakeStorage['auth.refresh_token'], 'new-refresh');
      final captured = verify(() => repo.refreshToken(captureAny())).captured.single;
      expect((captured as RefreshTokenRequest).refreshToken, 'old-refresh');
    });

    test('retourne null si le repo retourne une réponse incomplète', () async {
      fakeStorage['auth.refresh_token'] = 'old-refresh';

      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenAnswer(
        (_) async => SigninResponse(accessToken: 'new-access'),
      );
      TokenRefresher.repositoryBuilder = () => repo;

      final result = await TokenRefresher.refreshIfNeeded();

      expect(result, isNull);
      // Pas de rotation persistée si la réponse n'est pas complète.
      expect(fakeStorage.containsKey('auth.access_token'), false);
    });

    test('retourne null et ne stocke rien si le repo lève une exception', () async {
      fakeStorage['auth.refresh_token'] = 'old-refresh';

      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenThrow(Exception('boom'));
      TokenRefresher.repositoryBuilder = () => repo;

      final result = await TokenRefresher.refreshIfNeeded();

      expect(result, isNull);
      expect(fakeStorage.containsKey('auth.access_token'), false);
      // Le refresh token initial n'a pas été écrasé par une rotation foireuse.
      expect(fakeStorage['auth.refresh_token'], 'old-refresh');
    });

    test('mutex : N appels concurrents partagent un seul refresh', () async {
      fakeStorage['auth.refresh_token'] = 'old-refresh';

      var callCount = 0;
      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenAnswer((_) async {
        callCount++;
        // Yield au scheduler pour laisser les autres callers démarrer
        // avant que le premier ne complète.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return SigninResponse(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
      });
      TokenRefresher.repositoryBuilder = () => repo;

      final results = await Future.wait([
        TokenRefresher.refreshIfNeeded(),
        TokenRefresher.refreshIfNeeded(),
        TokenRefresher.refreshIfNeeded(),
        TokenRefresher.refreshIfNeeded(),
        TokenRefresher.refreshIfNeeded(),
      ]);

      expect(callCount, 1);
      expect(results, everyElement('new-access'));
    });

    test('après un refresh terminé, un nouveau refresh peut être lancé', () async {
      fakeStorage['auth.refresh_token'] = 'first-refresh';

      var callCount = 0;
      final repo = _MockSigninRepository();
      when(() => repo.refreshToken(any())).thenAnswer((_) async {
        callCount++;
        return SigninResponse(
          accessToken: 'access-$callCount',
          refreshToken: 'refresh-$callCount',
        );
      });
      TokenRefresher.repositoryBuilder = () => repo;

      final first = await TokenRefresher.refreshIfNeeded();
      final second = await TokenRefresher.refreshIfNeeded();

      expect(first, 'access-1');
      expect(second, 'access-2');
      expect(callCount, 2);
    });
  });
}
