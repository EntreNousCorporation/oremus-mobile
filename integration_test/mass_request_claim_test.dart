import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart' show MassRequestResponse;
// `TypeData` est ambigu (donation et massrequest la déclarent) ; on prend
// celle de massrequest, qui est ce que `claimTypes` exporte via le repo.
import 'package:oremusapp/app/modules/massrequestclaim/controller/mass_request_claim_controller.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : un user soumet une réclamation sur une demande de messe.
/// `MassRequestClaimController.doSendClaim` →
/// `POST /claims` avec body `{massRequest, description, typeOfClaim}`.
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
    // /types-of-claim : appelé par doGetClaimTypes dans onInit du controller.
    dioMock.mock(
      '/types-of-claim',
      (_) => jsonBody(200, [
        {'code': 'NOT_RECEIVED', 'name': {'fr': 'Pas reçue', 'en': 'Not received'}},
      ]),
    );
    dioMock.mock(
      '/claims',
      // ClaimData.fromJson parse `status` comme TypeOfClaim (objet), pas String.
      (_) => jsonBody(201, {
        'identifier': 555,
        'status': {'code': 'PENDING'},
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
      id: 'user-claim-001',
      username: 'claim@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'doSendClaim → POST /claims avec mass request id + type + description',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<MassRequestClaimController>(
        MassRequestClaimController(
          massRequestClaimRepository:
              MassRequestClaimRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // onInit fait /types-of-claim ; on attend qu'il populate la liste.
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(controller.claimTypes, isNotEmpty);

      controller.massRequestSelected.value =
          MassRequestResponse(identifier: 42);
      controller.claimTypeSelected.value = controller.claimTypes.first;
      controller.claimDescription.text = 'La messe n\'a pas été célébrée';

      controller.doSendClaim();
      for (var i = 0; i < 30; i++) {
        await tester.pump();
      }

      final claimCall = dioMock.calls.firstWhere(
        (c) => c.path == '/claims' && c.method == 'POST',
        orElse: () => throw StateError('POST /claims not captured'),
      );
      final body = claimCall.data as Map<String, dynamic>;
      expect(body['massRequest'], 42);
      expect(body['typeOfClaim'], 'NOT_RECEIVED');
      expect(body['description'], 'La messe n\'a pas été célébrée');
    },
  );
}
