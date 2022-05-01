import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
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
  final GlobalKey<AnimatorWidgetState> basicIconAnimation = GlobalKey<AnimatorWidgetState>();
  final GlobalKey<AnimatorWidgetState> basicTextAnimation = GlobalKey<AnimatorWidgetState>();

  @override
  void onReady() {
    getInitialView();
    super.onReady();
  }

  applyAnimation() {
    if (applyAnim.isTrue) {
      //basicIconAnimation.currentState?.animator?.loop();
      return AnimationPlayStates.Loop;
    }
    return AnimationPlayStates.None;
  }

  getInitialView() {
    Future.delayed(const Duration(seconds: 3), () {
      if (signinRepository.getUserSigninInfo() != null) {
        Get.offNamed(Routes.CUSTOM_HOME);
      } else {
        Get.offNamed(Routes.SIGNIN);
        //Get.offNamed(Routes.CUSTOM_HOME); //pour test
      }
    });
  }
}
