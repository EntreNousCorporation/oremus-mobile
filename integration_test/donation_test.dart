import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_recap_controller.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `DonationRecapController.doSendDonation` envoie un
/// `POST /donations` avec le bon body (montant, paroisse, paymentMethod,
/// phone) et la réponse est consommée.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageMock();
  final dioMock = RoutingMockAdapter();

  setUpAll(() async {
    secureStorage.install();
    await app.bootstrap(
      options: app.BootstrapOptions.forTests(
        overrideFlavorSettings: FlavorSettings.dev(),
      ),
    );
    final dio = await DioUtil().getInstance();
    dio.httpClientAdapter = dioMock;

    // Liste des paroisses pour le boot du home (skippé via OremusApp).
    dioMock.mock(
      '/places-of-worship',
      (_) => jsonBody(200, {'content': <Map<String, dynamic>>[], 'last': true}),
    );
    // /payment-methods : appelé par DonationRecapController.onInit.
    dioMock.mock(
      '/payment-methods',
      (_) => jsonBody(200, [
        {
          'name': {'fr': 'Wave', 'en': 'Wave'},
          'code': 'WAVE_CI',
        },
      ]),
    );
    // /donations : la cible du test.
    dioMock.mock(
      '/donations',
      (_) => jsonBody(200, {
        'identifier': 42,
        'transactionId': 'tx-don-001',
      }),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  setUp(() {
    secureStorage.store
      ..clear()
      ..['auth.access_token'] = 'access-test'
      ..['auth.refresh_token'] = 'refresh-test';
    DB.saveUserSigninInfo(Signin(
      id: 'user-test-don',
      username: 'don@example.com',
      phone: '0102030405',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('doSendDonation → POST /donations avec le bon body',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();
    // On laisse le splash compléter pour qu'il n'y ait plus de
    // Future.delayed dangling pendant la suite.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Instancie le controller manuellement (sans naviguer vers /donation-recap)
    // — ce qu'on valide c'est l'effet de doSendDonation, pas le binding.
    final controller = Get.put<DonationRecapController>(
      DonationRecapController(
        paymentRepository: PaymentRepository(ApiClientImpl()),
        donationRepository: DonationRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
    // Le onInit fait /payment-methods : on attend qu'il complète.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(controller.paymentMethods, isNotEmpty,
        reason: 'le mock /payment-methods doit avoir alimenté la liste');

    // Setup état requis par doSendDonation.
    controller.paroisseSelected.value =
        ContentPlace(identifier: 7, name: 'Paroisse Test');
    controller.amount.value = '5000';
    controller.paymentMethodSelected.value = controller.paymentMethods.first;
    controller.phoneNumberController.text = '0102030405';

    controller.doSendDonation();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final donationCall = dioMock.calls.firstWhere(
      (c) => c.path == '/donations' && c.method == 'POST',
      orElse: () => throw StateError('POST /donations not captured'),
    );
    final body = donationCall.data as Map<String, dynamic>;
    expect(body['amount'], '5000');
    expect(body['worshipPlace'], '7');
    expect(body['paymentMethod'], 'WAVE_CI');
    expect(body['phoneNumber'], '+2250102030405');
  });
}
