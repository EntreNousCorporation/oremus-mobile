import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : app boot → splash → home → liste paroisses rendue.
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
    // Le mock adapter ne peut être posé qu'après bootstrap (DioUtil créé là).
    final dio = await DioUtil().getInstance();
    dio.httpClientAdapter = dioMock;

    // Réponses scriptées
    dioMock.mock('/places-of-worship', (_) => jsonBody(200, {
          'content': [
            {
              'identifier': 1,
              'name': 'Paroisse Sainte Bakhita',
              'massInfo': 'Messes : Dim 7h, 9h30',
              'address': {
                'city': 'Abidjan',
                'municipality': 'Cocody',
                'neighbourhood': '2 Plateaux',
              },
              'diocese': {
                'identifier': 1,
                'name': "Archidiocèse d'Abidjan",
              },
            },
          ],
          'last': true,
          'totalElements': 1,
        }));
    dioMock.mock('/devices', (_) => jsonBody(200, {}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('app boot → splash → home avec liste paroisses', (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();

    // Le splash a un Future.delayed de 3s avant de naviguer vers le home.
    await tester.pump(const Duration(seconds: 3));
    // pumpAndSettle pour laisser les bindings s'init et la liste se charger.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(
      find.text('Paroisse Sainte Bakhita'),
      findsWidgets,
      reason:
          'la liste de paroisses devrait être rendue après nav home + fetch API',
    );
  });
}
