import 'dart:async';
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
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class MassRequestWithWorshipController extends GetxController {
  final MassRequestRepository massRequestRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestWithWorshipController({
    required this.massRequestRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isPricingProcessing = false.obs;
  var isDatesProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  late TextEditingController massIntentionController;
  var massIntentionFocusNode = FocusNode();

  RxList<TypeData?> massRequestTypes = RxList<TypeData?>([]);
  Rx<TypeData?> massRequestTypeSelected = Rx<TypeData?>(null);

  RxList<PrayerIntentData?> prayerIntents = RxList<PrayerIntentData?>([]);
  Rx<PrayerIntentData?> prayerIntentSelected = Rx<PrayerIntentData?>(null);

  RxList<PriceData> datesChoosen = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipHours =
      RxList<LiturgicalCelebrationResponse>([]);

  RxList<MassTypeRepetitionData?> massRequestTypeRepetitions = RxList<MassTypeRepetitionData?>([]);
  Rx<MassTypeRepetitionData?> massRequestTypeRepetitionSelected = Rx<MassTypeRepetitionData?>(null);

  RxList<LiturgicalCelebrationResponse> worshipRecurrentHoursTemp = RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipRecurrentHours = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipSpecialHoursTemp = RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipSpecialHours = RxList<PriceData>([]);

  var isValidForm = false.obs;
  var allowedDates = RxList<DateTime>([]);
  var selectedDate = Rx<PriceData?>(null);
  var selectedHours = RxList<Slot?>([]);
  var selectedHour = Rx<Slot?>(null);

  var paroisseSelected = ContentPlace().obs;
  var massRequestSelected = MassRequestResponse().obs;
  var price = '-'.obs;

  @override
  void onInit() {
    initControllers();
    doGetMassRequestType();
    initMassTypeRepetitions();
    super.onInit();
  }

  @override
  void dispose() {
    massIntentionController.dispose();
    massIntentionFocusNode.dispose();
    super.dispose();
  }

  initControllers() {
    massIntentionController = TextEditingController();
    // Attendre 2 secondes avant de donner le focus au TextField
    Timer(const Duration(milliseconds: 500), () {
      FocusScope.of(Get.context!).requestFocus(massIntentionFocusNode);
    });
  }

  initMassTypeRepetitions() {
    massRequestTypeRepetitions.value = [
      MassTypeRepetitionData(
        code: 'once',
        name: 'Une seule messe',
      ),
      MassTypeRepetitionData(
        code: 'many',
        name: 'Plusieurs messes',
      ),
    ];
    massRequestTypeRepetitionSelected.value =
        massRequestTypeRepetitions.firstWhereOrNull((p0) => p0?.code == 'once');
  }

  moveToPayment(MassRequestResponse massRequestResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: massRequestResponse.toJson(),
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }

  resetChooseDate() {
    worshipHours.clear();
    datesChoosen.clear();
    Get.delete<FilterMassRequestDateController>(force: true);
  }

  goToDatesChoice() async {
    if (paroisseSelected.value.identifier == null) {
      return;
    }
    if (worshipHours.isEmpty) {
      showNotification(
          message:
              'Aucun horaire disponible.\nVeuillez choisir une autre paroisse svp');
      return;
    }
    datesChoosen.value = await Get.toNamed(
        Routes.FILTER_MASS_REQUEST_CHOOSE_DATE,
      arguments: [
        worshipHours,
        selectedDate.toJson(),
      ],);
    datesChoosen.refresh();
    if (datesChoosen.isNotEmpty) {
      doGetMassRequestPrice();
    } else {
      resetPrice();
    }
    checkForm();
  }

  goToWorshipChoice() async {
    paroisseSelected = await Get.toNamed(
      Routes.FILTER_MASS_REQUEST_CHOOSE_WORSHIP,
      arguments: 'Demande de messe',
    );
    log('goToWorshipChoice ::: ${paroisseSelected.value.identifier}');
    if (paroisseSelected.value.identifier != null) {
      paroisseSelected.refresh();
      resetChooseDate();
      doGetPlaceOfWorshipHours();
    }
    checkForm();
  }

  void checkForm() {
    isValidForm.value = massRequestTypeSelected.value != null &&
        massIntentionController.text.isNotEmpty &&
        price.value != '-';
    update();
  }

  RxString getPrice() {
    if (price.value == '-') return '-'.obs;
    return '${price.value.amountFormat()} FCFA'.obs;
  }

  updateMassTypeFilter(TypeData? typeData) {
    massRequestTypeSelected.value = typeData;
    massIntentionController.text = "${typeData?.template?.fr ?? ''} ";
    checkForm();
  }

  updatePrayerIntentFilter(PrayerIntentData? prayerIntentData) {
    prayerIntentSelected.value = prayerIntentData;
    massIntentionController.text = prayerIntentData?.defaultText?.fr ?? '';
    checkForm();
  }

  String getTime(String value) {
    if (value.isEmpty) return '-';
    return '${value.split(':').first}:${value.split(':')[1]}';
  }

  void resetPrice() {
    price.value = '-';
  }

  updateMassTypeRepetitionHourFilter(Slot? slot) {
    selectedHour.value = slot;
    checkForm();
    if (selectedDate.value != null && selectedHour.value != null) {
      selectedDate.value?.slots = [selectedHour.value ?? Slot()];
      datesChoosen.value = [selectedDate.value ?? PriceData()];
      doGetMassRequestPrice();
    }
  }

  // Ouvrir un date picker qui ne permet que les dates calculées
  Future<void> showPicker(BuildContext context) async {
    // Normaliser les dates de _allowedDates pour ne garder que l'année, le mois et le jour
    final allowedDatesNormalized = allowedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();

    // S'assurer que la première date dans _allowedDates est valide comme initialDate
    DateTime initialDate = allowedDatesNormalized.firstWhere(
          (date) => date.isAfter(DateTime.now()) || date.isAtSameMomentAs(DateTime.now()),
      orElse: () => allowedDatesNormalized.first,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // On utilise une date initiale valide
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: AppConstants.END_DATE_LIMIT)),
      selectableDayPredicate: (DateTime day) {
        // Comparer seulement année, mois et jour (ignorer les heures)
        DateTime normalizedDay = DateTime(day.year, day.month, day.day);
        return allowedDatesNormalized.contains(normalizedDay);
      },
    );
    if (picked != null) {
      resetPrice();
      updateRepetitionFilter(picked, isFirst: false);

      /*String day = picked.day.toString();
      String month = picked.month.toString();
      if (picked.day < 10) {
        day = "0$day";
      }
      if (picked.month < 10) {
        month = "0$month";
      }
      selectedDate.value = PriceData(
        day: "${picked.year}-$month-$day",
        dayOfWeek: picked.weekday.toString(),
        isDaySelected: true,
        dayToDisplay: "$day-$month-${picked.year}",
      );
      checkForm();*/
    }
  }


  updateRepetitionFilter(DateTime datetime,
      {bool? isFirst = true, Slot? selectHour}) {
    String day = datetime.day.toString();
    String month = datetime.month.toString();
    if (datetime.day < 10) {
      day = "0$day";
    }
    if (datetime.month < 10) {
      month = "0$month";
    }

    for (var i in worshipRecurrentHours) {
      log('worshipRecurrentHours ::: ${i.toJson()}\n');
    }

    List<Slot>? tempSlots = [];
    var recurentHour = worshipRecurrentHours.value.firstWhereOrNull((element) {
      log('element ::: ${element.dayOfWeek}');
      log('datetime.weekday ::: ${datetime.weekday - 1}');
      return int.parse(element.dayOfWeek ?? '0') == (datetime.weekday - 1);
    });
    log('tempSlotss ::: ${recurentHour?.toJson()}');
    tempSlots = recurentHour?.slots ?? [];
    log('tempSlots ::: ${tempSlots.length}');
    selectedHours.clear();
    for (var i in tempSlots) {
      log('tempSlots i ::: ${i.toJson()}\n');
      selectedHours.add(i);
    }
    log('selectedHours ::: ${selectedHours.length}\n');
    for (var i in selectedHours) {
      log('selectedHours ::: ${i?.toJson()}\n');
    }

    if (isFirst == true) {
      selectedHour.value = tempSlots.first;
    } else {
      selectedHour.value = selectHour;
    }

    selectedDate.value = PriceData(
      day: "${datetime.year}-$month-$day",
      dayOfWeek: datetime.weekday.toString(),
      isDaySelected: true,
      dayToDisplay: "$day-$month-${datetime.year}",
      slots: [selectedHour.value ?? Slot()],
    );
    log('selectedDate ::: ${selectedDate.toJson()}');
    checkForm();
    if (selectedDate.value != null && selectedHour.value != null) {
      datesChoosen.value = [selectedDate.value ?? PriceData()];
      doGetMassRequestPrice();
    }
  }


  updateMassTypeRepetitionFilter(
      MassTypeRepetitionData? massTypeRepetitionData) {
    //selectedHour.value = null;
    datesChoosen.clear();
    massRequestTypeRepetitionSelected.value = massTypeRepetitionData;
    checkForm();
    if (selectedDate.value != null &&
        selectedHour.value != null &&
        massRequestTypeRepetitionSelected.value?.code == 'once') {
      selectedDate.value?.slots = [selectedHour.value ?? Slot()];
      datesChoosen.value = [selectedDate.value ?? PriceData()];
      doGetMassRequestPrice();
    } else {
      resetPrice();
    }
  }

  doGetMassRequestType() {
    hideKeyboard();

    log('request doGetMassRequestType');
    massRequestRepository.getMassRequestType(page: 0).then((value) {
      if (value.isNotEmpty == true) {
        massRequestTypes.value = value;
        var massRequestTypeSelected = value
            .firstWhereOrNull((element) => element.code == 'ACTION_OF_GRACE');
        updateMassTypeFilter(massRequestTypeSelected);
      }
      update();
    }, onError: (error) {
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
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
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  doGetPlaceOfWorshipHours() {
    hideKeyboard();

    log('request doGetPlaceOfWorshipHours');
    isDatesProcessing(true);
    paroisseRepository
        .getLiturgicalCelebration(paroisseSelected.value.identifier)
        .then((value) {
      isDatesProcessing(false);
      if (value.isNotEmpty == true) {
        worshipHours.value = value;
        worshipRecurrentHoursTemp.value = worshipHours
            .where((element) => element.isRecurrent == true)
            .toList();
        worshipSpecialHoursTemp.value = worshipHours
            .where((element) =>
        element.isRecurrent == false &&
            (Jiffy.parse(element.startDate ?? Jiffy.now().format(),
                pattern: AppConstants.TIME_ZONE_FORMAT)
                .isAfter(Jiffy.now().add(hours: 24))))
            .toList();

        worshipRecurrentHours.value =
            transformWorshipRecurrentHours(worshipRecurrentHoursTemp);
        worshipSpecialHours.value =
            transformWorshipSpecialHours(worshipSpecialHoursTemp);

        List<int> temp = [];
        temp = worshipRecurrentHours.value
            .map((element) => int.parse(element.dayOfWeek ?? '0') + 1)
            .toList();
        allowedDates.value = getNextDatesForDays(temp);
        DateTime datetime = allowedDates.value.firstWhere(
                (date) =>
            date.isAfter(DateTime.now()) ||
                date.isAtSameMomentAs(DateTime.now()),
            orElse: () => allowedDates
                .first); // Utiliser la première date valide de _allowedDates

        updateRepetitionFilter(datetime);
      }
    }, onError: (error) {
      isDatesProcessing(false);
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
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

    isPricingProcessing(true);
    hasData(false);
    log('request doGetMassRequestPrice');
    massRequestRepository
        .getMassRequestPrice(
            request: datesChoosen,
            workshipId: paroisseSelected.value.identifier.toString())
        .then((value) {
      isPricingProcessing(false);
      hasData(true);
      price.value = value.price.toString();
      checkForm();
    }, onError: (error) {
      isPricingProcessing(false);
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
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = MassRequestData(
      prayerIntent: massIntentionController.text.isNotEmpty
          ? massIntentionController.text
          : prayerIntentSelected.value?.defaultText?.fr,
      typeOfMassRequest: massRequestTypeSelected.value?.code,
      slots: datesChoosen,
      worshipPlace: paroisseSelected.value.identifier,
    );

    log('request doSendMassRequest => ${jsonEncode(request.toJson())}');

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
        showNotification(
            message: err.message.toString(),
            duration: const Duration(seconds: 4));
      }
    });
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
