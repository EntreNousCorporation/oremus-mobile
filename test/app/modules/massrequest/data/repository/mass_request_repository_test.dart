import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';

import '../../../../../test_utils/api_client_helpers.dart';

void main() {
  late MockApiClient api;
  late MassRequestRepository repo;

  setUpAll(registerHttpMethodFallback);

  setUp(() {
    api = MockApiClient();
    repo = MassRequestRepository(api);
  });

  group('MassRequestRepository.getMassRequestType', () {
    test('200 → liste de TypeData parsée', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse([
            {'identifier': 1, 'code': 'ORDINARY'},
            {'identifier': 2, 'code': 'SPECIAL'},
          ]));

      final result = await repo.getMassRequestType();

      expect(result, hasLength(2));
      expect(result[0].code, 'ORDINARY');
    });

    test('non-200 → CustomException', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => errResponse(500));

      expect(
        () => repo.getMassRequestType(),
        throwsA(isA<CustomException>()),
      );
    });
  });

  group('MassRequestRepository.getPrayerIntent', () {
    test('200 → liste de PrayerIntentData parsée', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse([
            {'identifier': 10, 'code': 'HEALTH'},
          ]));

      final result = await repo.getPrayerIntent();

      expect(result, hasLength(1));
      expect(result[0].code, 'HEALTH');
    });

    test('non-200 → CustomException', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => errResponse(503));

      expect(
        () => repo.getPrayerIntent(),
        throwsA(isA<CustomException>()),
      );
    });
  });

  group('MassRequestRepository.getMassRequestPrice', () {
    test('200 → PriceResponse parsée', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'totalAmount': 1500}));

      final result = await repo.getMassRequestPrice(
        request: const [],
        workshipId: 'wp-42',
      );

      expect(result, isA<PriceResponse>());
    });

    test('endpoint inclut workshipId dans le path', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse(<String, dynamic>{}));

      await repo.getMassRequestPrice(
        request: const [],
        workshipId: 'wp-42',
      );

      verify(() => api.doRequest(
            endpoint: '/mass-requests/wp-42/quotation',
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).called(1);
    });

    test('le body filtre les PriceData null', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse(<String, dynamic>{}));

      final entries = [PriceData(repeat: 2), null, PriceData(repeat: 1)];
      await repo.getMassRequestPrice(request: entries, workshipId: 'wp-1');

      final body = verify(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: captureAny(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).captured.single as List;
      expect(body, hasLength(2));
    });

    test('non-200 → CustomException', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => errResponse(400));

      expect(
        () => repo.getMassRequestPrice(request: const [], workshipId: 'wp-1'),
        throwsA(isA<CustomException>()),
      );
    });
  });

  group('MassRequestRepository.sendMassRequest', () {
    test('201 → MassRequestResponse parsée', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'identifier': 99}, code: 201));

      final result = await repo.sendMassRequest(request: MassRequestData());

      expect(result, isA<MassRequestResponse>());
      expect(result.identifier, 99);
    });

    test('non-2xx → CustomException', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => errResponse(409));

      expect(
        () => repo.sendMassRequest(request: MassRequestData()),
        throwsA(isA<CustomException>()),
      );
    });
  });

  group('MassRequestRepository.retryPayment', () {
    test('200 → MassRequestResponse parsée', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'identifier': 7}));

      final result = await repo.retryPayment(request: PaymentStatusData());

      expect(result.identifier, 7);
    });

    test('endpoint = /mass-requests/retry-payment', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse(<String, dynamic>{}));

      await repo.retryPayment(request: PaymentStatusData());

      verify(() => api.doRequest(
            endpoint: '/mass-requests/retry-payment',
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).called(1);
    });

    test('non-2xx → CustomException', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => errResponse(500));

      expect(
        () => repo.retryPayment(request: PaymentStatusData()),
        throwsA(isA<CustomException>()),
      );
    });
  });
}
