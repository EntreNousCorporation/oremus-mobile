import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_confession_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_masse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_office_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoisseConfessionBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ParoisseConfessionController(
      paroisseRepository: ParoisseRepository(ApiClientImpl()),
    ));
  }
}
