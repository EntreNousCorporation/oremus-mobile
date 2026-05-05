import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_controller.dart';
import 'package:oremusapp/app/modules/donationhistory/data/repository/donation_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `DonationHistoryController.getDonations` charge l'historique
/// des dons depuis `/donations/me`.
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
      '/donations/me',
      (_) => jsonBody(200, {
        'content': [
          {
            'identifier': 21,
            'transactionId': 'tx-don-1',
            'amount': 5000,
            'paymentStatus': 'SUCCESS',
            'createdAt': '2026-04-12T08:00:00',
            'updatedAt': '2026-04-12T08:00:00',
          },
          {
            'identifier': 22,
            'transactionId': 'tx-don-2',
            'amount': 10000,
            'paymentStatus': 'PENDING',
            'createdAt': '2026-04-15T10:00:00',
            'updatedAt': '2026-04-15T10:00:00',
          },
        ],
        'last': true,
        'totalElements': 2,
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
      id: 'user-don-history',
      username: 'donhistory@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'getDonations → /donations/me chargé et liste rendue',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<DonationHistoryController>(
        DonationHistoryController(
          donationHistoryRepository: DonationHistoryRepository(ApiClientImpl()),
          donationRepository: DonationRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );

      controller.getDonations();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(controller.donations, hasLength(2));
      expect(controller.donations[0]?.identifier, 21);
      expect(controller.donations[1]?.identifier, 22);
      expect(controller.hasData.value, true);

      final donCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/donations/me'),
        orElse: () => throw StateError('GET /donations/me not captured'),
      );
      expect(donCall.method, 'GET');
      expect(donCall.path, contains('sort=updatedAt,desc'));
    },
  );
}
