import 'package:get/get.dart';
import 'package:oremusapp/app/modules/faq/controller/faq_controller.dart';

class FaqBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(FaqController());
  }
}
