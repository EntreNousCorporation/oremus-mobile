import 'package:get/get.dart';
import 'package:oremusapp/app/modules/service/controller/service_controller.dart';
import 'package:oremusapp/app/modules/service/data/repository/service_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ServiceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceController>(
      () {
        return ServiceController(
          serviceRepository: ServiceRepository(ApiClientImpl()),
        );
      },
    );
  }
}
