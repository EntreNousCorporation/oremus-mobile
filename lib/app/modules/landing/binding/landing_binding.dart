import 'package:get/get.dart';
import 'package:oremusapp/app/modules/landing/controller/landing_controller.dart';

class LandingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandingController>(
      () {
        return LandingController();
      },
    );
  }
}
