import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : recherche par nom (`searchCriteria.name`) → la requête
/// `/places-of-worship` part avec le paramètre `name=` et la liste rendue
/// reflète le filtre serveur.
///
/// Le search "simple" (champ texte du home, endpoint `/worship-places` sur
/// le `customBaseUrl`) n'est pas couvert ici car il utilise un Dio séparé
/// via `DioUtil(forceNew: true)` qui contourne notre mock adapter posé sur
/// la singleton. Il faudrait ajouter un seam dans `DioUtil` pour le tester
/// — sortie de scope.
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

    // Le mock retourne des résultats différents selon `name=`. Sans filtre,
    // on renvoie 2 paroisses ; avec `name=Bakhita`, seulement Bakhita.
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
      final nameFilter = options.uri.queryParameters['name'];
      final filtered = nameFilter != null && nameFilter.contains('Bakhita')
          ? [bakhita]
          : [bakhita, joseph];
      return jsonBody(200, {
        'content': filtered,
        'last': true,
        'totalElements': filtered.length,
      });
    });
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets('searchCriteria.name → filtre serveur reflété dans la liste',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // État initial : 2 paroisses rendues.
    expect(find.text('Paroisse Sainte Bakhita'), findsWidgets);
    expect(find.text('Paroisse Saint Joseph'), findsWidgets);

    // Lance une recherche avancée par nom. `getParoisses()` réécrit
    // searchCriteria.name à partir de `searchController.text.trim()`, donc
    // c'est ce champ qu'on alimente.
    final controller = Get.find<ParoisseController>();
    controller.searchController.text = 'Bakhita';
    controller.getParoisses();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Saint Joseph n'est plus rendu, Bakhita oui.
    expect(find.text('Paroisse Sainte Bakhita'), findsWidgets);
    expect(find.text('Paroisse Saint Joseph'), findsNothing);

    // La requête filtrée a bien embarqué le nom dans le query string.
    final filteredCall = dioMock.calls.lastWhere(
      (c) => c.path.startsWith('/places-of-worship'),
    );
    expect(filteredCall.path, contains('name=Bakhita'));
  });
}
