import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class ParoisseMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuController({
    required this.paroisseRepository,
  });

  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);
  RxList<LiturgicalCelebrationResponse> masses = RxList<LiturgicalCelebrationResponse>([]);
  RxList<LiturgicalCelebrationResponse> confessions = RxList<LiturgicalCelebrationResponse>([]);
  RxList<LiturgicalCelebrationResponse> liturgicalCelebrations = RxList<LiturgicalCelebrationResponse>([]);

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  @override
  void onReady() {
    getLiturgicalCelebrations();
    super.onReady();
  }

  getArguments() {
    if (Get.arguments != null) {
      indexSelected.value = Get.arguments[0];
      paroisseSelected.value =
          ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  initMenus() {
    menus.value = [
      TypeMenu(
        code: 'HM',
        title: 'Horaires des messes',
        icon: 'assets/images/messe.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () {
          liturgicalCelebrations.value = masses.value;
          Get.toNamed(
            Routes.PAROISSE_MESSE,
            arguments: [
              'HM',
              jsonEncode(paroisseSelected.value.toJson()),
              jsonEncode(liturgicalCelebrations.value).toString(),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'HC',
        title: 'Horaires des confessions',
        icon: 'assets/images/confession_icon.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () {
          liturgicalCelebrations.value = confessions.value;
          Get.toNamed(
            Routes.PAROISSE_CONFESSION,
            arguments: [
              'HC',
              jsonEncode(paroisseSelected.value.toJson()),
              jsonEncode(liturgicalCelebrations.value).toString(),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'HB',
        title: 'Horaires des bureaux',
        icon: 'assets/images/calendar.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () {
          /*Get.toNamed(
            Routes.PAROISSE_CONFESSION,
            arguments: [
              'HB',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );*/
        },
      ),
      TypeMenu(
        code: 'AM',
        title: 'Activités & mouvements',
        icon: 'assets/images/group.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_ACTIVITY_MOVEMENT,
            arguments: [
              'AM',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'EP',
        title: 'Equipe presbytérale',
        icon: 'assets/images/priest_icon.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_PRESBY_TEAM,
            arguments: [
              'EP',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
    ];
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: jsonEncode(paroisseSelected.value.toJson()),
    );
  }

  getLiturgicalCelebrations() {
    log('request getLiturgicalCelebrations');

    var idParoisse = paroisseSelected.value.identifier;
    paroisseRepository.getLiturgicalCelebration(idParoisse ?? -1).then((value) {
      if (value.isEmpty == false) {
        masses.value = value.where((element) => (element.type?.code != 'CONFESSION')).toList();
        confessions.value = value
            .where((element) => element.type?.code == 'CONFESSION')
            .toList();
        log('masses => ${masses.length}');
        log('confessions => ${confessions.length}');
      }
    }, onError: (error) {
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
}
