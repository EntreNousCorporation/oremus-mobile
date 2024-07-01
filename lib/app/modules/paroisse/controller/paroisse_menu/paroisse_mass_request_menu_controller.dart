import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class ParoisseMassRequestMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMassRequestMenuController({
    required this.paroisseRepository,
  });

  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

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
        activeTint: colorBlack,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('FDM');
            return;
          }
          moveToAskMass();
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'MH',
        title: 'Mes historiques',
        icon: Assets.imagesTime,
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('MH');
            return;
          }
          moveToHistory();
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'FR',
        title: 'Faire une réclamation',
        icon: Assets.imagesEvent,
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('FR');
            return;
          }
          moveToClaims();
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'SR',
        title: 'Suivi de réclamation',
        icon: Assets.imagesChecklist,
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('SR');
            return;
          }
          moveToTrackClaims();
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
    ];
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
                          borderRadius: BorderRadius.circular(4),
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
                      ),
                      onPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 300), () {
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
          moveToAskMass();
          break;
        case 'MH':
          moveToHistory();
          break;
        case 'FR':
          moveToClaims();
          break;
        case 'SR':
          moveToTrackClaims();
          break;
      }
    }
  }

  moveToAskMass() {}

  moveToHistory() {}

  moveToClaims() {}

  moveToTrackClaims() {}

  bool isWorshipPlaceFavorite(ContentPlace paroisse) {
    var isFavorite = false;
    var favorites = paroisseRepository.getAllFavorites();
    var hasParoisse = favorites
        .indexWhere((element) => element.identifier == paroisse.identifier);
    if (hasParoisse != -1) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    return isFavorite;
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
