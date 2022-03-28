import 'package:get/get.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';

class CustomHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomHomeController>(
      () {
        return CustomHomeController();
      },
    );
  }
}
