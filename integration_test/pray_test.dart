import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';
import 'package:oremusapp/app/modules/pray/data/repository/pray_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : `PrayController` charge les prières spécifiques
/// (`/specific-prayers`) et coutumières (`/customary-prayers`).
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
    // Prayer.fromJson parse `title` et `content` comme TranslateContent (objets {fr, en}).
    dioMock.mock(
      '/specific-prayers',
      (_) => jsonBody(200, [
        {
          'identifier': 1,
          'title': {'fr': 'Notre Père', 'en': 'Our Father'},
          'content': {'fr': '<p>Notre Père...</p>', 'en': '<p>Our Father...</p>'},
        },
      ]),
    );
    dioMock.mock(
      '/customary-prayers',
      (_) => jsonBody(200, [
        {
          'identifier': 10,
          'title': {'fr': 'Je vous salue Marie', 'en': 'Hail Mary'},
          'content': {'fr': '<p>...</p>', 'en': '<p>...</p>'},
        },
      ]),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'PrayController charge /specific-prayers et /customary-prayers',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      Get.put<PrayController>(
        PrayController(prayRepository: PrayRepository(ApiClientImpl())),
        permanent: true,
      );
      // onInit déclenche les chargements ; on laisse settle.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final specificCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/specific-prayers'),
        orElse: () => throw StateError('GET /specific-prayers not captured'),
      );
      expect(specificCall.method, 'GET');

      final customaryCall = dioMock.calls.firstWhere(
        (c) => c.path.startsWith('/customary-prayers'),
        orElse: () => throw StateError('GET /customary-prayers not captured'),
      );
      expect(customaryCall.method, 'GET');
    },
  );
}
