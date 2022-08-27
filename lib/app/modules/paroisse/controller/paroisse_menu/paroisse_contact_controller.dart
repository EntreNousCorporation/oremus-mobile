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
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class ParoisseContactController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseContactController({
    required this.paroisseRepository,
  });

  var code = ''.obs;
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
      paroisseSelected.value =
          ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  launchEmail(String email) async {
    if (await canLaunch(Uri.encodeFull(
            "mailto:$email?subject=Besoin d'information&body=")) ==
        true) {
      launch(
          Uri.encodeFull("mailto:$email?subject=Besoin d'information&body="));
    } else {
      log("Can't launch url");
    }
  }

  launchPhone(String phone) async {
    if (await canLaunch("tel:$phone") == true) {
      launch("tel:$phone");
    } else {
      log("Can't launch phone number");
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
      case 'CO':
        return 'Contacts';
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
      case 'CO':
        return 'Aucune information trouvée';
    }
  }

  getContacts() {
    log('request getContacts');

    var idParoisse = paroisseSelected.value.identifier;
    isDataProcessing(true);
    hasData(false);
    paroisseRepository.getPlaceOfWorshipContacts(idParoisse ?? -1).then(
        (value) {
      isDataProcessing(false);
      contacts.value = value;
      if (contacts.isNotEmpty == true) {
        hasData(true);
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
          Get.context!,
          message: "Vous n’êtes pas autorisé à accéder à cette ressource",
        ).then((value) {
          //doLogout();
        });
      } else {
        showCustomDialog(Get.context!, message: err.message);
      }
      debugPrint("error => ${err.toString()}");
    });
  }

  onRefresh() {
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
      var err = error as CustomException;
      debugPrint('${err.code}');
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: "Vous n’êtes pas autorisé à accéder à cette ressource",
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
