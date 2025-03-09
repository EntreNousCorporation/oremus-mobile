import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class MassRequestClaimController extends GetxController {
  final MassRequestClaimRepository massRequestClaimRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestClaimController({
    required this.massRequestClaimRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var isValidForm = false.obs;

  RxList<TypeData> claimTypes = RxList<TypeData>([]);
  Rx<TypeData?> claimTypeSelected = Rx<TypeData?>(null);

  var paroisseSelected = ContentPlace().obs;
  var massRequestSelected = MassRequestResponse().obs;
  var claimDescription = TextEditingController();

  @override
  void onInit() {
    getArguments();
    doGetClaimTypes();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[0]);
      if (Get.arguments[1] != null) {
        massRequestSelected.value = MassRequestResponse.fromJson(Get.arguments[1]);
      }
    }
  }

  updateClaimTypeFilter(TypeData? typeData) {
    claimTypeSelected.value = typeData;
    checkForm();
    update();
  }

  void checkForm() {
    String description =
        claimDescription.text.trim().toString().replaceAll(RegExp(r'\s'), '');
    isValidForm.value =
        description.isNotEmpty && claimTypeSelected.value != null;
    update();
  }

  resetForm() {
    //paroisseSelected.value = ContentPlace();
    claimTypeSelected.value = null;
    claimDescription.clear();
    checkForm();
  }

  goToWorshipChoice() async {
    paroisseSelected = await Get.toNamed(Routes.FILTER_CHOOSE_WORSHIP, arguments: 'Faire une reclamation',);
    log('goToWorshipChoice ::: ${paroisseSelected.value.identifier}');
    if (paroisseSelected.value.identifier != null) {
      paroisseSelected.refresh();
    }
    checkForm();
  }

  doGetClaimTypes() {
    hideKeyboard();
    /*EasyLoading.show(
      status: 'Veuillez patienter...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });*/
    log('request getClaimTypes');
    massRequestClaimRepository.getClaimTypes(page: 0).then((value) {
      /*EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });*/
      if (value.isNotEmpty == true) {
        hasData(true);
        claimTypes.value = value;
        update();
      } else {
        hasData(false);
      }
    }, onError: (error) {
      /*EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });*/
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showCustomDialog(
          Get.context!,
          message: err.message.toString(),
          negativeLabel: 'OK',
          positiveLabel: 'Réessayer',
          positiveCallBack: () {
            doGetClaimTypes();
          },
        );
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  doSendClaim() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Soumission en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = ClaimRequest(
      massRequest: massRequestSelected.value.identifier,
      description: claimDescription.text.trim(),
      typeOfClaim: claimTypeSelected.value?.code,
    );

    log('request doSendClaim => ${jsonEncode(request.toJson())}');

    massRequestClaimRepository.claim(request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      resetForm();
      showNotification(
          message: 'Votre réclamation a été prise en compte',
          duration: const Duration(seconds: 5),
        bgColor: colorGreen,
      );
    }, onError: (error) {
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
      } else {
        showNotification(message: err.message.toString(), duration: const Duration(seconds: 4));
      }
    });
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
      arguments: paroisseSelected.toJson(),
    );
  }

  saveFavorite(ContentPlace paroisse, bool state) {
    log('saveFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.addFavorite(paroisse);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    log('removeFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.deleteFavorite(paroisse);
  }
}
