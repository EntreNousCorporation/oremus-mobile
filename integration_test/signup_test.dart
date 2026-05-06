import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/signup/controller/signup_controller.dart';
import 'package:oremusapp/app/modules/signup/data/repository/signup_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : signup envoie `POST /users/fo-agents` avec les champs
/// du formulaire, la réponse est consommée et le notification de succès
/// s'affiche.
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
      '/users/fo-agents',
      (_) => jsonBody(201, {
        'accessToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.sig',
        'refreshToken': 'refresh-after-signup',
        'isBoUser': false,
      }),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('signupUser → POST /users/fo-agents avec le bon body',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final controller = Get.put<SignupController>(
      SignupController(
        signupRepository: SignupRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
    await tester.pumpAndSettle();

    controller.firstnameController.text = 'Jean';
    controller.lastnameController.text = 'Dupont';
    controller.emailController.text = 'jean.dupont@example.com';
    controller.phoneController.text = '0102030405';
    controller.passwordController.text = 'Test@123';
    controller.confPasswordController.text = 'Test@123';

    controller.signupUser();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final signupCall = dioMock.calls.firstWhere(
      (c) => c.path == '/users/fo-agents' && c.method == 'POST',
      orElse: () => throw StateError('POST /users/fo-agents not captured'),
    );
    final body = signupCall.data as Map<String, dynamic>;
    expect(body['firstname'], 'Jean');
    expect(body['lastname'], 'Dupont');
    expect(body['email'], 'jean.dupont@example.com');
    expect(body['phone'], '0102030405');
    expect(body['password'], 'Test@123');
  });
}
