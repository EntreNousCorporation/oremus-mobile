import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class ParoisseContactController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseContactController({
    required this.paroisseRepository,
  });

  var code = ''.obs;
  var massInfoUrl = ''.obs;
  var paroisseSelected = ContentPlace().obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  RxList<Contact> contacts = RxList<Contact>([]);

  var refreshController = RefreshController();

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  @override
  void onReady() {
    getContacts();
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
      if (code.value == 'IP') {
        massInfoUrl.value = Get.arguments[2];
        log('massInfoUrl => ${massInfoUrl.value}');
      }
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
      case 'IP':
        return 'Infos paroissiales';
      case 'CO':
        return 'Contacts';
      case 'DM':
        return 'Demandes de messe';
    }
  }

  getTypeMessage(String code) {
    switch (code) {
      case 'HM':
      case 'HC':
      case 'HB':
        return 'Horaires non disponibles\nRéessayez plus tard svp';
      case 'CO':
        return 'Aucun contact trouvé';
      case 'AM':
      case 'EP':
      case 'IP':
      case 'DM':
        return 'Aucune information trouvée';
    }
  }

  String getContactName(String value) {
    if (code.value == 'DM') {
      return 'Contactez la paroisse';
    }
    return value;
  }

  goToReportProblem() {
    Get.toNamed(
      Routes.REPORT_PROBLEM,
      arguments: paroisseSelected.value.toJson(),
    );
  }

  getContacts() {

    if (code.value == 'IP') {
      contacts.clear();
      contacts.add(Contact(
        name: 'Cliquez pour plus d\'informations',
        url: paroisseSelected.value.massInfo,
      ));
      hasData(true);
      return;
    }

    log('request getContacts');
    var idParoisse = paroisseSelected.value.identifier;
    isDataProcessing(true);
    hasData(false);
    paroisseRepository.getPlaceOfWorshipContacts(idParoisse ?? -1).then(
        (value) {
      isDataProcessing(false);
      if (code.value == 'DM') {
        contacts.value = value.where((element) => element.name == AppConstants.DEMANDE_MESSE).toList();
      } else {
        contacts.value = value.where((element) => element.name != AppConstants.DEMANDE_MESSE).toList();;
      }
      if (contacts.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
    }, onError: (error) {
      if (error is! CustomException) return;
      final err = error;
      isDataProcessing(false);
      hasData(false);
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: "Vous n'êtes pas autorisé à accéder à cette ressource",
        ).then((value) {
          //doLogout();
        });
      } else {
        showNotification(message: err.message);
      }
      debugPrint("error => ${err.toString()}");
    });
  }

  onRefresh() {

    if (code.value == 'IP') {
      contacts.clear();
      contacts.add(Contact(
        name: 'Cliquez pour plus d\'informations',
        url: massInfoUrl.value,
      ));
      hasData(true);
      refreshController.refreshCompleted();
      return;
    }

    log('request onRefresh');
    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getPlaceOfWorshipContacts(idParoisse ?? -1).then(
        (value) {
      refreshController.refreshCompleted();
      if (value.isEmpty == false) {
        contacts.value = value;
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      if (error is! CustomException) return;
      final err = error;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: "Vous n'êtes pas autorisé à accéder à cette ressource",
        ).then((value) {
          //doLogout();
        });
      } else {
        showCustomDialog(Get.context!, message: err.message);
      }
      debugPrint("error => ${err.toString()}");
    });
  }

  getPresbyType(String code) {
    switch (code) {
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
