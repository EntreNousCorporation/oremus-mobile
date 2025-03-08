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
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class DonationWithWorshipController extends GetxController {
  final DonationRepository donationRepository;
  final ParoisseRepository paroisseRepository;

  DonationWithWorshipController({
    required this.donationRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isPricingProcessing = false.obs;
  var isDatesProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  late TextEditingController amountController;
  late TextEditingController descriptionController;
  var amountFocusNode = FocusNode();

  var isValidForm = false.obs;
  var paroisseSelected = ContentPlace().obs;
  var massRequestSelected = MassRequestResponse().obs;

  var selectedEntityType = EntityType.worship.name.obs; // default to paroisse
  var isOremusSelected = false.obs;

  @override
  void onInit() {
    initControllers();
    update();
    super.onInit();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    amountFocusNode.dispose();
    super.dispose();
  }

  initControllers() {
    amountController = TextEditingController();
    descriptionController = TextEditingController();
    // Attendre un court délai avant de donner le focus au TextField
    Timer(const Duration(milliseconds: 500), () {
      FocusScope.of(Get.context!).requestFocus(amountFocusNode);
    });
  }

  // New method to handle entity selection
  void selectEntityType(String entityType) {
    selectedEntityType.value = entityType;

    // If switching to Oremus, clear parish selection
    if (entityType == EntityType.oremus.name) {
      paroisseSelected.value = ContentPlace();
    }

    checkForm();
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

  goToWorshipChoice() async {
    paroisseSelected = await Get.toNamed(
      Routes.FILTER_MASS_REQUEST_CHOOSE_WORSHIP,
      arguments: 'Faire un don',
    );
    log('goToWorshipChoice ::: ${paroisseSelected.value.identifier}');
    if (paroisseSelected.value.identifier != null) {
      paroisseSelected.refresh();
    }
    checkForm();
  }

  void checkForm() {
    // For Oremus, only amount is needed
    // For Paroisse, both amount and parish selection are needed
    if (amountController.text.isEmpty) return;
    int amount = int.parse(amountController.text.replaceAll(RegExp(r'\s'), ''));
    if (selectedEntityType.value == EntityType.oremus.name) {
      isValidForm.value = descriptionController.text.isNotEmpty && amountController.text.isNotEmpty && amount >= AppConstants.MIN_AMOUNT;
    } else {
      isValidForm.value = descriptionController.text.isNotEmpty && amountController.text.isNotEmpty && amount >= AppConstants.MIN_AMOUNT &&
          paroisseSelected.value.identifier != null;
    }
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
      description: descriptionController.text,
      // Only set worship place if paroisse is selected
      worshipPlace: selectedEntityType.value == EntityType.worship.name ?
      paroisseSelected.value.identifier : null,
      isOremus: selectedEntityType.value == EntityType.oremus.name, //variable do not go to backend
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
}