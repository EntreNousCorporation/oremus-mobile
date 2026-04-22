import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
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
  late TextEditingController descriptionController;

  var isValidForm = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var donationSelected = DonationResponse().obs;

  var selectedAmount = ''.obs;

  @override
  void onInit() {
    getArguments();
    initControllers();
    initAmountListeners();
    super.onInit();
  }

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void initAmountListeners() {
    // Observer les changements de texte dans amountController
    amountController.addListener(() {
      // Mise à jour de selectedAmount quand amountController change
      selectedAmount.value = amountController.text.replaceAll(RegExp(r'\s'), '');
    });
  }

  initControllers() {
    amountController = TextEditingController();
    descriptionController = TextEditingController();
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
        donationSelected.value = DonationResponse.fromJson(Get.arguments[1]);
      }
    }
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  void checkForm() {
    if (amountController.text.isEmpty) return;
    int amount = int.parse(amountController.text.replaceAll(RegExp(r'\s'), ''));
    isValidForm.value = amountController.text.isNotEmpty && amount >= AppConstants.MIN_AMOUNT;
    update();
  }

  moveToRecap() {
    Get.toNamed(
      Routes.DONATION_RECAP,
      arguments: {
        'donationAmount': amountController.text,
        'donationDescription': descriptionController.text,
        'worshipPlace': paroisseSelected.toJson(),
      },
    );
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
      arguments: paroisseSelected.toJson(),
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
