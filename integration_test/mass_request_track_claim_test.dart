import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `MassRequestTrackClaimController.doGetClaims` charge la
/// liste des réclamations de l'utilisateur depuis `/users/claims`.
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
      '/users/claims',
      (_) => jsonBody(200, {
        'content': [
          {
            'identifier': 100,
            'description': 'Demande non célébrée',
            'status': {'code': 'PENDING'},
          },
          {
            'identifier': 101,
            'description': 'Date erronée',
            'status': {'code': 'RESOLVED'},
          },
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
      id: 'user-track-001',
      username: 'track@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'doGetClaims → /users/claims chargé et liste rendue',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<MassRequestTrackClaimController>(
        MassRequestTrackClaimController(
          massRequestClaimRepository:
              MassRequestClaimRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );

      controller.doGetClaims();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(controller.claims, hasLength(2));
      expect(controller.claims[0]?.identifier, 100);
      expect(controller.hasData.value, true);

      final claimsCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/users/claims'),
        orElse: () => throw StateError('GET /users/claims not captured'),
      );
      expect(claimsCall.method, 'GET');
      expect(claimsCall.path, contains('sort=createdAt,desc'));
    },
  );
}
