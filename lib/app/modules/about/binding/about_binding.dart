import 'package:get/get.dart';
import 'package:oremusapp/app/modules/about/controller/about_controller.dart';

class AboutBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      AboutController(),
    );
  }
}
