import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/splashscreen/data/repository/splashscreen_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';


class SplashscreenController extends GetxController {
  final SplashscreenRepository splashscreenRepository;

  SplashscreenController({required this.splashscreenRepository});

  var userInfo;

  var applyAnim = true.obs;

  @override
  void onInit() {
    log('onInit');
    getUserInfo();
    super.onInit();
  }

  @override
  void onReady() {
    log('onReady');
    getInitialView();
    super.onReady();
  }

  getInitialView() {
    Future.delayed(const Duration(seconds: 3), () {
      if (userInfo != null) {
        Get.offNamed(Routes.HOME);
      } else {
        Get.offNamed(Routes.SIGNIN);
      }
    });
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {

    }
  }
}
