import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_donation_menu_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_mass_request_menu_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoisseDonationMenuBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ParoisseDonationMenuController(
      paroisseRepository: ParoisseRepository(ApiClientImpl()),
    ));
  }
}
