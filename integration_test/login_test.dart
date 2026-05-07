import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/signin/controller/signin_controller.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : login submit → tokens persistés → navigation vers le home.
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

    // JWT minimal valide (header.payload.signature) ; le contenu doit
    // être parsable par jwt_decode car SigninController fait
    // `Jwt.parseJwt(value.accessToken)` après login.
    // Payload = { "username": "test@example.com", "phone_number": "+225...", "sub": "user-123" }
    const fakeJwt =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3RAZXhhbXBsZS5jb20iLCJwaG9uZV9udW1iZXIiOiIrMjI1MDAwMDAwMDAwIiwic3ViIjoidXNlci0xMjMifQ.signature';

    dioMock.mock(
      '/auth/login',
      (_) => jsonBody(200, {
        'accessToken': fakeJwt,
        'refreshToken': 'refresh-test-001',
        'isBoUser': false,
        'isTmpPassword': false,
        'expiresIn': 7776000,
      }),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
    // Le splash navigue vers home après 3s, qui appelle /places-of-worship.
    // On répond avec une liste vide pour ne pas polluer les logs (le test
    // n'assert rien sur cette page).
    dioMock.mock(
      '/places-of-worship',
      (_) => jsonBody(200, {'content': <Map<String, dynamic>>[], 'last': true}),
    );
  });

  setUp(() {
    secureStorage.store.clear();
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('submit du formulaire login → tokens persistés et nav home',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();

    // Laisse le splash compléter son timer 3s puis le home initialiser ;
    // sinon Get.toNamed(SIGNIN) est écrasé par le Get.offNamed(HOME) du
    // splash quand son Future.delayed se résout.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    Get.toNamed(Routes.SIGNIN);
    await tester.pumpAndSettle();

    // Saisie via vrais gestures clavier `tester.enterText` sur les
    // TextFormField (email = 1er, password = 2ème). Cela passe par les
    // FocusNode et déclenche `onChanged` → `controller.checkForm()`.
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.pumpAndSettle();

    final controller = Get.find<SigninController>();
    expect(controller.emailController.text, 'test@example.com');
    expect(controller.passwordController.text, 'password123');
    expect(controller.isValidForm.isTrue, true,
        reason: 'le bouton "Se connecter" est gris-désactivé tant que '
            'isValidForm est false ; checkForm doit être déclenché par '
            'le onChanged des TextFormField');

    // Tap sur le bouton submit (ElevatedButton qui contient "Se connecter").
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Vérifs : tokens en secure storage + flag global de session.
    expect(secureStorage.store['auth.access_token'], isNotNull);
    expect(secureStorage.store['auth.refresh_token'], 'refresh-test-001');
    expect(app.isUserConnected.value, true);

    // Le 1er appel intercepté est /auth/login (GET? non, POST).
    final loginCall = dioMock.calls.firstWhere(
      (c) => c.path == '/auth/login',
      orElse: () => throw StateError('login call not captured'),
    );
    expect(loginCall.method, 'POST');
  });
}
