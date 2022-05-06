import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/confession/regular_confession_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/confession/special_confession_screen.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseConfessionController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseConfessionController({
    required this.paroisseRepository,
  });

  var isRegularMassDataProcessing = false.obs;
  var hasRegularMassData = false.obs;

  var isSpecialMassDataProcessing = false.obs;
  var hasSpecialMassData = false.obs;

  var code = ''.obs;
  var paroisseSelected = ContentPlace().obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);
  RxList<LiturgicalCelebrationResponse> regularConfessions = RxList<LiturgicalCelebrationResponse>([]);
  RxList<LiturgicalCelebrationResponse> specialConfessions = RxList<LiturgicalCelebrationResponse>([]);

  var refreshController = RefreshController();
  var refreshNotRecurrentController = RefreshController();
  var menusConfessionTab = <String, Widget>{}.obs;

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  @override
  void onReady() {
    getConfessionsRecurrentTimes();
    getConfessionsNotRecurrentTimes();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    refreshNotRecurrentController.dispose();
    super.dispose();
  }

  initMenus() {
    menusConfessionTab['Confessions ordinaires'] = const RegularConfessionScreen();
    menusConfessionTab['Confessions spéciales'] = const SpecialConfessionScreen();
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

  getConfessionsRecurrentTimes() {
    log('request getConfessionsRecurrentTimes');

    var idParoisse = paroisseSelected.value.identifier;
    isRegularMassDataProcessing(true);
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      isRegularMassDataProcessing(false);
      regularConfessions.value = value
          .where((element) => (element.type?.code == 'CONFESSION') && (element.isRecurrent == true))
          .toList();
      log('regularConfessions => ${regularConfessions.length}');
      if (regularConfessions.isNotEmpty == true) {
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

  getConfessionsNotRecurrentTimes() {
    log('request getConfessionsNotRecurrentTimes');

    var idParoisse = paroisseSelected.value.identifier;
    isSpecialMassDataProcessing(true);
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      isSpecialMassDataProcessing(false);
      specialConfessions.value = value
          .where((element) => (element.type?.code == 'CONFESSION') && (element.isRecurrent == false) && (Jiffy(element.startDate).isAfter(Jiffy())))
          .toList();
      log('specialConfessions => ${specialConfessions.length}');
      if (specialConfessions.isNotEmpty == true) {
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

  onRegularConfessionsRefresh() {
    log('request onRegularConfessionsRefresh');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      refreshController.refreshCompleted();
      if (value.isEmpty == false) {
        regularConfessions.value = value
            .where((element) => (element.type?.code == 'CONFESSION') && (element.isRecurrent == true))
            .toList();
        log('regularConfessions => ${regularConfessions.length}');
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
      debugPrint("error regularConfessions => ${error.toString()}");
    });
  }

  onSpecialConfessionRefresh() {
    log('request onSpecialConfessionRefresh');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      refreshNotRecurrentController.refreshCompleted();
      if (value.isNotEmpty == true) {
        specialConfessions.value = value
            .where((element) => element.type?.code == 'CONFESSION' && (element.isRecurrent == false) && (Jiffy(element.startDate).isAfter(Jiffy())))
            .toList();
        log('specialConfessions => ${specialConfessions.length}');
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
      debugPrint("error specialConfessions => ${error.toString()}");
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
