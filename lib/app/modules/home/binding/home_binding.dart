import 'package:get/get.dart';
import 'package:oremusapp/app/modules/home/controller/home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () {
        return HomeController();
      },
    );
  }
}
