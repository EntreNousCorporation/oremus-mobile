import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class ParoissePresbyTeamController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoissePresbyTeamController({
    required this.paroisseRepository,
  });

  var code = ''.obs;
  var paroisseSelected = ContentPlace().obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  RxList<PlaceUser> presbyTeams = RxList<PlaceUser>([]);

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  @override
  void onReady() {
    getPresbyTeams();
    super.onReady();
  }

  getArguments() {
    if (Get.arguments != null) {
      code.value = Get.arguments[0];
      paroisseSelected.value =
          ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
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

  getTypeMessage(String code) {
    switch (code) {
      case 'HM':
      case 'HC':
      case 'HB':
        return 'Horaires non disponible\nRéessayez plus tard svp';
      case 'AM':
      case 'EP':
        return 'Aucune information trouvée';
    }
  }

  getPresbyTeams() {

    log('request getPresbyTeams');

    var idParoisse = paroisseSelected.value.identifier;
    isDataProcessing(true);
    hasData(false);
    paroisseRepository.getPlaceOfWorshipUsers(idParoisse ?? -1).then((value) {
      isDataProcessing(false);
      if (value.isEmpty == false) {
        hasData(true);
        presbyTeams.value = value.where((element) => (element.type != null) && (element.type?.toLowerCase() == "vicar" || element.type?.toLowerCase() == "clergyman")).toList();
        presbyTeams.value.sort((a, b) => a.type!.compareTo(b.type!));
        log('${presbyTeams.length}');
      } else {
        hasData(false);
      }
    }, onError: (error) {
      var err = error as CustomException;
      isDataProcessing(false);
      hasData(false);
      debugPrint('${err.code}');
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: "Vous n’êtes pas autorisé à accéder à cette ressource",
        ).then((value) {
          //doLogout();
        });
      } else {
        showCustomDialog(
          Get.context!, message: err.message);
      }
      debugPrint("error => ${err.toString()}");
    });
  }

  getPresbyType(String code) {
    switch(code) {
      case 'vicar':
      case 'VICAR':
        return 'Vicaire';
      case 'clergyman':
      case 'CLERGYMAN':
        return 'Curé';
      default:
        return '';
    }
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
