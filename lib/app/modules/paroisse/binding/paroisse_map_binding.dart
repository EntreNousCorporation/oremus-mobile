import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_map_controller.dart';

class ParoisseMapBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ParoisseMapController());
  }
}
