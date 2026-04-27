import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class DonationWithoutWorshipController extends GetxController {
  final DonationRepository donationRepository;
  final ParoisseRepository paroisseRepository;

  DonationWithoutWorshipController({
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

  var selectedEntityType = EntityType.worship.name.obs;
  var isOremusSelected = false.obs;

  var selectedAmount = ''.obs;

  @override
  void onInit() {
    getArguments();
    initControllers();
    initAmountListeners();
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

  getArguments() {
    if (Get.arguments == null) return;
    Map<String, dynamic> arguments = Get.arguments;
    if (arguments.containsKey('entity_type')) {
      selectedEntityType.value = arguments['entity_type'];
    }
  }

  void initAmountListeners() {
    amountController.addListener(() {
      selectedAmount.value = amountController.text.replaceAll(RegExp(r'\s'), '');
    });
  }

  initControllers() {
    amountController = TextEditingController();
    descriptionController = TextEditingController();
  }

  void selectEntityType(String entityType) {
    selectedEntityType.value = entityType;

    // If switching to Oremus, clear parish selection
    if (entityType == EntityType.oremus.name) {
      paroisseSelected.value = ContentPlace();
    }
    checkForm();
  }

  moveToRecap() {
    Get.toNamed(
      Routes.DONATION_RECAP,
      arguments: {
        'donationAmount': amountController.text,
        'donationDescription': descriptionController.text,
        'worshipPlace': selectedEntityType.value == EntityType.worship.name ?
        paroisseSelected.toJson() : null,
        'isOremus': selectedEntityType.value == EntityType.oremus.name,
      },
    );
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
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  goToWorshipChoice() async {
    paroisseSelected.value = await Get.toNamed(
      Routes.FILTER_CHOOSE_WORSHIP,
      arguments: 'Faire un don',
    );
    log('goToWorshipChoice ::: ${paroisseSelected.value.identifier}');
    if (paroisseSelected.value.identifier != null) {
      paroisseSelected.refresh();
    }
    checkForm();
    update();
  }

  void checkForm() {

    // Vérifier si le montant est vide
    if (amountController.text.isEmpty) {
      isValidForm.value = false;
    } else {
      // Vérifier le montant minimum
      int amount;
      try {
        amount = int.parse(amountController.text.replaceAll(RegExp(r'\s'), ''));
      } catch (e) {
        isValidForm.value = false;
        update();
        return;
      }

      // Pour Oremus, seul le montant est nécessaire
      if (selectedEntityType.value == EntityType.oremus.name) {
        isValidForm.value = amount >= AppConstants.MIN_AMOUNT;
      }
      // Pour Paroisse, le montant et la paroisse sont nécessaires
      else {
        isValidForm.value = amount >= AppConstants.MIN_AMOUNT &&
            paroisseSelected.value.identifier != null;
      }
    }

    // Forcer une mise à jour
    isValidForm.refresh();
    log("isValidForm mis à jour: ${isValidForm.value}");
    update();
  }
}