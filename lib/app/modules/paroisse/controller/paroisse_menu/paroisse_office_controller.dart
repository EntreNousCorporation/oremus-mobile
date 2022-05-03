import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseOfficeController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseOfficeController({
    required this.paroisseRepository,
  });

  var code = ''.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var openingTime = OpeningTime().obs;

  RxList<LiturgicalCelebrationResponse> offices =
      RxList<LiturgicalCelebrationResponse>([]);

  var refreshController = RefreshController();

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  @override
  void onReady() {
    getOfficeTimes();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      code.value = Get.arguments[0];
      paroisseSelected.value = ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('paroisseSelected ==> ${paroisseSelected.value.identifier}');
    }
  }

  getTime(String timeToConverted) {
    var hour = timeToConverted.split(':').first;
    var minutes = timeToConverted.split(':')[1];
    return '${hour}h$minutes';
  }

  getOfficeTimes() {
    hideKeyboard();

    log('request getOfficeTimes');

    var idParoisse = paroisseSelected.value.identifier ?? -1;
    isDataProcessing(true);
    paroisseRepository.getOfficeTimes(idParoisse).then((value) {
      isDataProcessing(false);
      offices.value = value.where((element) => element.type?.code == 'OFFICE').toList();
      if (offices.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  onRefresh() {
    log('request onRefresh');

    var idParoisse = paroisseSelected.value.identifier ?? -1;
    paroisseRepository.getOfficeTimes(idParoisse).then((value) {
      refreshController.refreshCompleted();
      if (value.isNotEmpty == true) {
        offices.value = value.where((element) => element.type?.code == 'OFFICE').toList();
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
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

  saveFavorite(ContentPlace paroisse, bool state) {
    log('saveFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.addFavorite(paroisse);
    //showMessageFavorite(state);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    log('removeFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.deleteFavorite(paroisse);
    //showMessageFavorite(state);
  }
}
