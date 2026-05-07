import 'dart:convert';
import 'dart:developer';

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
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class ParoisseMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuController({required this.paroisseRepository});

  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);
  var kExpandedHeight = Get.width / 1.7;

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      indexSelected.value = Get.arguments[0];
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[1]);
      doGetWorshipDetails(paroisseSelected.value.identifier.toString());
    }
  }

  initMenus() {
    menus.value =
        [
          TypeMenu(
            code: 'HM',
            title: 'Horaires des messes',
            icon: Assets.imagesMesse,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_MESSE,
                arguments: ['HM', paroisseSelected.value.toJson()],
              );
              log("retour");
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'HC',
            title: 'Horaires des confessions',
            icon: Assets.imagesConfessionIcon,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_CONFESSION,
                arguments: ['HC', jsonEncode(paroisseSelected.value.toJson())],
              );
              log("retour");
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'FD',
            title: 'Don',
            icon: Assets.imagesVolunteer,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_DONATION_MENU,
                arguments: paroisseSelected.toJson(),
              );
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'DM',
            title: 'Demandes de messe',
            icon: Assets.imagesIconDemandeDeMesse,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_MASS_REQUEST_MENU,
                arguments: paroisseSelected.toJson(),
              );
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'EP',
            title: 'Equipe presbytérale',
            icon: Assets.imagesPriestIcon,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_PRESBY_TEAM,
                arguments: ['EP', jsonEncode(paroisseSelected.value.toJson())],
              );
              log("retour");
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'CO',
            title: 'Contacts',
            icon: Assets.imagesContacts,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_CONTACT,
                arguments: ['CO', jsonEncode(paroisseSelected.value.toJson())],
              );
              log("retour");
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'IP',
            title: 'Infos paroissiales',
            icon: Assets.imagesIconInfosParoissiales,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              log('massInfoUrl => ${paroisseSelected.value.massInfo}');
              await Get.toNamed(
                Routes.PAROISSE_CONTACT,
                arguments: [
                  'IP',
                  jsonEncode(paroisseSelected.value.toJson()),
                  paroisseSelected.value.massInfo ?? '',
                ],
              );

              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            code: 'HB',
            title: 'Horaires des bureaux',
            icon: Assets.imagesCalendar,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_OFFICE,
                arguments: ['HB', jsonEncode(paroisseSelected.value.toJson())],
              );
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
          TypeMenu(
            isVisible: false,
            code: 'AM',
            title: 'Activités & mouvements',
            icon: Assets.imagesGroup,
            isPngImage: false,
            activeTint: colorGreenSemiLight,
            goToPage: () async {
              await Get.toNamed(
                Routes.PAROISSE_ACTIVITY_MOVEMENT,
                arguments: ['AM', jsonEncode(paroisseSelected.value.toJson())],
              );
              log("retour");
              //on met à jour la liste au cas où favoris mis à jour
              paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(
                paroisseSelected.value,
              );
              paroisseSelected.refresh();
            },
          ),
        ].where((element) => element.isVisible).toList();
  }

  bool isWorshipPlaceFavorite(ContentPlace paroisse) {
    var isFavorite = false;
    var favorites = paroisseRepository.getAllFavorites();
    var hasParoisse = favorites.indexWhere(
      (element) => element.identifier == paroisse.identifier,
    );
    if (hasParoisse != -1) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    return isFavorite;
  }

  doGoToReportProblem() {
    if (isUserConnected.value == false) {
      checkIfUserIsconnected('SP');
      return;
    }
    goToReportProblem();
  }

  checkIfUserIsconnected(String code) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.32, // Légèrement plus haut pour plus d'espace
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24), // Padding légèrement plus grand
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Indicateur de dialogue en haut
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              Text(
                'Authentification requise',
                style: TextStyles.montserratBold(
                  textSize: TextSizes.twenty,
                  textColor: colorBlack,
                ),
              ),
              const SizedBox(height: 8),
              // Icône pour renforcer le message
              Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: colorGreen.withValues(alpha: 0.8),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Veuillez vous connecter afin de mener cette action',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.sixteen,
                        textColor: Colors.grey[800]!,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Annuler",
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.sixteen,
                            textColor: colorGreen,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: colorGreen.withValues(alpha: 0.7),
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: Get.back,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Se connecter",
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen,
                            textColor: colorWhite,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorGreen,
                        elevation: 2,
                        shadowColor: colorGreen.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

  doGetWorshipDetails(String identifier) {
    paroisseRepository
        .getParoisseDetails(worshipId: paroisseSelected.value.identifier)
        .then(
          (value) {
            paroisseSelected.value = value;
            update();
          },
          onError: (error) {
            if (error is! CustomException) return;
            final err = error;
            if (err.code.toString().contains('401')) {
              showCustomDialog(
                Get.context!,
                message:
                    'Votre session a expiré\nVeuillez-vous reconnecter svp',
              ).then((value) {
                doLogout();
              });
            } else {
              showNotification(
                message:
                    'Erreur lors du chargement des données: ${err.code.toString()}',
              );
            }
            debugPrint("error => ${error.toString()}");
          },
        );
  }

  moveToLogin(String code) async {
    var result = await Get.toNamed(Routes.SIGNIN, arguments: true);
    if (result == true) {
      log('back moveToLogin');
      switch (code) {
        case 'SP':
          goToReportProblem();
          break;
      }
    }
  }

  goToReportProblem() {
    Get.toNamed(
      Routes.REPORT_PROBLEM,
      arguments: paroisseSelected.value.toJson(),
    );
  }

  goToMap() {
    Get.toNamed(Routes.PAROISSE_MAP, arguments: paroisseSelected.toJson());
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

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
