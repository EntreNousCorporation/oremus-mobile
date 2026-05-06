import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/editpassword/controller/edit_password_controller.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : un user connecté change son mot de passe →
/// `POST /users/change-password` avec le body username + oldPassword + newPassword.
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
      '/users/change-password',
      (_) => jsonBody(200, {'identifier': 'usr-pwd', 'username': 'edit@example.com'}),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  setUp(() {
    secureStorage.store
      ..clear()
      ..['auth.access_token'] = 'access-test'
      ..['auth.refresh_token'] = 'refresh-test';
    DB.saveUserSigninInfo(Signin(
      id: 'usr-pwd',
      username: 'edit@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'updatePassword → POST /users/change-password avec le bon body',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<EditPasswordController>(
        EditPasswordController(
          profileRepository: ProfileRepository(ApiClientImpl()),
          signinRepository: SigninRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      await tester.pump();
      controller.passwordController.text = 'OldPass@1';
      controller.newPasswordController.text = 'NewPass@2';
      controller.confPasswordController.text = 'NewPass@2';

      controller.updatePassword();
      // pumpAndSettle peut hang si une animation tourne ; on pump des frames.
      for (var i = 0; i < 30; i++) {
        await tester.pump();
      }

      final pwdCall = dioMock.calls.firstWhere(
        (c) => c.path == '/users/change-password' && c.method == 'POST',
        orElse: () => throw StateError('POST /users/change-password not captured'),
      );
      // Body est jsonEncode(...) en String avant l'envoi (cf. repo).
      final body = jsonDecode(pwdCall.data as String) as Map<String, dynamic>;
      expect(body['username'], 'edit@example.com');
      expect(body['oldPassword'], 'OldPass@1');
      expect(body['newPassword'], 'NewPass@2');
    },
  );
}
