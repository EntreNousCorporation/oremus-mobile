import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/repository/life_plan_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `LifePlanController` charge les plans disponibles
/// (`/life-plans`) et ceux de l'utilisateur (`/users/life-plans`).
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
    // Sous-paths d'abord (RoutingMockAdapter matche dans l'ordre).
    dioMock.mock(
      '/users/life-plans',
      (_) => jsonBody(200, {
        'content': [
          {'identifier': 99, 'startDate': '2026-01-01'},
        ],
        'last': true,
      }),
    );
    dioMock.mock(
      '/life-plans',
      (_) => jsonBody(200, {
        'content': [
          {'identifier': 1, 'name': 'Plan A'},
          {'identifier': 2, 'name': 'Plan B'},
        ],
        'last': true,
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
      id: 'usr-lp',
      username: 'lifeplan@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'LifePlanController charge /life-plans et /users/life-plans',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      Get.put<LifePlanController>(
        LifePlanController(
          lifePlanRepository: LifePlanRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // onInit déclenche le chargement.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final availableCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/life-plans'),
        orElse: () => throw StateError('GET /life-plans not captured'),
      );
      expect(availableCall.method, 'GET');

      final userCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/users/life-plans'),
        orElse: () => throw StateError('GET /users/life-plans not captured'),
      );
      expect(userCall.method, 'GET');
    },
  );
}
