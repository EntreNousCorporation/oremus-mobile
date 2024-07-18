import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/modules/splashscreen/data/repository/splashscreen_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';


class SplashscreenController extends GetxController {
  final SplashscreenRepository splashscreenRepository;
  final SigninRepository signinRepository;

  SplashscreenController({
    required this.splashscreenRepository,
    required this.signinRepository,
  });

  var applyAnim = true.obs;
  final GlobalKey<AnimatorWidgetState> basicIconAnimation = GlobalKey<AnimatorWidgetState>();
  final GlobalKey<AnimatorWidgetState> basicTextAnimation = GlobalKey<AnimatorWidgetState>();

  var currentLanguage = ''.obs;

  @override
  void onReady() {
    currentLanguage.value = (DB.getCurrentLanguage().isNotEmpty == true ? DB.getCurrentLanguage() : Get.deviceLocale?.languageCode) ?? 'fr';
    updateLocale(currentLanguage.value);
    log('getCurrentLanguage => ${DB.getCurrentLanguage().runtimeType}');

    hasUserConnected();
    getInitialView();
    super.onReady();
  }

  bool hasUserConnected() {
    log('hasUserConnected id => ${DB.getUserSigninInfo()?.id}');
    isUserConnected.value = DB.getUserSigninInfo() != null;
    return isUserConnected.value;
  }

  updateLocale(String code) {
    log('selected language => $code');
    Get.updateLocale(Locale(code, code.toUpperCase()));
    DB.setCurrentLanguage(code);
    update();
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
      Get.offNamed(Routes.CUSTOM_HOME);
    });
  }
}
