import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/services/notification_consent_manager.dart';
import 'package:oremusapp/app/commons/services/os_notification_service.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class SettingsController extends GetxController {

  SettingsController();

  var unlockBackButton = true.obs;
  final OSNotificationService _notificationService = OSNotificationService();
  var isLoading = false.obs;



  doCheckAndRequestConsent() async {
    await _notificationService.checkAndRequestConsent(Get.context!);
  }

  doDisableNotifications() async {
    await _notificationService.disableNotifications();
  }

  doSaveUserConsent() async {
    await NotificationConsentManager().saveUserConsent(false);
  }

  moveToFaq() {
    Get.toNamed(Routes.FAQ);
  }

  moveToAbout() {
    Get.toNamed(Routes.ABOUT);
  }

  moveToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
