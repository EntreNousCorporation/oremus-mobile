import 'package:get/get.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/multi_activity_form_controller.dart';

class LifePlanFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MultiActivityFormController>(() => MultiActivityFormController());
  }
}