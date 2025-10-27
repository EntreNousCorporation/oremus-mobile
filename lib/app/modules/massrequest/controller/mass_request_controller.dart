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
        'payment_type': PaymentType.massRequest,
      },
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
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
      barrierDismissible: false,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                onPrimary: colorWhite,
                onSurface: colorBlack,
                primary: colorGreen
            ),
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
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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

  @Deprecated('No longer used')
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
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
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

    // Convertir jour de la semaine standard (1-7, lundi-dimanche) vers votre système (0-6, lundi-dimanche)
    // Dans votre système: 0=lundi, 1=mardi, 2=mercredi, 3=jeudi, 4=vendredi, 5=samedi, 6=dimanche
    final currentDayOfWeekSystem = now.weekday - 1; // weekday: 1=lundi, 7=dimanche

    // Déterminer si nous sommes avant ou après midi
    final isBefore12h = now.hour < 12;

    log('Jour actuel: ${now.weekday} (${getDay(now.weekday)}), converti en système: $currentDayOfWeekSystem');
    log('Avant midi: $isBefore12h');

    // Variables pour stocker la date et l'heure cibles selon les règles
    DateTime targetDate;
    int targetHour;
    int targetDayOfWeekStandard; // Format standard (1-7, lundi-dimanche)

    // Appliquer les règles du tableau
    switch (now.weekday) { // Utiliser le format standard weekday (1-7)
      case 7: // Dimanche (tout le jour) -> Mardi 12h
        targetDayOfWeekStandard = 2; // Mardi
        targetHour = 12;
        break;
      case 1: // Lundi (tout le jour) -> Mardi 12h
        targetDayOfWeekStandard = 2; // Mardi
        targetHour = 12;
        break;
      case 2: // Mardi
        if (isBefore12h) {
          targetDayOfWeekStandard = 2; // Même jour (mardi)
          targetHour = 16;
        } else {
          targetDayOfWeekStandard = 3; // Mercredi
          targetHour = 12;
        }
        break;
      case 3: // Mercredi
        if (isBefore12h) {
          targetDayOfWeekStandard = 3; // Même jour (mercredi)
          targetHour = 16;
        } else {
          targetDayOfWeekStandard = 4; // Jeudi
          targetHour = 12;
        }
        break;
      case 4: // Jeudi
        if (isBefore12h) {
          targetDayOfWeekStandard = 4; // Même jour (jeudi)
          targetHour = 16;
        } else {
          targetDayOfWeekStandard = 5; // Vendredi
          targetHour = 12;
        }
        break;
      case 5: // Vendredi
        if (isBefore12h) {
          targetDayOfWeekStandard = 5; // Même jour (vendredi)
          targetHour = 16;
        } else {
          targetDayOfWeekStandard = 6; // Samedi
          targetHour = 12;
        }
        break;
      case 6: // Samedi
        if (isBefore12h) {
          targetDayOfWeekStandard = 6; // Même jour (samedi)
          targetHour = 16;
        } else {
          targetDayOfWeekStandard = 2; // Mardi (semaine suivante)
          targetHour = 12;
        }
        break;
      default:
      // Fallback au cas où
        targetDayOfWeekStandard = now.weekday + 1 > 7 ? 1 : now.weekday + 1;
        targetHour = 12;
    }

    // Calculer la date cible basée sur le jour de la semaine cible
    targetDate = getNextSpecificWeekday(now, targetDayOfWeekStandard);

    log('Date cible selon règles: ${targetDate.toString()} (${getDay(targetDate.weekday)}), Heure cible: $targetHour');

    // Si la date sélectionnée (datetime) est différente de la date par défaut et après la date minimale,
    // utiliser la date sélectionnée en gardant les règles d'heure
    if (!isFirst && datetime != targetDate && !datetime.isBefore(targetDate)) {
      targetDate = datetime;
      log('Utilisation de la date sélectionnée: ${targetDate.toString()} (${getDay(targetDate.weekday)})');
    }

    // Vérifier si des messes sont disponibles à cette date
    if (!hasMassesAvailable(targetDate)) {
      log('Aucune messe disponible pour ${targetDate.toString()} (${getDay(targetDate.weekday)})');

      // Chercher la prochaine date avec des messes disponibles en commençant par la date cible
      DateTime nextDate = findNextDateWithMasses(targetDate);

      if (nextDate != targetDate) {
        targetDate = nextDate;
        log('Prochaine date avec messes disponibles: ${targetDate.toString()} (${getDay(targetDate.weekday)})');
      }
    }

    // Formater la date pour l'affichage et pour les requêtes
    final formattedDay = targetDate.day.toString().padLeft(2, '0');
    final formattedMonth = targetDate.month.toString().padLeft(2, '0');
    final formattedTargetDate = "${targetDate.year}-$formattedMonth-$formattedDay";

    // Récupérer tous les slots disponibles pour cette date
    List<Slot> allSlots = [];

    // Conversion vers votre système: targetDate.weekday (1-7) -> votre système (0-6)
    final targetDayOfWeekSystem = targetDate.weekday - 1;

    // Ajouter les horaires récurrents pour le jour de la semaine
    final recurentHour = worshipRecurrentHours.firstWhereOrNull(
            (element) => int.parse(element.dayOfWeek ?? '-1') == targetDayOfWeekSystem
    );

    if (recurentHour != null && recurentHour.slots != null) {
      log('Messes récurrentes trouvées pour ${getDay(targetDate.weekday)}: ${recurentHour.slots?.length ?? 0}');
      allSlots.addAll(recurentHour.slots ?? []);
    }

    // Ajouter les horaires spéciaux pour cette date spécifique
    final specialHour = worshipSpecialHours.firstWhereOrNull(
            (element) => element.day == formattedTargetDate
    );

    if (specialHour != null && specialHour.slots != null) {
      log('Messes spéciales trouvées pour $formattedTargetDate: ${specialHour.slots?.length ?? 0}');
      allSlots.addAll(specialHour.slots ?? []);
    }

    log('Nombre total de slots trouvés: ${allSlots.length}');

    // Trier les slots par heure
    allSlots.sort((a, b) {
      final timeA = parseTimeFromString(a.startTime ?? '00:00:00');
      final timeB = parseTimeFromString(b.startTime ?? '00:00:00');
      return timeA.hour * 60 + timeA.minute - (timeB.hour * 60 + timeB.minute);
    });

    List<Slot> filteredSlots = [];

    // CORRECTION : Si l'utilisateur a sélectionné manuellement une date,
    // afficher TOUS les créneaux disponibles sans filtrage
    if (!isFirst) {
      filteredSlots = List.from(allSlots);
      log('Date sélectionnée manuellement : affichage de tous les créneaux (${filteredSlots.length})');
    } else {
      // Sinon, appliquer la logique de filtrage selon l'heure cible (pour la sélection automatique initiale)
      Slot? closestSlot;
      int? minDifference;

      for (var slot in allSlots) {
        final slotTime = parseTimeFromString(slot.startTime ?? '00:00:00');

        // Si nous avons un créneau exact à l'heure cible, le sélectionner directement
        if (slotTime.hour == targetHour) {
          closestSlot = slot;
          minDifference = 0;
          break;
        }

        // Sinon, trouver le créneau le plus proche de l'heure cible
        // Selon le tableau, nous préférons les créneaux après l'heure cible
        int difference = slotTime.hour - targetHour;

        // Pour les créneaux avant l'heure cible, augmenter artificiellement la différence
        // pour favoriser les créneaux après l'heure cible (comme indiqué dans le tableau)
        if (difference < 0) {
          difference = difference + 24; // Ajouter 24 pour mettre à la fin de la liste
        }

        if (minDifference == null || difference < minDifference) {
          minDifference = difference;
          closestSlot = slot;
        }
      }

      // Si on a trouvé un créneau proche, l'utiliser, sinon prendre tous les créneaux
      if (closestSlot != null) {
        filteredSlots = [closestSlot];
        log('Sélection automatique du créneau le plus proche de ${targetHour}h: ${closestSlot.startTime}');
      } else if (allSlots.isNotEmpty) {
        // Si aucun créneau ne correspond à notre logique, prendre tous les créneaux disponibles
        filteredSlots = List.from(allSlots);
        log('Aucun créneau proche trouvé, utilisation de tous les créneaux disponibles');
      }
    }

    // Mettre à jour les heures disponibles
    selectedHours.clear();
    selectedHours.addAll(filteredSlots);
    selectedHours.refresh();

    log('Heures disponibles après filtrage: ${selectedHours.length}');
    if (selectedHours.isNotEmpty) {
      log('Créneaux disponibles: ${selectedHours.map((s) => s?.startTime ?? "").join(", ")}');
    }

    // Sélectionner l'heure
    if (selectedHours.isNotEmpty) {
      if (isFirst || selectedHour.value == null) {
        selectedHour.value = selectedHours.first;
        log('Sélection de la première heure disponible: ${selectedHour.value?.startTime}');
      } else if (selectHour != null) {
        selectedHour.value = selectHour;
        log('Sélection de l\'heure spécifiée: ${selectedHour.value?.startTime}');
      } else if (!selectedHours.contains(selectedHour.value)) {
        selectedHour.value = selectedHours.first;
        log('L\'heure précédente n\'est plus disponible, sélection de la première heure: ${selectedHour.value?.startTime}');
      }
      selectedHour.refresh();
    } else {
      selectedHour.value = null;
      log('Aucune heure disponible après filtrage');
    }

    // Mettre à jour la date sélectionnée
    selectedDate.value = PriceData(
      day: formattedTargetDate,
      dayOfWeek: (targetDate.weekday - 1).toString(), // Conversion vers votre système
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

// Méthode pour obtenir le prochain jour de la semaine spécifique
  DateTime getNextSpecificWeekday(DateTime date, int targetWeekday) {
    DateTime result = date;

    // Ajuster pour que targetWeekday soit de 1-7 où 1 est lundi (format standard de DateTime)
    if (targetWeekday == 0) targetWeekday = 7; // Dimanche

    // Calculer combien de jours ajouter pour atteindre le jour cible
    int daysToAdd = targetWeekday - date.weekday;
    if (daysToAdd <= 0) daysToAdd += 7; // Si le jour cible est aujourd'hui ou avant, passer à la semaine suivante

    result = result.add(Duration(days: daysToAdd));
    return result;
  }

// Fonction pour vérifier si deux dates sont le même jour
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

// Fonction pour analyser une heure à partir d'une chaîne "HH:MM:SS"
  DateTime parseTimeFromString(String timeString) {
    try {
      final parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      int second = parts.length > 2 ? int.parse(parts[2]) : 0;

      return DateTime(2000, 1, 1, hour, minute, second);
    } catch (e) {
      log('Erreur lors du parsing de l\'heure: $timeString - $e');
      return DateTime(2000, 1, 1, 0, 0, 0);
    }
  }

// Vérifier si des messes sont disponibles pour une date donnée
  bool hasMassesAvailable(DateTime date) {
    // Convertir en jour de la semaine dans votre système (0-6, lundi-dimanche)
    final dayOfWeekSystem = date.weekday - 1;

    // Format de date "yyyy-MM-dd" pour les messes spéciales
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // Vérifier les messes récurrentes
    bool hasRecurrent = worshipRecurrentHours.any(
            (hour) => int.parse(hour.dayOfWeek ?? '-1') == dayOfWeekSystem &&
            (hour.slots?.isNotEmpty ?? false)
    );

    // Vérifier les messes spéciales
    bool hasSpecial = worshipSpecialHours.any(
            (hour) => hour.day == formattedDate &&
            (hour.slots?.isNotEmpty ?? false)
    );

    return hasRecurrent || hasSpecial;
  }

// Trouver la prochaine date avec des messes disponibles
  DateTime findNextDateWithMasses(DateTime startDate) {
    DateTime checkDate = startDate;

    // Chercher pendant 30 jours maximum
    for (int i = 0; i < 30; i++) {
      if (hasMassesAvailable(checkDate)) {
        return checkDate;
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    // Si aucune messe n'est trouvée, retourner la date de départ
    return startDate;
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

        // Filtrer les messes récurrentes (exclure les confessions)
        worshipRecurrentHoursTemp.value = worshipHours
            .where((element) => 
                element.isRecurrent == true && 
                element.type?.code != AppConstants.CONFESSION &&
                element.type?.code != AppConstants.SPECIAL_CONFESSION)
            .toList();

        // Filtrer les messes spéciales non expirées (24h à l'avance) et exclure les confessions
        worshipSpecialHoursTemp.value = worshipHours
            .where((element) =>
        element.isRecurrent == false &&
            element.type?.code != AppConstants.CONFESSION &&
            element.type?.code != AppConstants.SPECIAL_CONFESSION &&
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
