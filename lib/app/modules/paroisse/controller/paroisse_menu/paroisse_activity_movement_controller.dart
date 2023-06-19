import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  var refreshActivitiesController = RefreshController();
  var refreshMovementsController = RefreshController();

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

  @override
  void dispose() {
    refreshActivitiesController.dispose();
    refreshMovementsController.dispose();
    super.dispose();
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
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
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
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  onRefreshActivities() {
    log('request onRefreshActivities');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getActivities(idParoisse ?? -1).then((value) {
      refreshActivitiesController.refreshCompleted();
      if (value.isEmpty == false) {
        activities.value = value;
        log('${activities.length}');
      }
    }, onError: (error) {
      refreshActivitiesController.refreshCompleted();
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  onRefreshMouvements() {
    log('request onRefreshMouvements');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getMouvements(idParoisse ?? -1).then((value) {
      refreshMovementsController.refreshCompleted();
      if (value.isEmpty == false) {
        movements.value = value;
        log('${movements.length}');
      }
    }, onError: (error) {
      refreshMovementsController.refreshCompleted();
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
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
