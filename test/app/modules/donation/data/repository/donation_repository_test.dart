import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';

import '../../../../../test_utils/api_client_helpers.dart';

void main() {
  late MockApiClient api;
  late DonationRepository repo;

  setUpAll(registerHttpMethodFallback);

  setUp(() {
    api = MockApiClient();
    repo = DonationRepository(api);
  });

  group('DonationRepository.sendDonation', () {
    test('200 → renvoie un DonationResponse parsé', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({
            'identifier': 42,
            'amount': 5000,
          }));

      final result = await repo.sendDonation(request: DonationData());

      expect(result, isA<DonationResponse>());
      expect(result.identifier, 42);
    });

    test('204 (No Content) est accepté comme succès', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'identifier': 1}, code: 204));

      final result = await repo.sendDonation(request: DonationData());
      expect(result.identifier, 1);
    });

    test('endpoint = /donations en POST', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse(<String, dynamic>{}));

      await repo.sendDonation(request: DonationData());

      verify(() => api.doRequest(
            endpoint: '/donations',
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
        () => repo.sendDonation(request: DonationData()),
        throwsA(isA<CustomException>()),
      );
    });
  });

  group('DonationRepository.donationRetryPayment', () {
    test('200 → renvoie un DonationResponse parsé', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse({'identifier': 7}));

      final result = await repo.donationRetryPayment(request: PaymentStatusData());

      expect(result.identifier, 7);
    });

    test('endpoint = /donations/retry-payment', () async {
      when(() => api.doRequest(
            endpoint: any(named: 'endpoint'),
            method: any(named: 'method'),
            useBearer: any(named: 'useBearer'),
            body: any(named: 'body'),
            customBaseUrl: any(named: 'customBaseUrl'),
          )).thenAnswer((_) async => okResponse(<String, dynamic>{}));

      await repo.donationRetryPayment(request: PaymentStatusData());

      verify(() => api.doRequest(
            endpoint: '/donations/retry-payment',
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
          )).thenAnswer((_) async => errResponse(409));

      expect(
        () => repo.donationRetryPayment(request: PaymentStatusData()),
        throwsA(isA<CustomException>()),
      );
    });
  });
}
