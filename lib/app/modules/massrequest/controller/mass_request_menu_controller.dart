import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class MassRequestMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  MassRequestMenuController({
    required this.paroisseRepository,
  });

  var paroisseSelected = ContentPlace().obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments);
    }
  }

  initMenus() {
    menus.value = [
      TypeMenu(
        code: 'FDM',
        title: 'Faire une demande de messe',
        icon: Assets.imagesIconPray,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
        bgColor: colorGreenLight,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('FDM');
            return;
          }
          moveToMassRequest();
        },
      ),
      TypeMenu(
        code: 'MH',
        title: 'Mes historiques de demande',
        icon: Assets.imagesTime,
        isPngImage: false,
        activeTint: colorPurpleLight2,
        bgColor: colorPurpleLight1,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('MH');
            return;
          }
          moveToMassRequestHistory();
        },
      ),
      TypeMenu(
        code: 'FR',
        title: 'Faire une réclamation',
        icon: Assets.imagesEvent,
        isPngImage: false,
        activeTint: colorOrangeLight3,
        bgColor: colorOrangeLight1,
        isVisible: false,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('FR');
            return;
          }
          moveToMassRequestClaims();
        },
      ),
      TypeMenu(
        code: 'SR',
        title: 'Suivi de réclamation',
        icon: Assets.imagesChecklist,
        isPngImage: false,
        activeTint: colorOrangeLight4,
        bgColor: colorOrangeLight2,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('SR');
            return;
          }
          moveToMassRequestTrackClaims();
        },
      ),
    ].where((element) => element.isVisible == true).toList();
  }

  checkIfUserIsconnected(String code) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.3,
        decoration: const BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Authentification requise',
                style: TextStyles.montserratBold(
                  textSize: TextSizes.twenty,
                  textColor: colorBlack,
                ),
              ),
              Separators.maximumVertical(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Veuillez-vous connecter afin de mener cette action',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.sixteen,
                        textColor: colorBlack,
                      ),
                    ),
                    Separators.maximumVertical(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Annuler",
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.fourteen,
                            textColor: colorBlack,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: colorGreen, width: 0.5),
                        ),
                      ),
                      onPressed: Get.back,
                    ),
                  ),
                  Separators.normalHorizontal(),
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Se connecter",
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.fourteen,
                            textColor: colorWhite,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: colorGreen,
                        enableFeedback: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: colorGreen, width: 0.5),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 250), () {
                          moveToLogin(code);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      enableDrag: false,
      isDismissible: false,
    );
  }

  moveToLogin(String code) async {
    var result = await Get.toNamed(
      Routes.SIGNIN,
      arguments: true,
    );
    if (result == true) {
      log('back moveToLogin');
      switch (code) {
        case 'FDM':
          moveToMassRequest();
          break;
        case 'MH':
          moveToMassRequestHistory();
          break;
        case 'FR':
          moveToMassRequestClaims();
          break;
        case 'SR':
          moveToMassRequestTrackClaims();
          break;
      }
    }
  }

  moveToMassRequest() async {
    await Get.toNamed(
      Routes.MASS_REQUEST,
      arguments: [
        paroisseSelected.toJson(),
        null,
      ],
    );
  }

  moveToMassRequestHistory() async {
    await Get.toNamed(
      Routes.MASS_REQUEST_HISTORY,
      arguments: paroisseSelected.toJson(),
    );
  }

  moveToMassRequestClaims() async {
    await Get.toNamed(
      Routes.MASS_REQUEST_CLAIM,
      arguments: [
        paroisseSelected.toJson(),
        null,
      ],
    );
  }

  moveToMassRequestTrackClaims() async {
    await Get.toNamed(
      Routes.MASS_REQUEST_TRACK_CLAIM,
      arguments: paroisseSelected.toJson(),
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }
}
