import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/diocese_repository.dart';

import '../../../../../test_utils/api_client_helpers.dart';

void main() {
  late MockApiClient api;
  late DioceseRepository repo;

  setUpAll(registerHttpMethodFallback);

  setUp(() {
    api = MockApiClient();
    repo = DioceseRepository(api);
  });

  group('DioceseRepository.getDioceses', () {
    test('200 → DataResponse parsé', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({
            'content': [
              {'identifier': 1, 'name': "Archidiocèse d'Abidjan"},
              {'identifier': 2, 'name': 'Diocèse de Yopougon'},
            ],
            'empty': false,
          }));

      final result = await repo.getDioceses();

      expect(result.empty, false);
      expect(result.contents, hasLength(2));
      expect(result.contents?[0]?.name, "Archidiocèse d'Abidjan");
    });

    test('endpoint inclut page, taille fixe et tri par nom ASC', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'empty': true}));

      await repo.getDioceses(page: 2);

      final endpoint = verify(() => api.doRequest(
            endpoint: captureAny(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).captured.single as String;
      expect(endpoint, contains('/dioceses?page=2'));
      expect(endpoint, contains('size=100'));
      expect(endpoint, contains('sort=name%2CASC'));
    });

    test('appelé sans Bearer (endpoint public)', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'empty': true}));

      await repo.getDioceses();

      final useBearer = verify(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: captureAny(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).captured.single as bool;
      expect(useBearer, false,
          reason: 'la liste des diocèses est servie en anonyme');
    });

    test('non-200 → Exception', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => errResponse(503));

      expect(() => repo.getDioceses(), throwsException);
    });
  });
}
