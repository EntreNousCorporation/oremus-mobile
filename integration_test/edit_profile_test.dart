import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/profile/controller/edit_profile_controller.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : edit profile envoie `PUT /users/fo-agents/{userId}` avec
/// les champs du formulaire et stocke la réponse dans le profile cache.
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
      // /users/fo-agents/{userId} — la route est plus spécifique que
      // /users/fo-agents (signup), donc on l'enregistre AVANT.
      '/users/fo-agents/user-edit-001',
      (_) => jsonBody(200, {
        'identifier': 'user-edit-001',
        'firstname': 'Jeanne',
        'lastname': 'Dupont',
        'email': 'jeanne.dupont@example.com',
        'phone': '0102030405',
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
      id: 'user-edit-001',
      username: 'jean@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'updateProfile → PUT /users/fo-agents/{userId} avec le bon body',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<EditProfileController>(
        EditProfileController(
          profileRepository: ProfileRepository(ApiClientImpl()),
          signinRepository: SigninRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // En prod, `getArguments` appelle `updateUI(Profile)` qui crée les
      // TextEditingController. En test sans Get.arguments, on l'invoque
      // explicitement avec une Profile vide pour initialiser les controllers.
      controller.updateUI(Profile());
      await tester.pumpAndSettle();

      controller.firstnameController.text = 'Jeanne';
      controller.lastnameController.text = 'Dupont';
      controller.emailController.text = 'jeanne.dupont@example.com';
      controller.phoneController.text = '0102030405';

      controller.updateProfile();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final updateCall = dioMock.calls.firstWhere(
        (c) =>
            c.path == '/users/fo-agents/user-edit-001' && c.method == 'PUT',
        orElse: () =>
            throw StateError('PUT /users/fo-agents/{userId} not captured'),
      );
      // Le body est jsonEncoded en String avant d'être envoyé (cf. repo).
      final body = jsonDecode(updateCall.data as String) as Map<String, dynamic>;
      expect(body['firstname'], 'Jeanne');
      expect(body['lastname'], 'Dupont');
      expect(body['email'], 'jeanne.dupont@example.com');
      expect(body['phone'], '0102030405');
    },
  );
}
