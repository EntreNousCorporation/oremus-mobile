import 'package:get/get.dart';
import 'package:oremusapp/app/modules/formation/controller/formation_controller.dart';
import 'package:oremusapp/app/modules/formation/data/repository/formation_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FormationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormationController>(
      () {
        return FormationController(
          formationRepository: FormationRepository(ApiClientImpl()),
        );
      },
    );
  }
}
