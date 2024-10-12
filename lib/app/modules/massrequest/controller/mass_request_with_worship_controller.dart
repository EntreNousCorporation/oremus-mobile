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

  RxList<MassTypeRepetitionData?> massRequestTypeRepetitions =
      RxList<MassTypeRepetitionData?>([]);
  Rx<MassTypeRepetitionData?> massRequestTypeRepetitionSelected =
      Rx<MassTypeRepetitionData?>(null);

  RxList<LiturgicalCelebrationResponse> worshipRecurrentHoursTemp =
      RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipRecurrentHours = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipSpecialHoursTemp =
      RxList<LiturgicalCelebrationResponse>([]);
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
      ],
    );
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
        price.value != '-' && price.value != '0.0' && price.value != '0' &&
        (massRequestTypeRepetitionSelected.value?.code == 'many'
            ? datesChoosen.isNotEmpty
            : selectedDate.value != null);
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
    DateTime now = DateTime.now();
    DateTime initialDate = allowedDatesNormalized.firstWhere(
          (date) => date.isAfter(DateTime(now.year, now.month, now.day)) || date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
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
    }
  }

  updateRepetitionFilter(DateTime datetime, {bool? isFirst = true, Slot? selectHour}) {
    String day = datetime.day.toString();
    String month = datetime.month.toString();

    // Formatage du jour et du mois
    if (datetime.day < 10) {
      day = "0$day";
    }
    if (datetime.month < 10) {
      month = "0$month";
    }

    // Récupérer les heures récurrentes pour le jour sélectionné
    var recurentHour = worshipRecurrentHours.value.firstWhereOrNull((element) {
      return int.parse(element.dayOfWeek ?? '0') == (datetime.weekday - 1);
    });

    // Vérifier s'il y a des créneaux horaires disponibles pour ce jour
    List<Slot>? tempSlots = recurentHour?.slots ?? [];
    selectedHours.clear();
    for (var i in tempSlots) {
      selectedHours.add(i);
    }

    // Récupérer l'heure actuelle
    DateTime now = DateTime.now();

    // Calculer la date "logique" selon les règles du tableau (exemple avec 12h ou 18h)
    DateTime logicalDate = now;
    if (now.hour >= 0 && now.hour <= 9) {
      logicalDate = DateTime(now.year, now.month, now.day, 12); // Même jour à 12h
    } else if (now.hour > 9 && now.hour <= 15) {
      logicalDate = DateTime(now.year, now.month, now.day, 18); // Même jour à 18h
    } else {
      logicalDate = DateTime(now.year, now.month, now.day + 1, 12); // Lendemain à 12h
    }

    // Si la date passée en paramètre est après la date logique, on ignore les restrictions
    if (datetime.isAfter(logicalDate)) {
      log('Date future détectée, afficher toutes les heures disponibles');
      selectedHours.clear(); // Vider et réajouter toutes les heures disponibles
      for (var i in tempSlots) {
        selectedHours.add(i); // Ajouter tous les créneaux horaires disponibles
      }
    } else {
      // Appliquer les restrictions du tableau si la date est "logique" (comme aujourd'hui)
      if (now.hour >= 0 && now.hour <= 9) {
        // Entre 00h01 et 09h00, afficher les créneaux à partir de 12h00
        selectedHours.removeWhere((slot) {
          TimeOfDay slotTime = parseTime(slot?.startTime ?? '');
          return slotTime.hour < 12;
        });
      } else if (now.hour > 9 && now.hour <= 15) {
        // Entre 09h01 et 15h00, afficher les créneaux à partir de 18h00
        selectedHours.removeWhere((slot) {
          TimeOfDay slotTime = parseTime(slot?.startTime ?? '');
          return slotTime.hour < 18;
        });
      } else {
        // Entre 15h01 et 00h00, afficher les créneaux à partir de 12h00 le lendemain
        datetime = datetime.add(const Duration(days: 1)); // Passer au lendemain
        recurentHour = worshipRecurrentHours.value.firstWhereOrNull((element) {
          return int.parse(element.dayOfWeek ?? '0') == (datetime.weekday - 1);
        });
        tempSlots = recurentHour?.slots ?? [];
        selectedHours.clear();
        for (var i in tempSlots) {
          TimeOfDay slotTime = parseTime(i.startTime ?? '');
          if (slotTime.hour >= 12) {
            selectedHours.add(i); // Ajouter seulement les créneaux après 12h
          }
        }
      }
    }

    // Sélection du créneau horaire

    // Trier les heures dans selectedHours pour obtenir la plus petite
    if (selectedHours.isNotEmpty) {
      selectedHours.sort((a, b) {
        TimeOfDay timeA = parseTime(a?.startTime ?? '');  // Convertir le créneau A en TimeOfDay
        TimeOfDay timeB = parseTime(b?.startTime ?? '');  // Convertir le créneau B en TimeOfDay
        return compareTimes(timeA, timeB);         // Comparer les deux heures
      });
    }

    if (isFirst == true) {
      // Sélectionner le créneau avec la plus petite heure
      selectedHour.value = selectedHours.first;
    } else {
      selectedHour.value = selectHour;
    }

    // Mise à jour des informations sélectionnées
    selectedDate.value = PriceData(
      day: "${datetime.year}-$month-$day",
      dayOfWeek: datetime.weekday.toString(),
      isDaySelected: true,
      dayToDisplay: "$day-$month-${datetime.year}",
      slots: [selectedHour.value ?? Slot()],
    );

    log('selectedDate ::: ${selectedDate.toJson()}');

    // Vérifier si la sélection est valide
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
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day); // Ignorer les heures

        DateTime datetime = allowedDates.value.firstWhere(
              (date) =>
          date.isAfter(today) || date.isAtSameMomentAs(today),
          orElse: () => allowedDates.first,
        ); // Utiliser la première date valide de _allowedDates

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
    log('request doGetMassRequestPrice ::: ${jsonEncode(datesChoosen)}');
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
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
