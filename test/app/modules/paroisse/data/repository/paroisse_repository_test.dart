import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<dynamic> _ok(Map<String, dynamic> data) => Response(
      statusCode: 200,
      data: data,
      requestOptions: RequestOptions(path: ''),
    );

Response<dynamic> _err(int code, Map<String, dynamic> data) => Response(
      statusCode: code,
      data: data,
      requestOptions: RequestOptions(path: ''),
    );

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('oremus_db_test');
    Hive.init(tempDir.path);
    registerFallbackValue(HttpMethod.get);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    DB.encryptedBox = await Hive.openBox(
      'test_box_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await DB.encryptedBox?.deleteFromDisk();
    DB.encryptedBox = null;
  });

  group('ParoisseRepository.getParoisses — utilisateur connecté', () {
    test('isFavorite reflète isUserFavorite renvoyé par le backend', () async {
      DB.saveUserSigninInfo(Signin(id: 'user-123', username: 'test'));

      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({
            'content': [
              {
                'identifier': 1,
                'name': 'Sainte Bakhita',
                'isUserFavorite': true,
              },
              {
                'identifier': 2,
                'name': 'Saint Joseph',
                'isUserFavorite': false,
              },
            ],
          }));

      final result = await ParoisseRepository(api).getParoisses(
        searchCriteria: SearchCriteria(),
      );

      expect(result.contents, hasLength(2));
      expect(result.contents![0]!.isFavorite, true);
      expect(result.contents![1]!.isFavorite, false);
    });

    test('searchCriteria.likerUserId est rempli avec l\'id user courant',
        () async {
      DB.saveUserSigninInfo(Signin(id: 'user-456', username: 'test'));

      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({'content': []}));

      final criteria = SearchCriteria();
      await ParoisseRepository(api).getParoisses(searchCriteria: criteria);

      expect(criteria.likerUserId, 'user-456');
      final captured = verify(() => api.doRequest(
            endpoint: captureAny(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).captured.single as String;
      expect(captured, contains('likerUserId=user-456'));
    });
  });

  group('ParoisseRepository.getParoisses — utilisateur anonyme', () {
    test('isFavorite reflète les favoris locaux non synchronisés', () async {
      // Aucun user connecté ; favoris locaux contiennent identifier=1
      DB.saveUnsynchronizedFavorites([
        ContentPlace(identifier: 1),
        ContentPlace(identifier: 99),
      ]);

      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({
            'content': [
              {'identifier': 1, 'name': 'Sainte Bakhita'},
              {'identifier': 2, 'name': 'Saint Joseph'},
            ],
          }));

      final result = await ParoisseRepository(api).getParoisses(
        searchCriteria: SearchCriteria(),
      );

      expect(result.contents![0]!.isFavorite, true);
      expect(result.contents![1]!.isFavorite, false);
    });

    test('isFavorite false partout si aucun favori local', () async {
      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({
            'content': [
              {'identifier': 1, 'name': 'Sainte Bakhita'},
            ],
          }));

      final result = await ParoisseRepository(api).getParoisses(
        searchCriteria: SearchCriteria(),
      );

      expect(result.contents![0]!.isFavorite, false);
    });

    test('searchCriteria.likerUserId est vidé quand aucun user connecté',
        () async {
      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({'content': []}));

      final criteria = SearchCriteria(likerUserId: 'stale-id');
      await ParoisseRepository(api).getParoisses(searchCriteria: criteria);

      expect(criteria.likerUserId, '');
    });
  });

  group('ParoisseRepository.getParoisses — erreurs', () {
    test('non-200 lève une CustomException avec le message backend',
        () async {
      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _err(500, {
            'status': '500',
            'debugMessage': 'Internal error',
          }));

      expect(
        () => ParoisseRepository(api).getParoisses(
          searchCriteria: SearchCriteria(),
        ),
        throwsA(isA<CustomException>()),
      );
    });

    test('content vide retourne un DataResponse sans crash', () async {
      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({'content': <Map<String, dynamic>>[]}));

      final result = await ParoisseRepository(api).getParoisses(
        searchCriteria: SearchCriteria(),
      );

      expect(result.contents, isEmpty);
    });
  });

  group('ParoisseRepository.getParoisses — endpoint', () {
    test('encode les paramètres optionnels seulement quand présents',
        () async {
      final api = _MockApiClient();
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => _ok({'content': []}));

      await ParoisseRepository(api).getParoisses(
        page: 2,
        searchCriteria: SearchCriteria(
          name: 'Bakhita',
          diocese: 'Abidjan',
        ),
      );

      final endpoint = verify(() => api.doRequest(
            endpoint: captureAny(named: 'endpoint'),
            method: HttpMethod.get,
            useBearer: false,
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).captured.single as String;

      expect(endpoint, startsWith('/places-of-worship?page=2'));
      expect(endpoint, contains('name=Bakhita'));
      expect(endpoint, contains('diocese=Abidjan'));
      expect(endpoint, isNot(contains('city=')));
      expect(endpoint, isNot(contains('municipality=')));
    });
  });
}
