import 'package:get/get.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/modules/splashscreen/data/repository/splashscreen_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';


class SplashscreenController extends GetxController {
  final SplashscreenRepository splashscreenRepository;
  final SigninRepository signinRepository;

  SplashscreenController({
    required this.splashscreenRepository,
    required this.signinRepository,
  });

  var userConnection = Signin().obs;
  var userInfo;

  var applyAnim = true.obs;

  @override
  void onReady() {
    getInitialView();
    super.onReady();
  }

  getInitialView() {
    Future.delayed(const Duration(seconds: 2), () {
      if (signinRepository.getUserSigninInfo() != null) {
        Get.offNamed(Routes.CUSTOM_HOME);
      } else {
        Get.offNamed(Routes.SIGNIN);
        //Get.offNamed(Routes.CUSTOM_HOME); //pour test
      }
    });
  }
}
