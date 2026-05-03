import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class AuthGate {
  static bool _handlingUnauthorized = false;

  static void handleUnauthorized() {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;

    OremusLogger.warning('AuthGate: 401 received, clearing session');

    try {
      DB.saveData(AppConstants.KEY_TOKEN, null);
      DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
      DB.clearAllUserSpecificData();
      isUserConnected.value = false;

      Get.deleteAll(force: false);

      if (Get.currentRoute != Routes.SIGNIN) {
        Get.offAllNamed(Routes.SIGNIN);
      }
    } catch (e, st) {
      OremusLogger.error('AuthGate: error during logout: $e\n$st');
    }
  }

  static void resetAfterLogin() {
    _handlingUnauthorized = false;
  }
}
