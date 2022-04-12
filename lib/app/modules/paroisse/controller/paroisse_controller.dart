import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseController({
    required this.paroisseRepository,
  });

  var userConnection = Signin().obs;

  RxList<ContentPlace> paroisses = RxList<ContentPlace>([]);

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var refreshController = RefreshController();

  @override
  void onInit() {
    getUserInfo();
    super.onInit();
  }
  @override
  void onReady() {
    getParoisses();
    super.onReady();
  }

  getParoisses() {
    isDataProcessing(true);

    log('request getParoisses');

    paroisseRepository.getParoisses().then((value) {
      isDataProcessing(false);
      if (value.empty == false) {
        hasData(true);
        paroisses.value = value.content ?? [];
      } else {
        hasData(false);
      }
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
            Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  doLogout() {
    encryptedBox.put(AppConstants.USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  onRefresh() {

    log('request onRefresh');

    paroisseRepository.getParoisses().then((value) {
      refreshController.refreshCompleted();
      if (value.empty == false) {
        paroisses.value = value.content ?? [];
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    log('==> $userInfo');
    if (userInfo != null) {
      Signin userConnected =
      Signin.fromJson(jsonDecode(userInfo));
      userConnection.value = userConnected;
      log('==> ${userConnection.value.toJson()}');
    }
  }
}
