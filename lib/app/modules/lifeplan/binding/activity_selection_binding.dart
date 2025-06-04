import 'package:get/get.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/activity_selection_controller.dart';

class ActivitySelectionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivitySelectionController>(() => ActivitySelectionController());
  }
}