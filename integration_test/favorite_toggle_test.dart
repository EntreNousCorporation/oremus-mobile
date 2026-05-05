import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/dio_mock_adapter.dart';
import 'test_helpers/secure_storage_mock.dart';

/// Happy path : un user connecté tape le like d'une paroisse →
/// `POST /favorites` est tiré, et l'état local de la paroisse passe à
/// `isFavorite = true`.
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
      (_) => jsonBody(200, {
        'content': [
          {
            'identifier': 1,
            'name': 'Paroisse Sainte Bakhita',
            'isUserFavorite': false,
            'address': {'city': 'Abidjan'},
          },
        ],
        'last': true,
        'totalElements': 1,
      }),
    );
    dioMock.mock(
      '/favorites',
      (_) => jsonBody(200, {'identifier': 99}),
    );
    dioMock.mock('/devices', (_) => jsonBody(200, <String, dynamic>{}));
  });

  setUp(() {
    secureStorage.store
      ..clear()
      ..['auth.access_token'] = 'access-test'
      ..['auth.refresh_token'] = 'refresh-test';
    DB.saveUserSigninInfo(Signin(
      id: 'user-test-fav',
      username: 'fav@example.com',
    ));
    app.isUserConnected.value = true;
  });

  tearDownAll(() {
    secureStorage.uninstall();
  });

  testWidgets(
    'tap like (user connecté) → POST /favorites + isFavorite local = true',
    (tester) async {
      await tester.pumpWidget(app.OremusApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final controller = Get.find<ParoisseController>();
      final paroisse = controller.paroisses.first!;
      expect(paroisse.identifier, 1);
      expect(paroisse.isFavorite, false,
          reason: 'pré-condition : la paroisse n\'est pas encore likée');

      // Action : équivalent du tap sur le coeur (LikeButton).
      // `onLikeButtonTapped(false, ...)` → saveFavorite → POST /favorites.
      final newState =
          await controller.onLikeButtonTapped(false, paroisse);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(newState, true);
      expect(paroisse.isFavorite, true,
          reason: 'l\'état local doit refléter le like immédiatement');

      // Le POST /favorites a bien été tiré avec userId + worshipPlaceId.
      final favCall = dioMock.calls.firstWhere(
        (c) => c.path == '/favorites' && c.method == 'POST',
        orElse: () => throw StateError('POST /favorites not captured'),
      );
      final body = favCall.data as Map<String, dynamic>;
      expect(body['userId'], 'user-test-fav');
      expect(body['worshipPlaceId'], 1);
    },
  );
}
