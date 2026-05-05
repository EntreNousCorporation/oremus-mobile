import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/services/auth_gate.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `AuthGate.handleUnauthorized` (déclenché par l'intercepteur
/// sur 401 non récupérable) doit purger les tokens, reset le flag global
/// et rediriger vers /signin sur le **vrai** GetMaterialApp.
///
/// Le flow réseau complet (401 → refresh → 401 → AuthGate) est couvert par
/// le test vertical-slice de PR #6 ; ici on valide spécifiquement que les
/// effets d'AuthGate impactent bien la navigator live d'OremusApp.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageMock();

  setUpAll(() async {
    secureStorage.install();
    await app.bootstrap(
      options: app.BootstrapOptions.forTests(
        overrideFlavorSettings: FlavorSettings.dev(),
      ),
    );
  });

  setUp(() {
    secureStorage.store
      ..clear()
      ..['auth.access_token'] = 'expired-access'
      ..['auth.refresh_token'] = 'expired-refresh';
    DB.saveUserSigninInfo(Signin(
      id: 'user-test-401',
      username: 'expired@example.com',
    ));
    app.isUserConnected.value = true;
    AuthGate.resetAfterLogin();
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'AuthGate.handleUnauthorized → tokens effacés + nav signin E2E',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();

      // Déclenche directement AuthGate, comme le ferait l'intercepteur
      // sur un 401 non récupérable (cf. unit test PR #6 pour le flow réseau).
      await AuthGate.handleUnauthorized();

      // Pumps sans avancer le temps simulé pour ne pas laisser le
      // Future.delayed(3s) du splash écraser notre Get.offAllNamed.
      for (var i = 0; i < 10; i++) {
        await tester.pump();
      }

      expect(secureStorage.store.containsKey('auth.access_token'), false);
      expect(secureStorage.store.containsKey('auth.refresh_token'), false);
      expect(app.isUserConnected.value, false);
      expect(Get.currentRoute, Routes.SIGNIN);
    },
  );
}
