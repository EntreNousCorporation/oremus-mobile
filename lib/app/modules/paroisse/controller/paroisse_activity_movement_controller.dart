import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class ParoisseActivityMovementController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseActivityMovementController({
    required this.paroisseRepository,
  });

  var code = ''.obs;
  var paroisseSelected = ContentPlace().obs;
  var indexDaySelected = 0.obs;
  var openingTime = OpeningTime().obs;

  var isActivityDataProcessing = false.obs;
  var hasActivityData = false.obs;

  var isMovementDataProcessing = false.obs;
  var hasMovementData = false.obs;

  RxList<String> menusTab = RxList<String>([]);

  RxList<ActivityResponse> activities = RxList<ActivityResponse>([]);
  RxList<MovementResponse> movements = RxList<MovementResponse>([]);

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  @override
  void onReady() {
    getMovements();
    getActivities();
    super.onReady();
  }

  getArguments() {
    if (Get.arguments != null) {
      code.value = Get.arguments[0];
      paroisseSelected.value = ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  initMenus() {
    menusTab.value = [
      'Activités',
      'Mouvements'
    ];
  }

  getTypeTitle(String code) {
    switch (code) {
      case 'HM':
        return 'Horaires des messes';
      case 'HC':
        return 'Horaires des confessions';
      case 'HB':
        return 'Horaires des bureaux';
      case 'AM':
        return 'Activités & mouvements';
      case 'EP':
        return 'Equipe presbytérale';
    }
  }

  getMovements() {

    log('request getMovements');

    var idParoisse = paroisseSelected.value.identifier;
    isMovementDataProcessing(true);
    hasMovementData(false);
    paroisseRepository.getMouvements(idParoisse ?? -1).then((value) {
      isMovementDataProcessing(false);
      if (value.isEmpty == false) {
        hasMovementData(true);
        movements.value = value;
        log('${movements.length}');
      } else {
        hasMovementData(false);
      }
    }, onError: (error) {
      isMovementDataProcessing(false);
      hasMovementData(false);
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

  getActivities() {

    log('request getActivities');

    var idParoisse = paroisseSelected.value.identifier;
    isActivityDataProcessing(true);
    hasActivityData(false);
    paroisseRepository.getActivities(idParoisse ?? -1).then((value) {
      isActivityDataProcessing(false);
      if (value.isEmpty == false) {
        hasActivityData(true);
        activities.value = value;
        log('${activities.length}');
      } else {
        hasActivityData(false);
      }
    }, onError: (error) {
      isActivityDataProcessing(false);
      hasActivityData(false);
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

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: jsonEncode(paroisseSelected.value.toJson()),
    );
  }
}
