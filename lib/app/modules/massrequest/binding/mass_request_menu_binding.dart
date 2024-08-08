import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_controller.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_menu_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestMenuBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MassRequestMenuController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
    );
  }
}
