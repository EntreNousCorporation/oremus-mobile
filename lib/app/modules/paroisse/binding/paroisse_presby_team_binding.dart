import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_presby_team_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoissePresbyTeamBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        ParoissePresbyTeamController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ));
  }
}
