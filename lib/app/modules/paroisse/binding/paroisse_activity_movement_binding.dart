import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoisseActivityMovementBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ParoisseActivityMovementController(
      paroisseRepository: ParoisseRepository(ApiClientImpl()),
    ));
  }
}
