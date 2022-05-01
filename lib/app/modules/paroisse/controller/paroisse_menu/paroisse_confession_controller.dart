import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class ParoisseConfessionController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseConfessionController({
    required this.paroisseRepository,
  });

  var code = ''.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var openingTime = OpeningTime().obs;

  RxList<LiturgicalCelebrationResponse> confessions = RxList<LiturgicalCelebrationResponse>([]);

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  @override
  void onReady() {
    getConfessionTimes();
    super.onReady();
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

  getConfessionTimes() {
    log('request getLiturgicalCelebrations');

    var idParoisse = paroisseSelected.value.identifier;
    isDataProcessing(true);
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      isDataProcessing(false);
      if (value.isEmpty == false) {
        confessions.value = value
            .where((element) => element.type?.code == 'CONFESSION')
            .toList();
        log('confessions => ${confessions.length}');
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
