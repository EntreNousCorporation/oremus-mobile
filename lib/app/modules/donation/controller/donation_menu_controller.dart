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

class DonationMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  DonationMenuController({
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
        code: 'FD',
        title: 'Faire un don',
        icon: Assets.imagesVolunteer,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
        bgColor: colorGreenLight,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('FD');
            return;
          }
          if (donationWithoutWorship.value == true) {
            moveToDonationWithoutWorship();
            return;
          }
          moveToDonation();
        },
      ),
      TypeMenu(
        code: 'DH',
        title: 'Mes historiques de don',
        icon: Assets.imagesTime,
        isPngImage: false,
        activeTint: colorPurpleLight2,
        bgColor: colorPurpleLight1,
        goToPage: () async {
          if (isUserConnected.value == false) {
            checkIfUserIsconnected('DH');
            return;
          }
          moveToDonationHistory();
        },
      ),
    ].where((element) => element.isVisible == true).toList();
  }

  checkIfUserIsconnected(String code) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.4, // Légèrement plus haut pour plus d'espace
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                color: colorGreen.withOpacity(0.8),
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
                          side: BorderSide(color: colorGreen.withOpacity(0.7), width: 1),
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
                        shadowColor: colorGreen.withOpacity(0.5),
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
              SizedBox(height: MediaQuery.of(Get.context!).padding.bottom)
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
        case 'FD':
          if (donationWithoutWorship.value == true) {
            moveToDonationWithoutWorship();
          } else {
            moveToDonation();
          }
          break;
        case 'DH':
          moveToDonationHistory();
          break;
      }
    }
  }

  moveToDonation() async {
    await Get.toNamed(
      Routes.DONATION,
      arguments: [
        paroisseSelected.toJson(),
        null,
      ],
    );
  }

  moveToDonationWithoutWorship() {
    Get.toNamed(Routes.DONATION_WITHOUT_WORSHIP);
  }

  moveToDonationHistory() async {
    await Get.toNamed(
      Routes.DONATION_HISTORY,
      arguments: paroisseSelected.toJson(),
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }
}
