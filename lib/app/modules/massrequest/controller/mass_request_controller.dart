import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class MassRequestController extends GetxController {
  final MassRequestRepository massRequestRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestController({
    required this.massRequestRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  RxList<TypeData?> massRequestTypes = RxList<TypeData?>([]);
  Rx<TypeData?> massRequestTypeSelected = Rx<TypeData?>(null);

  RxList<PrayerIntentData?> prayerIntents = RxList<PrayerIntentData?>([]);
  Rx<PrayerIntentData?> prayerIntentSelected = Rx<PrayerIntentData?>(null);

  RxList<PriceData> datesChoosen = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipHours = RxList<LiturgicalCelebrationResponse>([]);

  var isValidForm = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var massRequestSelected = MassRequestResponse().obs;
  var price = '-'.obs;

  @override
  void onInit() {
    getArguments();
    doGetMassRequestType();
    doGetPrayerIntent();
    doGetPlaceOfWorshipHours();

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

  moveToPayment(MassRequestResponse massRequestResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: massRequestResponse.toJson(),
    );
  }

  goToDatesChoice() async {
    datesChoosen.value = await Get.toNamed(Routes.FILTER_MASS_REQUEST_CHOOSE_DATE, arguments: worshipHours);
    datesChoosen.refresh();
    if (datesChoosen.isNotEmpty) {
      doGetMassRequestPrice();
    }
  }

  void checkForm() {
    isValidForm.value = massRequestTypeSelected.value != null && prayerIntentSelected.value != null && price.value != '-';
  }

  String getPrice() {
    if (price.value == '-') return '-';
    return '${price.value.amountFormat()} FCFA';
  }

  updateMassTypeFilter(TypeData? typeData) {
    massRequestTypeSelected.value = typeData;
    checkForm();
    update();
  }

  updatePrayerIntentFilter(PrayerIntentData? prayerIntentData) {
    prayerIntentSelected.value = prayerIntentData;
    checkForm();
    update();
  }

  doGetMassRequestType() {
    hideKeyboard();

    log('request doGetMassRequestType');
    massRequestRepository.getMassRequestType(page: 0).then((value) {
      if (value.isNotEmpty == true) {
        massRequestTypes.value = value;
      }
      update();
    }, onError: (error) {
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  doGetPrayerIntent() {
    hideKeyboard();

    log('request doGetPrayerIntent');
    massRequestRepository.getPrayerIntent(page: 0).then((value) {
      if (value.isNotEmpty == true) {
        prayerIntents.value = value;
      }
      update();
    }, onError: (error) {
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///remove all old dates
  List<LiturgicalCelebrationResponse> getValidPlaceOfWorshipHours(List<LiturgicalCelebrationResponse> data) {
    List<LiturgicalCelebrationResponse> worships = [];
    for (LiturgicalCelebrationResponse item in data) {
      if (item.isRecurrent == false) {
        if (Jiffy.parse(item.startDate ?? Jiffy.now().format(), pattern: AppConstants.TIME_ZONE_FORMAT).isAfter(Jiffy.now().add(hours: 24))) {
          worships.add(item);
        }
      } else {
        worships.add(item);
      }
    }
    return worships;
  }

  doGetPlaceOfWorshipHours() {
    hideKeyboard();

    log('request doGetPlaceOfWorshipHours');
    paroisseRepository.getLiturgicalCelebration(paroisseSelected.value.identifier).then((value) {
      if (value.isNotEmpty == true) {
        worshipHours.value = value;
        /*log('doGetPlaceOfWorshipHours before ::: ${value.length}');
        worshipHours.value = getValidPlaceOfWorshipHours(value);
        log('doGetPlaceOfWorshipHours after ::: ${worshipHours.length}');*/
      }
    }, onError: (error) {
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("doGetPlaceOfWorshipHours Error => ${error.toString()}");
    });
  }

  doGetMassRequestPrice() {
    hideKeyboard();

    isDataProcessing(true);
    hasData(false);
    log('request doGetMassRequestPrice');
    massRequestRepository.getMassRequestPrice(request: datesChoosen, workshipId: paroisseSelected.value.identifier.toString() ?? '').then((value) {
      isDataProcessing(false);
      hasData(true);
      price.value = value.price.toString().amountFormat();
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        price.value = '-';
        log('Error doGetMassRequestPrice ::: ${err.message.toString()}');
      }
      debugPrint("Error doGetMassRequestPrice => ${error.toString()}");
    });
  }

  doSendMassRequest() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Soumission en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = MassRequestData(
      prayerIntent: prayerIntentSelected.value?.code,
      typeOfMassRequest: massRequestTypeSelected.value?.code,
      slots: [],
      worshipPlace: paroisseSelected.value.identifier,
    );

    log('request doSendClaim => ${jsonEncode(request.toJson())}');

    massRequestRepository.sendMassRequest(request: request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      moveToPayment(value);
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
