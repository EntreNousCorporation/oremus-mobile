import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/modules/splashscreen/controller/splashscreen_controller.dart';
import 'package:oremusapp/app/modules/splashscreen/data/repository/splashscreen_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class SplashscreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashscreenController>(() {
      return SplashscreenController(
        splashscreenRepository: SplashscreenRepository(ApiClientImpl()),
        signinRepository: SigninRepository(ApiClientImpl()),
      );
    });
  }
}
