import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : un user a liké des paroisses en mode anonyme (favoris
/// non-synchronisés en Hive). Au login, `synchronizeFavorites()` doit
/// pousser ces likes sur le serveur via `POST /favorites`.
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

    // Le home boot lance /places-of-worship — on le neutralise.
    dioMock.mock(
      '/places-of-worship/user-favorites',
      // Avant sync : aucun favori serveur. Après le POST, on s'attendrait à
      // y retrouver le 5 ; on garde la même réponse pour simplifier (la
      // partie qu'on assert ici est le POST, pas le re-fetch).
      (_) => jsonBody(200, {'content': <Map<String, dynamic>>[], 'last': true}),
    );
    dioMock.mock(
      '/places-of-worship',
      (_) => jsonBody(200, {'content': <Map<String, dynamic>>[], 'last': true}),
    );
    dioMock.mock(
      '/favorites',
      (_) => jsonBody(200, {'identifier': 999}),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  setUp(() {
    secureStorage.store
      ..clear()
      ..['auth.access_token'] = 'access-test'
      ..['auth.refresh_token'] = 'refresh-test';
    DB.saveUserSigninInfo(Signin(
      id: 'user-sync-001',
      username: 'sync@example.com',
    ));
    app.isUserConnected.value = true;

    // Favoris locaux non-sync : la paroisse 5 a été likée en mode anonyme.
    DB.saveUnsynchronizedFavorites([
      ContentPlace(identifier: 5, name: 'Paroisse Sainte Bakhita'),
    ]);
    // Force lastSyncUserId à null (pas '') pour que syncFavorites prenne
    // la branche "première sync" qui pousse vers /favorites. La méthode
    // `DB.clearLastSyncUserId()` met '' qui matche la branche "user
    // différent" et skippe le POST.
    DB.encryptedBox?.delete(DB.KEY_LAST_SYNC_USER_ID);
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'synchronizeFavorites pousse les favoris locaux vers /favorites',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final controller = Get.find<ParoisseController>();
      await controller.synchronizeFavorites();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Le POST /favorites a bien été tiré pour la paroisse non-sync.
      final postCalls = dioMock.calls.where(
        (c) => c.path == '/favorites' && c.method == 'POST',
      );
      expect(postCalls, hasLength(1),
          reason: 'un seul POST attendu (1 favori non-sync à pousser)');
      final body = postCalls.first.data as Map<String, dynamic>;
      expect(body['userId'], 'user-sync-001');
      expect(body['worshipPlaceId'], 5);

      // Le repo enregistre l'ID du dernier user synchronisé pour ne pas
      // re-pousser au login suivant du même user.
      expect(DB.getLastSyncUserId(), 'user-sync-001');
    },
  );
}
