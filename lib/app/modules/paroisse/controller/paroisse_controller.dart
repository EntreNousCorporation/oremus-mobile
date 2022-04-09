import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseController({
    required this.paroisseRepository,
  });

  var userConnection = SigninResponse().obs;

  RxList<ContentPlace> paroisses = RxList<ContentPlace>([]);

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var refreshController = RefreshController();

  @override
  void onInit() {
    //getUserInfo();
    super.onInit();
  }
  @override
  void onReady() {
    getParoisses();
    super.onReady();
  }

  initPullToRefresh() {
    refreshController = RefreshController(initialRefresh: false);
  }

  getParoisses() {
    isDataProcessing(true);

    log('request getParoisses');

    paroisseRepository.getParoisses().then((value) {
      log('response getParoisses => $value');
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
      debugPrint("error => ${error.toString()}");
    });
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
      debugPrint("error => ${error.toString()}");
    });
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      SigninResponse userConnected =
      SigninResponse.fromJson(jsonDecode(userInfo));
      userConnection.value = userConnected;
    }
  }
}
