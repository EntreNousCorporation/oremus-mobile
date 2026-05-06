import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/init_reset_password_controller.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/otp_controller.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/reset_password_controller.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/reset_password_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : flow complet de reset password à travers les 3 controllers.
///   1. `InitResetPasswordController.doInitResetPassword` →
///      `POST /users/fo-agents/{email}/init-reset-password`
///   2. `OtpController.doCheckOtp` →
///      `POST /users/fo-agents/check-otp?email=...&otp=...`
///   3. `ResetPasswordController.doResetPassword` →
///      `POST /users/fo-agents/reset-password`
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

    // 1) init-reset-password : enregistrer AVANT /users/fo-agents/check-otp
    //    (les deux ont des préfixes proches, mais la check-otp ne contient pas
    //    `init-reset-password`).
    dioMock.mock(
      '/users/fo-agents/test@example.com/init-reset-password',
      (_) => jsonBody(200, {'identifier': 'usr-1', 'email': 'test@example.com'}),
    );
    // 2) check-otp avec query string fixe — on enregistre par préfixe.
    dioMock.mock(
      '/users/fo-agents/check-otp',
      (_) => jsonBody(200, {'id': 'usr-1', 'username': 'test@example.com'}),
    );
    // 3) reset-password
    dioMock.mock(
      '/users/fo-agents/reset-password',
      (_) => jsonBody(200, {'id': 'usr-1', 'username': 'test@example.com'}),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'init → check OTP → reset password : 3 endpoints tirés en séquence',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. Init reset password
      final initController = Get.put<InitResetPasswordController>(
        InitResetPasswordController(
          resetPasswordRepository: ResetPasswordRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // onInit crée emailController.
      await tester.pump();
      initController.emailController.text = 'test@example.com';
      initController.doInitResetPassword();
      // pumpAndSettle hang : `goToCheckOtp` ouvre un écran avec animation
      // Lottie qui ne settle jamais. Pump des frames sans avancer le temps.
      for (var i = 0; i < 30; i++) {
        await tester.pump();
      }

      final initCall = dioMock.calls.firstWhere(
        (c) => c.path.contains('init-reset-password'),
        orElse: () => throw StateError('init-reset-password not captured'),
      );
      expect(initCall.path,
          contains('/users/fo-agents/test@example.com/init-reset-password'));

      // 2. Check OTP
      final otpController = Get.put<OtpController>(
        OtpController(
          resetPasswordRepository: ResetPasswordRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      await tester.pump();
      otpController.usernameEntered.value = 'test@example.com';
      otpController.otpController.text = '123456';
      otpController.doCheckOtp();
      for (var i = 0; i < 30; i++) {
        await tester.pump();
      }

      final otpCall = dioMock.calls.firstWhere(
        (c) => c.path.contains('check-otp'),
        orElse: () => throw StateError('check-otp not captured'),
      );
      expect(otpCall.path, contains('email=test@example.com'));
      expect(otpCall.path, contains('otp=123456'));

      // 3. Reset password
      final resetController = Get.put<ResetPasswordController>(
        ResetPasswordController(
          resetPasswordRepository: ResetPasswordRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      await tester.pump();
      resetController.usernameEntered.value = 'test@example.com';
      resetController.otpEntered.value = '123456';
      resetController.newPasswordController.text = 'NewPass@1';
      resetController.confPasswordController.text = 'NewPass@1';
      resetController.doResetPassword();
      for (var i = 0; i < 30; i++) {
        await tester.pump();
      }

      final resetCall = dioMock.calls.firstWhere(
        (c) => c.path == '/users/fo-agents/reset-password',
        orElse: () => throw StateError('reset-password not captured'),
      );
      expect(resetCall.method, 'PATCH');
    },
  );
}
