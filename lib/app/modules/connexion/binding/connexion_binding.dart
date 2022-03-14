import 'package:get/get.dart';
import 'package:oremusapp/app/modules/connexion/controller/connexion_controller.dart';
import 'package:oremusapp/app/modules/connexion/data/repository/connexion_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ConnexionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnexionController>(() {
      return ConnexionController(
        connexionRepository: ConnexionRepository(ApiClientImpl())
      );
    });
  }
}