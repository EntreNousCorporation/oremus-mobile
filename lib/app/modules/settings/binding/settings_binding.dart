import 'package:get/get.dart';
import 'package:oremusapp/app/modules/settings/controller/settings_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController());
  }
}
