import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/reportproblem/controller/report_problem_controller.dart';
import 'package:oremusapp/app/modules/reportproblem/data/repository/report_problem_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : un user signale un problème → `POST /report-problems`
/// avec body `{description, email, worshipPlaceId, reportProblemTypeId}`.
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
    // /report-problem-types : appelé par doGetReportProblemTypes dans onInit.
    dioMock.mock(
      '/report-problem-types',
      (_) => jsonBody(200, [
        {
          'identifier': 7,
          'code': 'BUG',
          'name': {'fr': 'Bug', 'en': 'Bug'},
        },
      ]),
    );
    dioMock.mock(
      '/report-problems',
      (_) => jsonBody(201, <String, dynamic>{}),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'doSendReportProblem → POST /report-problems avec le bon body',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final controller = Get.put<ReportProblemController>(
        ReportProblemController(
          reportProblemRepository: ReportProblemRepository(ApiClientImpl()),
        ),
        permanent: true,
      );
      // onInit fait /report-problem-types ; on attend qu'il populate la liste.
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(controller.reportProblemTypes, isNotEmpty);

      controller.paroisseSelected.value = ContentPlace(identifier: 11);
      controller.reportProblemTypeSelected.value =
          controller.reportProblemTypes.first;
      controller.descriptionController.text = 'Application crash sur Android';
      controller.emailController.text = 'reporter@example.com';

      controller.doSendReportProblem();
      for (var i = 0; i < 30; i++) {
        await tester.pump();
      }

      final reportCall = dioMock.calls.firstWhere(
        (c) => c.path == '/report-problems' && c.method == 'POST',
        orElse: () => throw StateError('POST /report-problems not captured'),
      );
      final body = reportCall.data as Map<String, dynamic>;
      expect(body['description'], 'Application crash sur Android');
      expect(body['email'], 'reporter@example.com');
      expect(body['worshipPlaceId'], 11);
      expect(body['reportProblemTypeId'], 7);
    },
  );
}
