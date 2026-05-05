import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : user authentifié → tap logout → tokens effacés et nav signin.
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
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  setUp(() {
    // Simule un user déjà loggé : tokens en secure storage, user info en
    // Hive (sinon SplashscreenController.hasUserConnected reset le flag à
    // false), et le flag global on.
    secureStorage.store
      ..clear()
      ..['auth.access_token'] = 'access-already-logged-in'
      ..['auth.refresh_token'] = 'refresh-already-logged-in';
    DB.saveUserSigninInfo(Signin(
      id: 'user-test-001',
      username: 'test@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('user authentifié → doLogout → tokens effacés + nav signin',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();

    // Le test ne dépend pas du chemin splash → home : on instancie le
    // controller manuellement et on appelle doLogout. Ce qu'on valide c'est
    // l'effet du logout (TokenStore, isUserConnected, navigation), pas
    // les bindings GetX.
    final controller = Get.put<CustomHomeController>(
      CustomHomeController(
        signinRepository: SigninRepository(ApiClientImpl()),
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
    expect(app.isUserConnected.value, true);

    // Action : équivalent du tap sur "Déconnexion" dans le drawer.
    // On évite pumpAndSettle ici : le splash a un Future.delayed(3s) qui
    // sinon firerait pendant le pump, redirigeant vers /custom-home-new
    // après notre Get.offAllNamed(SIGNIN). On pump juste assez de frames
    // pour que la nav signin se résolve.
    await controller.doLogout();
    for (var i = 0; i < 10; i++) {
      await tester.pump();
    }

    // Vérifs : secure storage purgée, flag global off, redir signin.
    expect(secureStorage.store.containsKey('auth.access_token'), false,
        reason: 'le token d\'accès doit être effacé du secure storage');
    expect(secureStorage.store.containsKey('auth.refresh_token'), false,
        reason: 'le refresh token doit être effacé du secure storage');
    expect(app.isUserConnected.value, false);
    expect(Get.currentRoute, Routes.SIGNIN);
  });
}
