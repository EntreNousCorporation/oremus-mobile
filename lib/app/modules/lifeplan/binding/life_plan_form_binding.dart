import 'package:get/get.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_form_controller.dart';

class LifePlanFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LifePlanFormController>(LifePlanFormController());
  }
}
