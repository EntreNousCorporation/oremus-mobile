import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class DonationController extends GetxController {
  final DonationRepository donationRepository;
  final ParoisseRepository paroisseRepository;

  DonationController({
    required this.donationRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isPricingProcessing = false.obs;
  var isDatesProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  late TextEditingController amountController;
  var amountFocusNode = FocusNode();

  var isValidForm = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var donationSelected = DonationResponse().obs;

  @override
  void onInit() {
    getArguments();
    initControllers();
    super.onInit();
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    super.dispose();
  }

  initControllers() {
    amountController = TextEditingController();
    // Attendre 500 millisecondes avant de donner le focus au TextField
    Timer(const Duration(milliseconds: 500), () {
      FocusScope.of(Get.context!).requestFocus(amountFocusNode);
    });
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[0]);
      log('arguments ::: ${jsonEncode(Get.arguments[0])}');
      log('paroisseSelected :::${jsonEncode(paroisseSelected.value)}');
      if (Get.arguments[1] != null) {
        donationSelected.value =
            DonationResponse.fromJson(Get.arguments[1]);
      }
    }
  }

  moveToPayment(DonationResponse donationResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: {
        'payment_response': donationResponse.toJson(),
        'payment_type': PaymentType.donation,
      },
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }

  void checkForm() {
    isValidForm.value = donationSelected.value != null &&
        amountController.text.isNotEmpty;
    update();
  }

  doSendDonation({bool? forceDuplicateCreation}) {
    hideKeyboard();
    EasyLoading.show(
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = DonationData(
      amount: amountController.text.replaceAll(RegExp(r'\s'), ''),
      worshipPlace: paroisseSelected.value.identifier,
      forceDuplicateCreation: forceDuplicateCreation,
    );

    log('request doSendDonation => ${jsonEncode(request.toJson())}');

    donationRepository.sendDonation(request: request).then(
      (value) {
        EasyLoading.dismiss(animation: true).then((v) {
          unlockBackButton.value = true;
        });
        moveToPayment(value);
      },
      onError: (error) {
        EasyLoading.dismiss(animation: true).then((v) {
          unlockBackButton.value = true;
        });
        debugPrint("error => ${error.toString()}");
        var err = error as CustomException;
        if (err.code == 401) {
          showCustomDialog(
            Get.context!,
            message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
          ).then((value) {
            doLogout();
          });
          return;
        }
        if (err.code == 409) {
          showCustomDialog(
            Get.context!,
            message:
            'Vous venez de faire un don identique. Souhaitez-vous confirmer ce don ?',
            positiveLabel: 'OUI',
            positiveCallBack: () {
              doSendDonation(forceDuplicateCreation: true);
            },
            negativeLabel: 'NON',
          );
          return;
        }
        showNotification(
            message: 'Une erreur est survenue',
            duration: const Duration(seconds: 4));
      },
    );
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

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
      arguments: jsonEncode(paroisseSelected.toJson()),
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
