import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/mass/special_mass_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/mass/regular_mass_screen.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseMasseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMasseController({
    required this.paroisseRepository,
  });

  var isRegularMassDataProcessing = false.obs;
  var hasRegularMassData = false.obs;

  var isSpecialMassDataProcessing = false.obs;
  var hasSpecialMassData = false.obs;

  var code = ''.obs;
  var paroisseSelected = ContentPlace().obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);
  RxList<LiturgicalCelebrationResponse> regularMasses = RxList<LiturgicalCelebrationResponse>([]);
  RxList<LiturgicalCelebrationResponse> specialMasses = RxList<LiturgicalCelebrationResponse>([]);

  var refreshController = RefreshController();
  var refreshNotRecurrentController = RefreshController();
  var menusMasseTab = <String, Widget>{}.obs;

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  @override
  void onReady() {
    getMasseRecurrentTimes();
    getMasseNotRecurrentTimes();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    refreshNotRecurrentController.dispose();
    super.dispose();
  }

  initMenus() {
    menusMasseTab['Messes ordinaires'] = const RegularMassScreen();
    menusMasseTab['Messes spéciales'] = const SpecialMassScreen();
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

  getMasseRecurrentTimes() {
    log('request getMasseRecurrentTimes');

    var idParoisse = paroisseSelected.value.identifier;
    isRegularMassDataProcessing(true);
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      isRegularMassDataProcessing(false);
      regularMasses.value = value
          .where((element) => (element.type?.code != 'CONFESSION') && (element.isRecurrent == true))
          .toList();
      log('regularMasses => ${regularMasses.length}');
      if (regularMasses.isNotEmpty == true) {
        hasRegularMassData(true);
      } else {
        hasRegularMassData(false);
      }
    }, onError: (error) {
      isRegularMassDataProcessing(false);
      hasRegularMassData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error regularMasses => ${error.toString()}");
    });
  }

  getMasseNotRecurrentTimes() {
    log('request getMasseNotRecurrentTimes');

    var idParoisse = paroisseSelected.value.identifier;
    isSpecialMassDataProcessing(true);
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      isSpecialMassDataProcessing(false);
      specialMasses.value = value
          .where((element) => (element.type?.code != 'CONFESSION') && (element.isRecurrent == false) && (Jiffy(element.startDate).isAfter(Jiffy())))
          .toList();
      log('specialMasses => ${specialMasses.length}');
      if (specialMasses.isNotEmpty == true) {
        hasSpecialMassData(true);
      } else {
        hasSpecialMassData(false);
      }
    }, onError: (error) {
      isSpecialMassDataProcessing(false);
      hasSpecialMassData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error specialMasses => ${error.toString()}");
    });
  }

  onRegularMassesRefresh() {
    log('request onRegularMassesRefresh');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      refreshController.refreshCompleted();
      if (value.isEmpty == false) {
        regularMasses.value = value
            .where((element) => (element.type?.code != 'CONFESSION') && (element.isRecurrent == true))
            .toList();
        log('regularMasses => ${regularMasses.length}');
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
      debugPrint("error regularMasses => ${error.toString()}");
    });
  }

  onSpecialMassesRefresh() {
    log('request onSpecialMassesRefresh');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      refreshNotRecurrentController.refreshCompleted();
      if (value.isNotEmpty == true) {
        specialMasses.value = value
            .where((element) => (element.type?.code != 'CONFESSION') && (element.isRecurrent == false) && (Jiffy(element.startDate).isAfter(Jiffy())))
            .toList();
        log('specialMasses => ${specialMasses.length}');
        //log('specialMasses hour => ${Jiffy(specialMasses.value.first.startDate, "yyyy-MM-dd'T'HH:mm:ss").jm}');
      }
    }, onError: (error) {
      refreshNotRecurrentController.refreshCompleted();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error specialMasses => ${error.toString()}");
    });
  }

  String getDate(String date) {
    return Jiffy(date, "yyyy-MM-dd'T'HH:mm:ss").yMd;
  }

  String getHour(String date) {
    return Jiffy(date, "yyyy-MM-dd'T'HH:mm:ss").jm;
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
