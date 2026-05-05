import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
// `TypeData` vient de donation (massrequest la hide), `PriceData` vient
// de massrequest (donation la hide). Reflète l'aliasing du controller.
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart' show TypeData;
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_recap_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart' show PriceData;
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `MassRequestRecapController.doSendMassRequest` envoie un
/// `POST /mass-requests` avec le body attendu (paroisse, type, intention,
/// slots, paymentMethod, phone).
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

    dioMock.mock(
      '/places-of-worship',
      (_) => jsonBody(200, {'content': <Map<String, dynamic>>[], 'last': true}),
    );
    dioMock.mock(
      '/payment-methods',
      (_) => jsonBody(200, [
        {
          'name': {'fr': 'Wave', 'en': 'Wave'},
          'code': 'WAVE_CI',
        },
      ]),
    );
    dioMock.mock(
      '/mass-requests',
      (_) => jsonBody(200, {
        'identifier': 88,
        'transactionId': 'tx-mass-001',
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
      id: 'user-test-mass',
      username: 'mass@example.com',
      phone: '0102030405',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'doSendMassRequest → POST /mass-requests avec le bon body',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      // Laisse le splash compléter pour ne plus avoir de timer dangling.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<MassRequestRecapController>(
        MassRequestRecapController(
          paymentRepository: PaymentRepository(ApiClientImpl()),
          massRequestRepository: MassRequestRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // onInit fait /payment-methods : on attend qu'il complète.
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(controller.paymentMethods, isNotEmpty);

      // Setup état requis par doSendMassRequest.
      controller.paroisseSelected.value =
          ContentPlace(identifier: 12, name: 'Paroisse Test');
      controller.massRequestTypeSelected.value = TypeData(code: 'ORDINARY');
      controller.prayerIntentSelected.value = 'Pour la paix';
      controller.datesChoosen.add(
        PriceData(
          dayOfWeek: 'MONDAY',
          day: '2026-05-12',
          repeat: 1,
          isDaySelected: true,
        ),
      );
      controller.paymentMethodSelected.value = controller.paymentMethods.first;
      controller.phoneNumberController.text = '0102030405';

      controller.doSendMassRequest();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final massCall = dioMock.calls.firstWhere(
        (c) => c.path == '/mass-requests' && c.method == 'POST',
        orElse: () => throw StateError('POST /mass-requests not captured'),
      );
      final body = massCall.data as Map<String, dynamic>;
      expect(body['worshipPlace'], 12);
      expect(body['typeOfMassRequest'], 'ORDINARY');
      expect(body['prayerIntent'], 'Pour la paix');
      expect(body['paymentMethod'], 'WAVE_CI');
      expect(body['phoneNumber'], '+2250102030405');
      expect(body['slots'], isA<List>());
      expect((body['slots'] as List), hasLength(1));
    },
  );
}
