import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_confession_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_mass_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_office_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_presby_team_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : chaque sous-onglet du paroisse-menu déclenche son endpoint
/// `/places-of-worship/{id}/...` au montage. Couvre les 5 controllers
/// principaux : Mass / Confession / Office / Activity-Movement / Presby Team.
/// (Contact controller n'a pas de fetch dédié — pas inclus.)
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
      '/places-of-worship/42/liturgical-celebrations',
      (_) => jsonBody(200, <Map<String, dynamic>>[]),
    );
    dioMock.mock(
      '/places-of-worship/42/activities',
      (_) => jsonBody(200, <Map<String, dynamic>>[]),
    );
    dioMock.mock(
      '/places-of-worship/42/movements',
      (_) => jsonBody(200, <Map<String, dynamic>>[]),
    );
    dioMock.mock(
      '/places-of-worship/42/users',
      (_) => jsonBody(200, <Map<String, dynamic>>[]),
    );
    dioMock.mock(
      '/places-of-worship/42/services',
      (_) => jsonBody(200, <Map<String, dynamic>>[]),
    );
    dioMock.mock(
      '/places-of-worship',
      (_) => jsonBody(200, {'content': <Map<String, dynamic>>[], 'last': true}),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'sub-tabs paroisse menu : chaque controller fire son endpoint',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Mass tab : `getLiturgicalCelebration` → /liturgical-celebrations
      final massCtrl = Get.put<ParoisseMassController>(
        ParoisseMassController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // Forcer la paroisse selected à 42 (sans Get.arguments le getArguments noop).
      massCtrl.paroisseSelected.value.identifier = 42;
      // Re-déclencher : les fetchs sont en onReady ; on les appelle nous-mêmes.
      massCtrl.getMasseRecurrentTimes();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Confession tab : /liturgical-celebrations (même endpoint, filtre côté client)
      final confessionCtrl = Get.put<ParoisseConfessionController>(
        ParoisseConfessionController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      confessionCtrl.paroisseSelected.value.identifier = 42;
      confessionCtrl.getConfessionsRecurrentTimes();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Office tab
      final officeCtrl = Get.put<ParoisseOfficeController>(
        ParoisseOfficeController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      officeCtrl.paroisseSelected.value.identifier = 42;
      officeCtrl.getOfficeTimes();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Activity-Movement tab : 2 endpoints (movements + activities)
      final activityCtrl = Get.put<ParoisseActivityMovementController>(
        ParoisseActivityMovementController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      activityCtrl.paroisseSelected.value.identifier = 42;
      activityCtrl.getMovements();
      activityCtrl.getActivities();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Presby team tab : /users
      final presbyCtrl = Get.put<ParoissePresbyTeamController>(
        ParoissePresbyTeamController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      presbyCtrl.paroisseSelected.value.identifier = 42;
      presbyCtrl.getPresbyTeams();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tous les endpoints attendus ont été tirés au moins une fois.
      expect(
        dioMock.calls.any(
          (c) => c.path == '/places-of-worship/42/liturgical-celebrations',
        ),
        true,
        reason: 'mass / confession / office tirent tous le même endpoint',
      );
      expect(
        dioMock.calls.any(
          (c) => c.path == '/places-of-worship/42/movements',
        ),
        true,
      );
      expect(
        dioMock.calls.any(
          (c) => c.path == '/places-of-worship/42/activities',
        ),
        true,
      );
      expect(
        dioMock.calls.any(
          (c) => c.path == '/places-of-worship/42/users',
        ),
        true,
      );
      expect(
        dioMock.calls.any(
          (c) => c.path == '/places-of-worship/42/services',
        ),
        true,
        reason: 'office controller hit /services',
      );
    },
  );
}
