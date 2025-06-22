import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoisseBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() =>
        ParoisseController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        fenix: true,
    );
  }
}
