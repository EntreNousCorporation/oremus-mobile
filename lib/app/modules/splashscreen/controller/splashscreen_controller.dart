import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/splashscreen/data/repository/splashscreen_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';


class SplashscreenController extends GetxController {
  final SplashscreenRepository splashscreenRepository;

  SplashscreenController({required this.splashscreenRepository});

  var userConnection = Signin().obs;
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
    Future.delayed(const Duration(seconds: 2), () {
      if (userInfo != null) {
        Get.offNamed(Routes.HOME);
      } else {
        Get.offNamed(Routes.SIGNIN);
      }
    });
  }

  getUserInfo() {
    userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      Signin userConnected =
      Signin.fromJson(jsonDecode(userInfo));
      userConnection.value = userConnected;
    }
  }
}
