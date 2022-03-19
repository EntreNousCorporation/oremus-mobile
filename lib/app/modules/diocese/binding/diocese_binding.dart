import 'package:get/get.dart';
import 'package:oremusapp/app/modules/diocese/controller/diocese_controller.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/diocese_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DioceseBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DioceseController>(
      () {
        return DioceseController(
          dioceseRepository: DioceseRepository(ApiClientImpl()),
        );
      },
    );
  }
}
