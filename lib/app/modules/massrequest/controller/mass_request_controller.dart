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
import 'package:oremusapp/app/commons/enums.dart';
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

  var isPricingProcessing = false.obs;
  var isDatesProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  late TextEditingController massIntentionController;
  var massIntentionFocusNode = FocusNode();

  RxList<TypeData?> massRequestTypes = RxList<TypeData?>([]);
  Rx<TypeData?> massRequestTypeSelected = Rx<TypeData?>(null);
  RxList<MassTypeRepetitionData?> massRequestTypeRepetitions =
      RxList<MassTypeRepetitionData?>([]);
  Rx<MassTypeRepetitionData?> massRequestTypeRepetitionSelected =
      Rx<MassTypeRepetitionData?>(null);

  RxList<PrayerIntentData?> prayerIntents = RxList<PrayerIntentData?>([]);
  Rx<PrayerIntentData?> prayerIntentSelected = Rx<PrayerIntentData?>(null);

  RxList<PriceData?> datesChoosen = RxList<PriceData?>([]);

  RxList<LiturgicalCelebrationResponse> worshipHours =
      RxList<LiturgicalCelebrationResponse>([]);

  RxList<LiturgicalCelebrationResponse> worshipRecurrentHoursTemp =
      RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipRecurrentHours = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipSpecialHoursTemp =
      RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipSpecialHours = RxList<PriceData>([]);

  var allowedDates = RxList<DateTime>([]);
  var selectedDate = Rx<PriceData?>(null);
  var selectedHours = RxList<Slot?>([]);
  var selectedHour = Rx<Slot?>(null);

  var isValidForm = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var massRequestSelected = MassRequestResponse().obs;
  var price = '-'.obs;

  @override
  void onInit() {
    getArguments();
    initControllers();
    doGetMassRequestType();
    doGetPlaceOfWorshipHours();
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

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[0]);
      log('arguments ::: ${jsonEncode(Get.arguments[0])}');
      log('paroisseSelected :::${jsonEncode(paroisseSelected.value)}');
      if (Get.arguments[1] != null) {
        massRequestSelected.value =
            MassRequestResponse.fromJson(Get.arguments[1]);
      }
    }
  }

  initMassTypeRepetitions() {
    massRequestTypeRepetitions.value = [
      MassTypeRepetitionData(
        code: RepetitionType.once.name,
        name: 'Une seule messe',
      ),
      MassTypeRepetitionData(
        code: RepetitionType.many.name,
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

  // Ouvrir un date picker qui ne permet que les dates calculées
  Future<void> showPicker(BuildContext context) async {
    // Normaliser les dates permises
    final allowedDatesNormalized = allowedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();

    // Obtenir la date actuelle
    DateTime now = DateTime.now();

    // Déterminer la date initiale du picker
    DateTime initialDate;
    if (selectedDate.value != null) {
      // Si une date est déjà sélectionnée, on l'utilise comme date initiale
      // On parse d'abord la date depuis le format "dd-MM-yyyy"
      List<String> dateParts = selectedDate.value!.dayToDisplay?.split('-') ?? [];
      DateTime selectedDateTime = DateTime(
          int.parse(dateParts[2]),  // année
          int.parse(dateParts[1]),  // mois
          int.parse(dateParts[0])   // jour
      );

      // Vérifier si cette date est toujours valide
      if (allowedDatesNormalized.contains(DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day
      ))) {
        initialDate = selectedDateTime;
      } else {
        // Si la date sélectionnée n'est plus valide, on prend la prochaine date disponible
        initialDate = allowedDatesNormalized.firstWhere(
                (date) => date.isAfter(DateTime(now.year, now.month, now.day)) ||
                date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
            orElse: () => allowedDatesNormalized.first
        );
      }
    } else {
      // Si aucune date n'est sélectionnée, on prend la prochaine date disponible
      initialDate = allowedDatesNormalized.firstWhere(
              (date) => date.isAfter(DateTime(now.year, now.month, now.day)) ||
              date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
          orElse: () => allowedDatesNormalized.first
      );
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: allowedDatesNormalized.reduce((a, b) => a.isBefore(b) ? a : b), // La plus petite date autorisée
      lastDate: allowedDatesNormalized.reduce((a, b) => a.isAfter(b) ? a : b),   // La plus grande date autorisée
      selectableDayPredicate: (DateTime day) {
        DateTime normalizedDay = DateTime(day.year, day.month, day.day);
        return allowedDatesNormalized.contains(normalizedDay);
      },
    );

    if (picked != null) {
      resetPrice();
      updateRepetitionFilter(picked, isFirst: false);
    }
  }

  String getTime(String value) {
    if (value.isEmpty) return '-';
    return '${value.split(':').first}:${value.split(':')[1]}';
  }

  goToDatesChoice() async {
    if (worshipHours.isEmpty) {
      showNotification(
          message:
              'Aucun horaire de messe disponible.\nVeuillez choisir une autre paroisse svp');
      return;
    }
    var dc = await Get.toNamed(
      Routes.FILTER_MASS_REQUEST_CHOOSE_DATE,
      arguments: [
        worshipHours,
        selectedDate.toJson(),
      ],
    );
    datesChoosen.value = dc ?? [];
    datesChoosen.refresh();
    if (datesChoosen.isNotEmpty) {
      doGetMassRequestPrice();
    } else {
      resetPrice();
    }
    checkForm();
  }

  void resetPrice() {
    price.value = '-';
  }

  void checkForm() {
    isValidForm.value = massRequestTypeSelected.value != null &&
        massIntentionController.text.isNotEmpty &&
        price.value != '-' &&
        price.value != '0.0' &&
        price.value != '0' &&
        (massRequestTypeRepetitionSelected.value?.code == RepetitionType.once.name
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

  updateMassTypeRepetitionFilter(
      MassTypeRepetitionData? massTypeRepetitionData) {
    datesChoosen.clear();
    massRequestTypeRepetitionSelected.value = massTypeRepetitionData;
    checkForm();
    if (selectedDate.value != null &&
        selectedHour.value != null &&
        massRequestTypeRepetitionSelected.value?.code == RepetitionType.once.name) {
      selectedDate.value?.slots = [selectedHour.value ?? Slot()];
      datesChoosen.value = [selectedDate.value ?? PriceData()];
      doGetMassRequestPrice();
    } else {
      resetPrice();
    }
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

  updatePrayerIntentFilter(PrayerIntentData? prayerIntentData) {
    prayerIntentSelected.value = prayerIntentData;
    massIntentionController.text = prayerIntentData?.defaultText?.fr ?? '';
    checkForm();
  }

  void updateRepetitionFilter(DateTime datetime, {bool isFirst = true, Slot? selectHour}) {
    final now = DateTime.now();
    log('=== DATE DEBUG START ===');
    log('Current date/time: ${now.toString()}');
    log('Input datetime parameter: ${datetime.toString()}');

    // 1. Déterminer la plage horaire
    final timeRange = _determineTimeRange(now);
    log('Time range: $timeRange');

    // 2. Déterminer si nous devons passer au lendemain
    final shouldUseNextDay = timeRange == TimeRange.evening;
    log('Should use next day: $shouldUseNextDay');

    // 3. Ajuster la date si nécessaire
    DateTime targetDate;
    if (shouldUseNextDay) {
      // Si la date en paramètre est aujourd'hui, on ajoute un jour
      if (datetime.year == now.year &&
          datetime.month == now.month &&
          datetime.day == now.day) {
        targetDate = datetime.add(const Duration(days: 1));
      } else {
        // Sinon on utilise la date en paramètre
        targetDate = datetime;
      }
    } else {
      targetDate = datetime;
    }

    log('Target date after adjustment: ${targetDate.toString()}');

    // 4. Formater la date pour l'affichage
    final formattedDay = targetDate.day.toString().padLeft(2, '0');
    final formattedMonth = targetDate.month.toString().padLeft(2, '0');

    // 5. Récupérer les horaires disponibles pour ce jour
    final recurentHour = worshipRecurrentHours.firstWhereOrNull(
            (element) => int.parse(element.dayOfWeek ?? '0') == (targetDate.weekday - 1)
    );
    log('Found slots for weekday ${targetDate.weekday - 1}');

    // 6. Filtrer et trier les créneaux disponibles
    selectedHours.clear();
    final filteredSlots = _filterAvailableSlots(
      slots: recurentHour?.slots ?? [],
      timeRange: timeRange,
    );
    selectedHours.addAll(filteredSlots);
    log('Available slots: ${selectedHours.map((s) => s?.startTime).join(', ')}');

    // 7. Sélectionner l'horaire
    if (selectedHours.isNotEmpty) {
      if (isFirst) {
        selectedHour.value = selectedHours.first;
      } else {
        selectedHour.value = selectHour;
      }
      log('Selected hour: ${selectedHour.value?.startTime}');
    }

    // 8. Mettre à jour la date sélectionnée
    selectedDate.value = PriceData(
      day: "${targetDate.year}-$formattedMonth-$formattedDay",
      dayOfWeek: targetDate.weekday.toString(),
      isDaySelected: true,
      dayToDisplay: "$formattedDay-$formattedMonth-${targetDate.year}",
      slots: [selectedHour.value ?? Slot()],
    );

    log('Final date to display: ${selectedDate.value?.dayToDisplay}');
    log('=== DATE DEBUG END ===');

    // 9. Mise à jour du formulaire et du prix
    checkForm();
    if (selectedDate.value != null && selectedHour.value != null) {
      datesChoosen.value = [selectedDate.value ?? PriceData()];
      doGetMassRequestPrice();
    }
  }

  /// Détermine la plage horaire en fonction de l'heure actuelle
  TimeRange _determineTimeRange(DateTime now) {
    final currentTime = now.hour * 60 + now.minute;  // Convertir en minutes

    if (currentTime >= 0 && currentTime <= 9 * 60) return TimeRange.morning;
    if (currentTime > 9 * 60 && currentTime <= 15 * 60) return TimeRange.afternoon;
    return TimeRange.evening;
  }

  /// Filtre les créneaux disponibles selon les règles
  List<Slot> _filterAvailableSlots({
    required List<Slot> slots,
    required TimeRange timeRange,
  }) {
    int minHour;
    switch (timeRange) {
      case TimeRange.morning:
        minHour = 12;
        break;
      case TimeRange.afternoon:
        minHour = 18;
        break;
      case TimeRange.evening:
        minHour = 12;
        break;
    }

    return slots.where((slot) {
      final slotTime = parseTime(slot.startTime ?? '');
      return slotTime.hour >= minHour;
    }).toList()
      ..sort((a, b) {
        final timeA = parseTime(a.startTime ?? '');
        final timeB = parseTime(b.startTime ?? '');
        return compareTimes(timeA, timeB);
      });
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
        DateTime today =
            DateTime(now.year, now.month, now.day); // Ignorer les heures

        DateTime datetime = allowedDates.value.firstWhere(
          (date) => date.isAfter(today) || date.isAtSameMomentAs(today),
          orElse: () => allowedDates.first,
        ); // Utiliser la première date valide de _allowedDates

        log('datetime ::: ${datetime.toIso8601String()}');
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

  doSendMassRequest({bool? forceDuplicateCreation}) {
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
      forceDuplicateCreation: forceDuplicateCreation,
    );

    log('request doSendMassRequest => ${jsonEncode(request.toJson())}');

    massRequestRepository.sendMassRequest(request: request).then(
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
                'Vous venez de faire une demande de messe identique. Souhaitez-vous confirmer cette demande ?',
            positiveLabel: 'OUI',
            positiveCallBack: () {
              doSendMassRequest(forceDuplicateCreation: true);
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
