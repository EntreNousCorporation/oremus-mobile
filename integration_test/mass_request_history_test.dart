import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `MassRequestHistoryController.getMassRequests` charge la
/// liste depuis `/mass-requests/me`. Couvre la zone récemment buggée
/// (cf. commit "Fix bug history mass request after payment").
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
      '/mass-requests/me',
      (_) => jsonBody(200, {
        'content': [
          {
            'identifier': 11,
            'transactionId': 'tx-mass-1',
            'paymentStatus': 'SUCCESS',
            'createdAt': '2026-04-12T08:00:00',
            'updatedAt': '2026-04-12T08:00:00',
          },
          {
            'identifier': 12,
            'transactionId': 'tx-mass-2',
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
      id: 'user-history-001',
      username: 'history@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'getMassRequests → /mass-requests/me chargé et liste rendue',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<MassRequestHistoryController>(
        MassRequestHistoryController(
          massRequestHistoryRepository:
              MassRequestHistoryRepository(ApiClientImpl()),
          massRequestRepository: MassRequestRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );

      controller.getMassRequests();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(controller.massRequests, hasLength(2));
      expect(controller.massRequests[0]?.identifier, 11);
      expect(controller.massRequests[1]?.identifier, 12);
      expect(controller.hasData.value, true);

      final historyCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/mass-requests/me'),
        orElse: () => throw StateError('GET /mass-requests/me not captured'),
      );
      expect(historyCall.method, 'GET');
      expect(historyCall.path, contains('sort=updatedAt,desc'));
    },
  );
}
