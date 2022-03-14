import 'package:get/get.dart';
import 'package:oremusapp/app/modules/home/controller/home_controller.dart';
import 'package:oremusapp/app/modules/home/data/repository/home_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () {
        return HomeController(
          homeRepository: HomeRepository(ApiClientImpl()),
        );
      },
    );
  }
}
