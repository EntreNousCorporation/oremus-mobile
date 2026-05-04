import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// `payment_repository.dart` expose une variable top-level `test` (sample data),
// qui rentre en conflit avec `test()` de flutter_test. On la masque.
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart' hide test;
import 'package:oremusapp/app/remote/custom_exception.dart';

import '../../../../../test_utils/api_client_helpers.dart';

void main() {
  late MockApiClient api;
  late PaymentRepository repo;

  setUpAll(registerHttpMethodFallback);

  setUp(() {
    api = MockApiClient();
    repo = PaymentRepository(api);
  });

  group('PaymentRepository.paymentStatus', () {
    test('200 → renvoie un PaymentStatusData parsé', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({
            'transactionId': 'tx-123',
            'paymentStatus': 'SUCCESS',
          }));

      final result = await repo.paymentStatus(transactionId: 'tx-123');

      expect(result.transactionId, 'tx-123');
      expect(result.paymentStatus, 'SUCCESS');
    });

    test('endpoint inclut transactionId et manualVerify', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse(<String, dynamic>{}));

      await repo.paymentStatus(transactionId: 'tx-abc');

      final captured = verify(() => api.doRequest(
            endpoint: captureAny(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).captured.single as String;
      expect(captured, '/checkout/check-payment/tx-abc?manualVerify=false');
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
        () => repo.paymentStatus(transactionId: 'tx-x'),
        throwsA(isA<CustomException>()),
      );
    });
  });

  group('PaymentRepository.getPaymentMethods', () {
    test('200 → liste de PaymentMethodData parsée', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse([
            {
              'name': {'fr': 'Wave', 'en': 'Wave'},
              'code': 'WAVE_CI',
            },
            {
              'name': {'fr': 'Orange Money', 'en': 'Orange Money'},
              'code': 'OM_CI',
            },
          ]));

      final result = await repo.getPaymentMethods();

      expect(result, hasLength(2));
      expect(result[0].code, 'WAVE_CI');
      expect(result[1].code, 'OM_CI');
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
        () => repo.getPaymentMethods(),
        throwsA(isA<CustomException>()),
      );
    });
  });
}
