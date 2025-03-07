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
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
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

  // Ajout d'une propriété pour stocker l'état des sélections
  final RxSet<String> savedSelectedSlotKeys = <String>{}.obs;
  final RxList<PriceData> savedWorshipRecurrentHours = RxList<PriceData>([]);
  final RxList<PriceData> savedWorshipSpecialHours = RxList<PriceData>([]);

  Rx<PriceData?> savedEndDate = Rx<PriceData?>(null);
  var savedSpecialMasses;

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
    // Attendre 500 millisecondes avant de donner le focus au TextField
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
      arguments: {
        'payment_response': massRequestResponse.toJson(),
        'payment_type': PaymentType.donation,
      },
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
      List<String> dateParts = selectedDate.value!.dayToDisplay?.split('-') ?? [];
      DateTime selectedDateTime = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0])
      );

      if (allowedDatesNormalized.contains(DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day
      ))) {
        initialDate = selectedDateTime;
      } else {
        initialDate = allowedDatesNormalized.firstWhere(
                (date) => date.isAfter(DateTime(now.year, now.month, now.day)) ||
                date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
            orElse: () => allowedDatesNormalized.first
        );
      }
    } else {
      initialDate = allowedDatesNormalized.firstWhere(
              (date) => date.isAfter(DateTime(now.year, now.month, now.day)) ||
              date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
          orElse: () => allowedDatesNormalized.first
      );
    }

    final DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: initialDate,
      firstDate: allowedDatesNormalized.reduce((a, b) => a.isBefore(b) ? a : b),
      lastDate: allowedDatesNormalized.reduce((a, b) => a.isAfter(b) ? a : b),
      selectableDayPredicate: (DateTime day) {
        DateTime normalizedDay = DateTime(day.year, day.month, day.day);
        return allowedDatesNormalized.contains(normalizedDay);
      },
      cancelText: 'cancel'.tr,
      confirmText: 'confirm'.tr,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                onPrimary: colorWhite,
                onSurface: colorBlack,
                primary: colorGreen
            ),
            dialogBackgroundColor: Colors.white,
            // Personnaliser les boutons du Dialog
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) => colorWhite
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                    // Si le bouton est le bouton "Annuler"
                    if (states.contains(WidgetState.selected)) {
                      return colorBlack;
                    }
                    // Pour le bouton "Confirmer"
                    return colorGreen;
                  },
                ),
                textStyle: WidgetStateProperty.all(
                    TextStyles.montserratRegular(textSize: TextSizes.fourteen)
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(
                        color: Colors.transparent,
                        width: 1,
                        style: BorderStyle.solid
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      resetPrice();
      updateRepetitionFilter(picked, isFirst: false);
    }
  }

  Future<void> showPickerBack(BuildContext context) async {
    // Normaliser les dates permises
    final allowedDatesNormalized = allowedDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();

    // Obtenir la date actuelle
    DateTime now = DateTime.now();

    // Déterminer la date initiale du picker
    DateTime initialDate;
    if (selectedDate.value != null) {
      List<String> dateParts = selectedDate.value!.dayToDisplay?.split('-') ?? [];
      DateTime selectedDateTime = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0])
      );

      if (allowedDatesNormalized.contains(DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day
      ))) {
        initialDate = selectedDateTime;
      } else {
        initialDate = allowedDatesNormalized.firstWhere(
                (date) => date.isAfter(DateTime(now.year, now.month, now.day)) ||
                date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
            orElse: () => allowedDatesNormalized.first
        );
      }
    } else {
      initialDate = allowedDatesNormalized.firstWhere(
              (date) => date.isAfter(DateTime(now.year, now.month, now.day)) ||
              date.isAtSameMomentAs(DateTime(now.year, now.month, now.day)),
          orElse: () => allowedDatesNormalized.first
      );
    }

    DateTime? selectedPickedDate = initialDate;  // Variable pour stocker la date sélectionnée

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                onPrimary: colorWhite,
                onSurface: colorBlack,
                primary: colorGreen
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: allowedDatesNormalized.reduce((a, b) => a.isBefore(b) ? a : b),
                  lastDate: allowedDatesNormalized.reduce((a, b) => a.isAfter(b) ? a : b),
                  onDateChanged: (DateTime date) {
                    selectedPickedDate = date;  // Mettre à jour la date sélectionnée
                  },
                  selectableDayPredicate: (DateTime day) {
                    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                    return allowedDatesNormalized.contains(normalizedDay);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: colorWhite,
                          backgroundColor: colorBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('cancel'.tr),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: colorWhite,
                          backgroundColor: colorGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, selectedPickedDate);
                        },
                        child: Text('confirm'.tr),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        resetPrice();
        updateRepetitionFilter(value, isFirst: false);
      }
    });
  }

  String getTime(String value) {
    if (value.isEmpty) return '-';
    return '${value.split(':').first}:${value.split(':')[1]}';
  }

  goToDatesChoice() async {
    if (worshipHours.isEmpty) {
      showNotification(
          message: 'Aucun horaire de messe disponible.\nVeuillez choisir une autre paroisse svp');
      return;
    }

    // Préparer les arguments avec l'état sauvegardé
    final arguments = [
      worshipHours,
      selectedDate.toJson(),
      {
        'selectedSlotKeys': savedSelectedSlotKeys.toList(),
        'endDate': savedEndDate.toJson(),
        'specialMasses': savedSpecialMasses,
      }
    ];

    final result = await Get.toNamed(
      Routes.FILTER_MASS_REQUEST_CHOOSE_DATE,
      arguments: arguments,
    );

    if (result != null && result is Map) {
      // Mettre à jour avec le nouveau format de résultat
      datesChoosen.value = result['dates'] ?? [];
      savedEndDate.value = result['endDate'] != null
          ? PriceData.fromJson(result['endDate'])
          : null;
      savedSelectedSlotKeys.clear();
      savedSelectedSlotKeys.addAll(Set<String>.from(result['selectedSlotKeys'] ?? []));
      savedSpecialMasses = result['specialMasses'];

      datesChoosen.refresh();
      if (datesChoosen.isNotEmpty) {
        doGetMassRequestPrice();
      } else {
        resetPrice();
      }
      checkForm();
    } else {
      // Si on revient sans résultat (back button), réinitialiser le prix
      resetPrice();
      datesChoosen.clear();
      checkForm();
    }
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
    // Sauvegarder l'état précédent
    PriceData? previousSelectedDate = selectedDate.value;
    Slot? previousSelectedHour = selectedHour.value;
    String? previousPrice = price.value;
    List<PriceData?> previousDatesChoosen = List.from(datesChoosen);

    // Réinitialiser les données pour plusieurs messes
    if (massTypeRepetitionData?.code == RepetitionType.many.name) {
      datesChoosen.clear();
      resetPrice();
    }

    // Mettre à jour le type de répétition
    massRequestTypeRepetitionSelected.value = massTypeRepetitionData;

    // Restaurer l'état pour une seule messe ou réinitialiser pour plusieurs messes
    if (massTypeRepetitionData?.code == RepetitionType.once.name) {
      selectedDate.value = previousSelectedDate;
      selectedHour.value = previousSelectedHour;
      if (selectedDate.value != null && selectedHour.value != null) {
        selectedDate.value?.slots = [selectedHour.value ?? Slot()];
        datesChoosen.value = [selectedDate.value ?? PriceData()];
        price.value = previousPrice;
      }
    }

    // Vérifier le formulaire après avoir tout mis à jour
    checkForm();
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
    final timeRange = _determineTimeRange(now);

    // Normaliser les dates pour la comparaison
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final tomorrowNormalized = todayNormalized.add(const Duration(days: 1));
    final selectedDateNormalized = DateTime(datetime.year, datetime.month, datetime.day);

    // Déterminer la date cible selon les règles
    DateTime targetDate = datetime;

    // Vérifier si nous devons appliquer les règles de filtrage
    bool shouldApplyRules = false;

    if (selectedDateNormalized.isAtSameMomentAs(todayNormalized)) {
      // Pour aujourd'hui, on applique toujours les règles
      shouldApplyRules = true;

      // Si on est le soir, forcer le passage à demain
      if (timeRange == TimeRange.evening) {
        targetDate = tomorrowNormalized;
      }
    }
    // Pour demain, on applique les règles uniquement si on vient de basculer depuis le soir
    else if (selectedDateNormalized.isAtSameMomentAs(tomorrowNormalized) &&
        timeRange == TimeRange.evening &&
        !selectedDateNormalized.isAfter(tomorrowNormalized)) {
      shouldApplyRules = true;
    }

    // Formater la date pour l'affichage
    final formattedDay = targetDate.day.toString().padLeft(2, '0');
    final formattedMonth = targetDate.month.toString().padLeft(2, '0');
    final formattedTargetDate = "${targetDate.year}-$formattedMonth-$formattedDay";

    // Récupérer tous les slots disponibles pour cette date
    List<Slot> allSlots = [];

    // Ajouter les horaires récurrents
    final recurentHour = worshipRecurrentHours.firstWhereOrNull(
            (element) => int.parse(element.dayOfWeek ?? '0') == (targetDate.weekday - 1)
    );
    if (recurentHour != null) {
      allSlots.addAll(recurentHour.slots ?? []);
    }

    // Ajouter les horaires spéciaux
    final specialHour = worshipSpecialHours.firstWhereOrNull(
            (element) => element.day == formattedTargetDate
    );
    if (specialHour != null) {
      allSlots.addAll(specialHour.slots ?? []);
    }

    // Filtrer les slots selon les règles
    List<Slot> filteredSlots = List.from(allSlots);

    if (shouldApplyRules) {
      switch (timeRange) {
        case TimeRange.morning:
        // Entre 00h01 et 09h00 : messes à partir de 12h le même jour
          filteredSlots = allSlots.where((slot) {
            final slotTime = parseTime(slot.startTime ?? '');
            return slotTime.hour >= 12;
          }).toList();
          break;

        case TimeRange.afternoon:
        // Entre 09h01 et 15h00 : messes à partir de 18h le même jour
          filteredSlots = allSlots.where((slot) {
            final slotTime = parseTime(slot.startTime ?? '');
            return slotTime.hour >= 18;
          }).toList();
          break;

        case TimeRange.evening:
        // Entre 15h01 et 00h00 : messes à partir de 12h le lendemain
          filteredSlots = allSlots.where((slot) {
            final slotTime = parseTime(slot.startTime ?? '');
            return slotTime.hour >= 12;
          }).toList();
          break;
      }
    }

    // Trier les slots
    filteredSlots.sort((a, b) {
      final timeA = parseTime(a.startTime ?? '');
      final timeB = parseTime(b.startTime ?? '');
      return compareTimes(timeA, timeB);
    });

    // Mettre à jour les heures disponibles
    selectedHours.clear();
    selectedHours.addAll(filteredSlots);
    selectedHours.refresh();

    // Sélectionner l'heure
    if (selectedHours.isNotEmpty) {
      if (isFirst || selectedHour.value == null) {
        selectedHour.value = selectedHours.first;
      } else if (selectHour != null) {
        selectedHour.value = selectHour;
      } else if (!selectedHours.contains(selectedHour.value)) {
        selectedHour.value = selectedHours.first;
      }
      selectedHour.refresh();
    } else {
      selectedHour.value = null;
    }

    // Mettre à jour la date sélectionnée
    selectedDate.value = PriceData(
      day: formattedTargetDate,
      dayOfWeek: targetDate.weekday.toString(),
      isDaySelected: true,
      dayToDisplay: "$formattedDay-$formattedMonth-${targetDate.year}",
      slots: selectedHour.value != null ? [selectedHour.value!] : [],
    );
    selectedDate.refresh();
    // Après avoir mis à jour la date et l'heure sélectionnées
    if (selectedHour.value != null && selectedDate.value != null) {
      // Mettre à jour datesChoosen avec une seule date
      datesChoosen.value = [selectedDate.value ?? PriceData()];
      // Appeler le service de prix
      doGetMassRequestPrice();
    }
    update();
  }

  /// Détermine la plage horaire en fonction de l'heure actuelle
  TimeRange _determineTimeRange(DateTime now) {
    final currentTime = now.hour * 60 + now.minute;  // Convertir en minutes

    if (currentTime > 0 && currentTime <= 9 * 60) {
      return TimeRange.morning;     // 00:01-09:00
    }
    if (currentTime > 9 * 60 && currentTime <= 15 * 60) {
      return TimeRange.afternoon;   // 09:01-15:00
    }
    return TimeRange.evening;       // 15:01-00:00
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

        // Filtrer les messes récurrentes
        worshipRecurrentHoursTemp.value = worshipHours
            .where((element) => element.isRecurrent == true)
            .toList();

        // Filtrer les messes spéciales non expirées (24h à l'avance)
        worshipSpecialHoursTemp.value = worshipHours
            .where((element) =>
        element.isRecurrent == false &&
            (Jiffy.parse(element.startDate ?? Jiffy.now().format(),
                pattern: AppConstants.TIME_ZONE_FORMAT)
                .isAfter(Jiffy.now().add(hours: 24))))
            .toList();

        worshipRecurrentHours.value = transformWorshipRecurrentHours(worshipRecurrentHoursTemp);
        worshipSpecialHours.value = transformWorshipSpecialHours(worshipSpecialHoursTemp);

        // Obtenir les dates autorisées pour les messes récurrentes
        List<int> recurringDays = worshipRecurrentHours
            .map((element) => int.parse(element.dayOfWeek ?? '0') + 1)
            .toList();
        List<DateTime> recurringDates = getNextDatesForDays(recurringDays);

        // Obtenir les dates pour les messes spéciales
        List<DateTime> specialDates = worshipSpecialHours
            .map((element) => Jiffy.parse(element.day ?? '', pattern: "yyyy-MM-dd").dateTime)
            .toList();

        // Combiner les dates récurrentes et spéciales
        Set<DateTime> allDates = {...recurringDates, ...specialDates};

        // Trier les dates
        allowedDates.value = allDates.toList()..sort();

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        DateTime datetime = allowedDates.value.firstWhere(
              (date) => date.isAfter(today) || date.isAtSameMomentAs(today),
          orElse: () => allowedDates.first,
        );

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
