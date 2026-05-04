import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/services/token_store.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class AuthGate {
  static bool _handlingUnauthorized = false;

  // Logout local déclenché par l'intercepteur sur 401 non récupérable.
  // Pas d'appel backend ici : la session est déjà invalide côté serveur,
  // et passer par /auth/logout repasserait dans l'intercepteur (boucle).
  static Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    OremusLogger.warning('AuthGate: 401 reçu, fermeture de la session');

    try {
      await TokenStore.clear();
      DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
      DB.clearAllUserSpecificData();
      isUserConnected.value = false;

      Get.deleteAll(force: false);

      if (Get.currentRoute != Routes.SIGNIN) {
        Get.offAllNamed(Routes.SIGNIN);
      }
    } catch (e, st) {
      OremusLogger.error('AuthGate: erreur pendant le logout: $e\n$st');
    }
  }

  static void resetAfterLogin() {
    _handlingUnauthorized = false;
  }
}
