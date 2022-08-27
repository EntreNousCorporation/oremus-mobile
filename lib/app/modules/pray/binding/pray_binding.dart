import 'package:get/get.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';

class PrayBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrayController>(
      () {
        return PrayController();
      },
    );
  }
}
