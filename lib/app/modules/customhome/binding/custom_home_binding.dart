import 'package:get/get.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class CustomHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomHomeController>(
      () {
        return CustomHomeController(
          signinRepository: SigninRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        );
      },
      fenix: true,
    );
  }
}
