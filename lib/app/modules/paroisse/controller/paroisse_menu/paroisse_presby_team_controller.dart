import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

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

  var refreshController = RefreshController();

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

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      code.value = Get.arguments[0];
      paroisseSelected.value =
          ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  goToReportProblem() {
    Get.toNamed(
      Routes.REPORT_PROBLEM,
      arguments: paroisseSelected.value.toJson(),
    );
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
        return 'Horaires non disponibles\nRéessayez plus tard svp';
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
      presbyTeams.value = value.where((element) => (element.type != null) && (element.type?.toLowerCase() == "vicar" || element.type?.toLowerCase() == "clergyman")).toList();
      if (presbyTeams.isNotEmpty == true) {
        hasData(true);
        presbyTeams.sort((a, b) => a.type!.compareTo(b.type!));
        log('${presbyTeams.length}');
      } else {
        hasData(false);
      }
    }, onError: (error) {
      var err = error as CustomException;
      isDataProcessing(false);
      hasData(false);
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: "Vous n’êtes pas autorisé à accéder à cette ressource",
        ).then((value) {
          //doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      } else {
        showNotification(message: err.message);
      }
      debugPrint("error => ${err.toString()}");
    });
  }

  onRefresh() {
    log('request onRefresh');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getPlaceOfWorshipUsers(idParoisse ?? -1).then((value) {
      refreshController.refreshCompleted();
      if (value.isEmpty == false) {
        presbyTeams.value = value.where((element) => (element.type != null) && (element.type?.toLowerCase() == "vicar" || element.type?.toLowerCase() == "clergyman")).toList();
        presbyTeams.sort((a, b) => a.type!.compareTo(b.type!));
        log('${presbyTeams.length}');
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: "Vous n’êtes pas autorisé à accéder à cette ressource",
        ).then((value) {
          //doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
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
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: paroisseSelected.toJson(),
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
