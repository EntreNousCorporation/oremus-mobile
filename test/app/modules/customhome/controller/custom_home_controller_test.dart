import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/main.dart' as app;

class _MockSigninRepository extends Mock implements SigninRepository {}

class _MockParoisseRepository extends Mock implements ParoisseRepository {}

class _MockDrawerController extends Mock implements SimpleHiddenDrawerController {}

void main() {
  setUpAll(() async {
    Get.testMode = true;
    await LoggerService.initialize(showAppLogs: false);
  });

  setUp(() {
    Get.reset();
    Get.testMode = true;
    // État global initial : pas de session active.
    app.isUserConnected.value = false;
    app.requestMassWithoutWorship.value = false;
    app.donationWithoutWorship.value = false;
  });

  CustomHomeController buildController() {
    return CustomHomeController(
      signinRepository: _MockSigninRepository(),
      paroisseRepository: _MockParoisseRepository(),
    );
  }

  group('CustomHomeController.initMenus', () {
    test('utilisateur déconnecté → entrée SIGNIN visible dans la liste', () {
      app.isUserConnected.value = false;
      final controller = buildController();
      controller.initMenus();

      final signinEntry = controller.menus
          .where((m) => m.code == AppConstants.SIGNIN)
          .toList();
      expect(signinEntry, hasLength(1));
      expect(signinEntry.first.libelle, 'Connexion');
    });

    test('utilisateur connecté → entrée SIGNIN absente', () {
      app.isUserConnected.value = true;
      final controller = buildController();
      controller.initMenus();

      final signinEntry = controller.menus
          .where((m) => m.code == AppConstants.SIGNIN)
          .toList();
      expect(signinEntry, isEmpty,
          reason: 'la "Connexion" doit être masquée quand on est déjà loggé');
    });

    test('menus toujours visibles indépendamment de la session', () {
      app.isUserConnected.value = true;
      final controller = buildController();
      controller.initMenus();

      final codes = controller.menus.map((m) => m.code).toSet();
      expect(codes, contains(AppConstants.HOME));
      expect(codes, contains(AppConstants.PRAY));
      expect(codes, contains(AppConstants.ROSAIRE));
      expect(codes, contains(AppConstants.LIFE_PLAN));
      expect(codes, contains(AppConstants.SHARE_APP));
      expect(codes, contains(AppConstants.SETTINGS));
    });
  });

  group('CustomHomeController.doRedirection — flags drawer', () {
    test('REQUEST_MASS_WITHOUT_WORSHIP → flags request + donation = true', () {
      final controller = buildController();
      controller.initMenus();
      final drawer = _MockDrawerController();
      when(() => drawer.setSelectedMenuPosition(any())).thenReturn(null);

      final massIndex = controller.menus
          .indexWhere((m) => m.code == AppConstants.REQUEST_MASS_WITHOUT_WORSHIP);
      expect(massIndex, isNonNegative);

      controller.doRedirection(massIndex, drawer);

      expect(app.requestMassWithoutWorship.value, true);
      expect(app.donationWithoutWorship.value, true);
      expect(controller.selectedIndex.value, massIndex);
      verify(() => drawer.setSelectedMenuPosition(massIndex)).called(1);
    });

    test('DONATION_WITHOUT_WORSHIP → flags request + donation = true', () {
      final controller = buildController();
      controller.initMenus();
      final drawer = _MockDrawerController();
      when(() => drawer.setSelectedMenuPosition(any())).thenReturn(null);

      final donIndex = controller.menus
          .indexWhere((m) => m.code == AppConstants.DONATION_WITHOUT_WORSHIP);
      expect(donIndex, isNonNegative);

      controller.doRedirection(donIndex, drawer);

      expect(app.requestMassWithoutWorship.value, true);
      expect(app.donationWithoutWorship.value, true);
    });

    test('SHARE_APP → flags remis à false (pas de routage drawer)', () {
      app.requestMassWithoutWorship.value = true;
      app.donationWithoutWorship.value = true;
      final controller = buildController();
      controller.initMenus();
      final drawer = _MockDrawerController();

      final shareIndex = controller.menus
          .indexWhere((m) => m.code == AppConstants.SHARE_APP);
      expect(shareIndex, isNonNegative);

      // SHARE_APP appelle aussi `doShareApp()` → on ne le déclenche pas
      // (besoin de plugins). On vérifie juste les flags. Pour ça, on
      // s'attend à ce que la méthode lance le partage et plante côté
      // plugin ; on capture la levée si elle survient et on assert
      // quand même les flags car ils sont set AVANT doShareApp().
      try {
        controller.doRedirection(shareIndex, drawer);
      } catch (_) {
        // share plugin non disponible en unit test : OK
      }

      expect(app.requestMassWithoutWorship.value, false);
      expect(app.donationWithoutWorship.value, false);
      // SHARE_APP ne doit pas changer la position du drawer.
      verifyNever(() => drawer.setSelectedMenuPosition(any()));
    });

    test('autre menu (PRAY) → flags remis à false + drawer.setSelected', () {
      app.requestMassWithoutWorship.value = true;
      app.donationWithoutWorship.value = true;
      final controller = buildController();
      controller.initMenus();
      final drawer = _MockDrawerController();
      when(() => drawer.setSelectedMenuPosition(any())).thenReturn(null);

      final prayIndex = controller.menus
          .indexWhere((m) => m.code == AppConstants.PRAY);
      expect(prayIndex, isNonNegative);

      controller.doRedirection(prayIndex, drawer);

      expect(app.requestMassWithoutWorship.value, false);
      expect(app.donationWithoutWorship.value, false);
      verify(() => drawer.setSelectedMenuPosition(prayIndex)).called(1);
    });
  });
}
