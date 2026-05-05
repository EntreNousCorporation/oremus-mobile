import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : pagination de la liste paroisses.
/// Page 0 retourne 1 item avec `last: false` → controller `page` passe à 1.
/// `onLoading()` (déclenché par le scroll-to-load en prod) fait `page=1`,
/// la 2ème réponse vient s'ajouter à la liste rendue.
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

    final bakhita = {
      'identifier': 1,
      'name': 'Paroisse Sainte Bakhita',
      'address': {'city': 'Abidjan'},
    };
    final joseph = {
      'identifier': 2,
      'name': 'Paroisse Saint Joseph',
      'address': {'city': 'Abidjan'},
    };
    dioMock.mock('/places-of-worship', (options) {
      final page = options.uri.queryParameters['page'];
      if (page == '1') {
        return jsonBody(200, {
          'content': [joseph],
          'last': true,
          'totalElements': 2,
        });
      }
      // page 0 ou défaut
      return jsonBody(200, {
        'content': [bakhita],
        'last': false,
        'totalElements': 2,
      });
    });
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('onLoading() ajoute la page suivante à la liste rendue',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // État initial : page 0 chargée, 1 item rendu, page incrémentée à 1.
    final controller = Get.find<ParoisseController>();
    expect(controller.paroisses, hasLength(1));
    expect(controller.page.value, 1);
    expect(find.text('Paroisse Sainte Bakhita'), findsWidgets);
    expect(find.text('Paroisse Saint Joseph'), findsNothing);

    // Action : équivalent du scroll-to-load.
    controller.onLoading();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // La page 1 a été ajoutée à la liste.
    expect(controller.paroisses, hasLength(2));
    expect(find.text('Paroisse Sainte Bakhita'), findsWidgets);
    expect(find.text('Paroisse Saint Joseph'), findsWidgets);

    // La 2ème requête a bien embarqué `page=1`.
    final page1Call = dioMock.calls.lastWhere(
      (c) => c.path.startsWith('/places-of-worship'),
    );
    expect(page1Call.path, contains('page=1'));
  });
}
