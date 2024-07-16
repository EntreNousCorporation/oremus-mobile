import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/diocese_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DioceseController extends GetxController {
  final DioceseRepository dioceseRepository;

  DioceseController({
    required this.dioceseRepository,
  });

  var userConnection = Signin().obs;
  RxList<ContentPlace?> dioceses = RxList<ContentPlace?>([]);
  var unlockBackButton = true.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var refreshController = RefreshController();

  @override
  void onInit() {
    super.onInit();
    initPullToRefresh();
  }

  @override
  void onReady() {
    getDioceses();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  initPullToRefresh() {
    refreshController = RefreshController(initialRefresh: false);
  }

  getDioceses() {
    isDataProcessing(true);

    log('request getDioceses');

    dioceseRepository.getDioceses().then((value) {
      log('response getDioceses => $value');
      isDataProcessing(false);
      if (value.empty == false) {
        hasData(true);
        dioceses.value = value.contents ?? [];
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

    dioceseRepository.getDioceses().then((value) {
      refreshController.refreshCompleted();
      if (value.empty == false) {
        dioceses.value = value.contents ?? [];
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      debugPrint("error => ${error.toString()}");
    });
  }
}
