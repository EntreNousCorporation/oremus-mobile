import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/custom_calendar_date_picker.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/recap_dialog.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';

class SelectionState {
  final String dayOfWeek;
  final String startTime;
  bool isSelected;

  SelectionState({
    required this.dayOfWeek,
    required this.startTime,
    this.isSelected = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectionState &&
          runtimeType == other.runtimeType &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime;

  @override
  int get hashCode => dayOfWeek.hashCode ^ startTime.hashCode;
}

class FilterMassRequestDateController extends GetxController with GetSingleTickerProviderStateMixin {
  FilterMassRequestDateController();

  late TabController tabController;

  RxList<TypeData> massRequestTypes = RxList<TypeData>([]);
  RxList<TypeData> massRequestTypesTemp = RxList<TypeData>([]);
  var massRequestTypeSelected = TypeData().obs;
  var unlockBackButton = true.obs;

  var isMassRequestDataProcessing = false.obs;
  var hasMassRequestData = false.obs;

  late TextEditingController typeMassRequestSearchController;

  var isMassRequestSearchFieldEmpty = true.obs;

  var searchCriteria = SearchCriteria().obs;
  var enabledApplyButton = false.obs;

  RxList<PriceData> datesChoosen = RxList<PriceData>([]);
  RxList<PriceData?> datesChoosenForWorshipRecurrentHours =
      RxList<PriceData>([]);
  RxList<PriceData?> datesChoosenWorshipSpecialHours = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipHours =
      RxList<LiturgicalCelebrationResponse>([]);

  RxList<LiturgicalCelebrationResponse> worshipRecurrentHoursTemp =
      RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipRecurrentHours = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipSpecialHoursTemp =
      RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipSpecialHours = RxList<PriceData>([]);

  var initialSelectedDate = Rx<PriceData?>(null);
  var endSelectedDate = Rx<PriceData?>(null);

  //------------------------------------
  // Gardons une trace explicite des slots sélectionnés
  final RxSet<String> selectedSlotKeys = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    getArguments();
    // Ne pas réinitialiser les sélections par défaut
    //resetSelections();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void getArguments() {
    if (Get.arguments != null) {
      worshipHours.value = Get.arguments[0];
      worshipRecurrentHoursTemp.value =
          worshipHours.where((element) => 
              element.isRecurrent == true && 
              element.type?.code != 'CONFESSION' &&
              element.type?.code != 'SPECIAL_CONFESSION').toList();
      worshipSpecialHoursTemp.value = worshipHours
          .where((element) =>
      element.isRecurrent == false &&
          element.type?.code != 'CONFESSION' &&
          element.type?.code != 'SPECIAL_CONFESSION' &&
          (Jiffy.parse(element.startDate ?? Jiffy.now().format(),
              pattern: AppConstants.TIME_ZONE_FORMAT)
              .isAfter(Jiffy.now().add(hours: 24))))
          .toList();

      worshipRecurrentHours.value =
          transformWorshipRecurrentHours(worshipRecurrentHoursTemp);
      worshipSpecialHours.value =
          transformWorshipSpecialHours(worshipSpecialHoursTemp);

      // Déterminer la première date autorisée selon les règles
      final now = DateTime.now();
      final currentWeekDay = now.weekday - 1; // Convertir au format 0-6 où 0=lundi
      final isAfternoon = now.hour >= 12;

      // Trouver le prochain jour valide selon le tableau
      DateTime firstAllowedDate;

      switch (currentWeekDay) {
        case 6: // Dimanche (6)
        // Prochain jour valide: Mardi
          firstAllowedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi dans notre format
          break;
        case 0: // Lundi (0)
        // Prochain jour valide: Mardi
          firstAllowedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi dans notre format
          break;
        case 1: // Mardi (1)
          if (!isAfternoon) {
            // Avant 12h: le même jour (mardi) à 16h
            firstAllowedDate = now;
          } else {
            // Après 12h: mercredi à 12h
            firstAllowedDate = _findNextDayOfWeek(now, 2); // 2 = Mercredi dans notre format
          }
          break;
        case 2: // Mercredi (2)
          if (!isAfternoon) {
            // Avant 12h: le même jour (mercredi) à 16h
            firstAllowedDate = now;
          } else {
            // Après 12h: jeudi à 12h
            firstAllowedDate = _findNextDayOfWeek(now, 3); // 3 = Jeudi dans notre format
          }
          break;
        case 3: // Jeudi (3)
          if (!isAfternoon) {
            // Avant 12h: le même jour (jeudi) à 16h
            firstAllowedDate = now;
          } else {
            // Après 12h: vendredi à 12h
            firstAllowedDate = _findNextDayOfWeek(now, 4); // 4 = Vendredi dans notre format
          }
          break;
        case 4: // Vendredi (4)
          if (!isAfternoon) {
            // Avant 12h: le même jour (vendredi) à 16h
            firstAllowedDate = now;
          } else {
            // Après 12h: samedi à 12h
            firstAllowedDate = _findNextDayOfWeek(now, 5); // 5 = Samedi dans notre format
          }
          break;
        case 5: // Samedi (5)
          if (!isAfternoon) {
            // Avant 12h: le même jour (samedi) à 16h
            firstAllowedDate = now;
          } else {
            // Après 12h: mardi à 12h
            firstAllowedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi dans notre format
          }
          break;
        default:
        // Par défaut, on commence au lendemain
          firstAllowedDate = now.add(const Duration(days: 1));
          break;
      }

      // Formater la date pour l'initialSelectedDate
      String formattedDay = firstAllowedDate.day.toString().padLeft(2, '0');
      String formattedMonth = firstAllowedDate.month.toString().padLeft(2, '0');
      String formattedDate = "${firstAllowedDate.year}-$formattedMonth-$formattedDay";

      // Initialiser la date de début
      initialSelectedDate.value = PriceData(
          day: formattedDate,
          dayToDisplay: "$formattedDay-$formattedMonth-${firstAllowedDate.year}",
          dayOfWeek: (firstAllowedDate.weekday - 1).toString(), // Convertir au format 0-6
          isDaySelected: true
      );

      // Si l'état sauvegardé existe, on le restaure
      if (Get.arguments.length > 2 && Get.arguments[2] != null) {
        final savedState = Get.arguments[2];
        if (savedState['endDate'] != null) {
          endSelectedDate.value = PriceData.fromJson(savedState['endDate']);
        } else {
          // Sinon on utilise la même date que celle de début
          endSelectedDate.value = PriceData.fromJson(initialSelectedDate.value!.toJson());
        }

        if (savedState['specialMasses'] != null) {
          final savedSpecialMasses = List<Map<String, dynamic>>.from(savedState['specialMasses']);
          _restoreSpecialMasses(savedSpecialMasses);
        }

        if (savedState['recurringMasses'] != null) {
          final savedRecurringMasses = List<Map<String, dynamic>>.from(savedState['recurringMasses']);
          _restoreRecurrentMasses(savedRecurringMasses);
        }

        if (savedState['selectedSlotKeys'] != null) {
          selectedSlotKeys.clear();
          selectedSlotKeys.addAll(List<String>.from(savedState['selectedSlotKeys']));
        }
      } else {
        // Si pas d'état sauvegardé, la date de fin est la même que celle de début
        endSelectedDate.value = PriceData.fromJson(initialSelectedDate.value!.toJson());
      }

      doRefreshHoursAfterAction();
      canDoApplyAction();
    }
  }

  // Ici, dayOfWeek est au format 0-6 où 0=lundi, 6=dimanche
  DateTime _findNextDayOfWeek(DateTime from, int dayOfWeek) {
    DateTime result = DateTime(from.year, from.month, from.day);

    // Convertir dayOfWeek de notre format (0-6) au format Dart (1-7)
    int dartDayOfWeek = dayOfWeek + 1;

    while (result.weekday != dartDayOfWeek) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  // Créer une clé unique pour chaque slot
  String _createSlotKey(String dayOfWeek, String startTime) {
    return '$dayOfWeek-$startTime';
  }

  // Créer une clé unique pour les messes spéciales
  String _createSpecialSlotKey(String date, String startTime) {
    return 'special-$date-$startTime';
  }

  void toggleSlotSelection(String identifier, String startTime, {bool isSpecial = false}) {
    if (isSpecial) {
      // Vérifier si la messe spéciale est sélectionnable
      final specialDate = Jiffy.parse(identifier).dateTime;
      final now = DateTime.now();
      final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche
      final isAfternoon = now.hour >= 12;
      final slotTime = parseTime(startTime);
      bool isAvailable = true;

      // Vérifier si la messe est dans la plage de dates sélectionnée
      if (!isSpecialMassSelectable(identifier)) {
        showNotification(
          message: 'Cette messe spéciale n\'est pas disponible pour la période sélectionnée',
          bgColor: colorBlue2,
        );
        return;
      }

      // Pour aujourd'hui, vérifier selon les règles du tableau
      if (isSameDay(specialDate, now)) {
        switch (currentWeekDay) {
          case 1: // Mardi
            isAvailable = !isAfternoon && slotTime.hour >= 16;
            break;
          case 2: // Mercredi
            isAvailable = !isAfternoon && slotTime.hour >= 16;
            break;
          case 3: // Jeudi
            isAvailable = !isAfternoon && slotTime.hour >= 16;
            break;
          case 4: // Vendredi
            isAvailable = !isAfternoon && slotTime.hour >= 16;
            break;
          case 5: // Samedi
            isAvailable = !isAfternoon && slotTime.hour >= 16;
            break;
          default:
            isAvailable = false; // Dimanche et Lundi: pas de messe disponible
        }
      }

      if (!isAvailable) {
        showNotification(
          message: 'Cette heure n\'est pas disponible',
          bgColor: colorBlue2,
        );
        return;
      }

      final slotKey = _createSpecialSlotKey(identifier, startTime);

      if (selectedSlotKeys.contains(slotKey)) {
        selectedSlotKeys.remove(slotKey);
      } else {
        selectedSlotKeys.add(slotKey);
      }

      var specialMass = worshipSpecialHours.firstWhere(
            (mass) => mass.day == identifier,
        orElse: () => PriceData(),
      );

      var slot = specialMass.slots?.firstWhere(
            (s) => s.startTime == startTime,
        orElse: () => Slot(),
      );

      if (slot != null) {
        slot.isHourSelected = selectedSlotKeys.contains(slotKey);
        onWorshipSpecialHoursSelected(specialMass);
      }

      worshipSpecialHours.refresh();
    } else {
      // Code pour les messes récurrentes
      // Vérifier la disponibilité selon les règles actuelles
      final now = DateTime.now();
      final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche
      final isAfternoon = now.hour >= 12;
      final targetWeekDay = int.parse(identifier);
      final slotTime = parseTime(startTime);

      // Vérifier si l'heure est disponible pour le jour actuel
      bool isHourAvailable = true;

      // Vérification spécifique pour dimanche et lundi lorsqu'on sélectionne un horaire du mardi
      if (targetWeekDay == 1) { // Si c'est un mardi
        // Si aujourd'hui est dimanche (6) ou lundi (0), n'autoriser que les heures à partir de 12h
        // MAIS SEULEMENT pour le premier mardi après le jour actuel
        if ((currentWeekDay == 6 || currentWeekDay == 0)) {
          // Obtenir la date du prochain mardi
          DateTime nextTuesday = _findNextDayOfWeek(now, 1);
          // Obtenir la date de fin sélectionnée
          DateTime endDate = Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime;

          // Si la date de fin est après le prochain mardi, et que la période contient plusieurs mardis,
          // alors permettre tous les créneaux pour les mardis futurs
          bool isExtendedPeriod = endDate.isAfter(nextTuesday.add(const Duration(days: 1)));

          // Si nous ne sommes pas dans une période étendue, ou si c'est le premier mardi de la période,
          // appliquer la restriction
          if (!isExtendedPeriod) {
            if (slotTime.hour < 12) {
              isHourAvailable = false;
              showNotification(
                message: 'Le dimanche et le lundi, seules les messes du mardi à partir de 12h sont disponibles',
                bgColor: colorBlue2,
              );
              return;
            }
          }
        }
      }

      // Si une date de fin a été sélectionnée, on ignore certaines règles
      if (endSelectedDate.value?.dayToDisplay == null ||
          endSelectedDate.value?.dayToDisplay == '-') {
        // Appliquer les règles spécifiques selon le jour actuel
        switch (currentWeekDay) {
          case 6: // Dimanche (6)
            if (targetWeekDay == 1) { // Mardi
              isHourAvailable = slotTime.hour >= 12;
            }
            break;
          case 0: // Lundi (0)
            if (targetWeekDay == 1) { // Mardi
              isHourAvailable = slotTime.hour >= 12;
            }
            break;
          case 1: // Mardi (1)
            if (targetWeekDay == 1) { // Mardi (même jour)
              isHourAvailable = !isAfternoon && slotTime.hour >= 16;
            } else if (targetWeekDay == 2) { // Mercredi
              isHourAvailable = isAfternoon && slotTime.hour >= 12;
            }
            break;
          case 2: // Mercredi (2)
            if (targetWeekDay == 2) { // Mercredi (même jour)
              isHourAvailable = !isAfternoon && slotTime.hour >= 16;
            } else if (targetWeekDay == 3) { // Jeudi
              isHourAvailable = isAfternoon && slotTime.hour >= 12;
            }
            break;
          case 3: // Jeudi (3)
            if (targetWeekDay == 3) { // Jeudi (même jour)
              isHourAvailable = !isAfternoon && slotTime.hour >= 16;
            } else if (targetWeekDay == 4) { // Vendredi
              isHourAvailable = isAfternoon && slotTime.hour >= 12;
            }
            break;
          case 4: // Vendredi (4)
            if (targetWeekDay == 4) { // Vendredi (même jour)
              isHourAvailable = !isAfternoon && slotTime.hour >= 16;
            } else if (targetWeekDay == 5) { // Samedi
              isHourAvailable = isAfternoon && slotTime.hour >= 12;
            }
            break;
          case 5: // Samedi (5)
            if (targetWeekDay == 5) { // Samedi (même jour)
              isHourAvailable = !isAfternoon && slotTime.hour >= 16;
            } else if (targetWeekDay == 1) { // Mardi
              isHourAvailable = isAfternoon && slotTime.hour >= 12;
            }
            break;
        }
      }

      if (!isHourAvailable) {
        showNotification(
          message: 'Cette heure n\'est pas disponible selon les règles actuelles',
          bgColor: colorBlue2,
        );
        return;
      }

      var recurrentMass = worshipRecurrentHours.firstWhere(
            (mass) => mass.dayOfWeek == identifier,
        orElse: () => PriceData(),
      );

      var slot = recurrentMass.slots?.firstWhere(
            (s) => s.startTime == startTime,
        orElse: () => Slot(),
      );

      if (slot != null) {
        slot.isHourSelected = !(slot.isHourSelected ?? false);
        onWorshipRecurrentHoursSelected(recurrentMass, slot.isHourSelected ?? false);
      }
    }

    worshipRecurrentHours.refresh();
    worshipSpecialHours.refresh();
    canDoApplyAction();
  }

  bool isSlotSelected(String identifier, String startTime, {bool isSpecial = false}) {
    if (isSpecial) {
      return selectedSlotKeys.contains(_createSpecialSlotKey(identifier, startTime));
    } else {
      return worshipRecurrentHours
          .firstWhere(
            (mass) => mass.dayOfWeek == identifier,
        orElse: () => PriceData(),
      )
          .slots
          ?.firstWhere(
            (s) => s.startTime == startTime,
        orElse: () => Slot(),
      )
          .isHourSelected ??
          false;
    }
  }

  void _restoreRecurrentMasses(List<Map<String, dynamic>> savedRecurrentMasses) {
    final now = DateTime.now();
    final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche

    for (var savedMass in savedRecurrentMasses) {
      var mass = worshipRecurrentHours.firstWhereOrNull(
              (m) => m.dayOfWeek == savedMass['dayOfWeek']
      );

      if (mass != null) {
        final savedSlots = List<Map<String, dynamic>>.from(savedMass['slots'] ?? []);
        final dayOfWeek = int.parse(mass.dayOfWeek ?? '0');

        for (var savedSlot in savedSlots) {
          if (savedSlot['isHourSelected'] == true) {
            // Retrouver le slot correspondant
            var slot = mass.slots?.firstWhereOrNull(
                    (s) => s.startTime == savedSlot['startTime']
            );

            if (slot != null) {
              bool isAvailable = true;

              // Vérification spécifique pour dimanche et lundi quand c'est un mardi
              if (dayOfWeek == 1) { // Si c'est mardi (1)
                if ((currentWeekDay == 6 || currentWeekDay == 0)) { // dimanche ou lundi
                  final slotTime = parseTimeFromString(slot.startTime ?? '');
                  isAvailable = slotTime.hour >= 12;
                }
              }

              if (isAvailable) {
                // Marquer le slot comme sélectionné
                slot.isHourSelected = true;
                // Ajouter la clé au selectedSlotKeys
                final slotKey = _createSlotKey(mass.dayOfWeek ?? '', slot.startTime ?? '');
                selectedSlotKeys.add(slotKey);
                // Mettre à jour l'état global
                onWorshipRecurrentHoursSelected(mass, true);
              }
            }
          }
        }
      }
    }
    worshipRecurrentHours.refresh();
  }

  void _restoreSpecialMasses(List<Map<String, dynamic>> savedSpecialMasses) {
    final now = DateTime.now();
    final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche
    final isAfternoon = now.hour >= 12;

    for (var savedMass in savedSpecialMasses) {
      var mass = worshipSpecialHours.firstWhereOrNull(
              (m) => m.day == savedMass['day']
      );

      if (mass != null) {
        final savedSlots = List<Map<String, dynamic>>.from(savedMass['slots'] ?? []);
        final specialDate = Jiffy.parse(mass.day ?? '').dateTime;
        final isToday = isSameDay(specialDate, now);

        for (var savedSlot in savedSlots) {
          if (savedSlot['isHourSelected'] == true) {
            // Retrouver le slot correspondant
            var slot = mass.slots?.firstWhereOrNull((s) => s.startTime == savedSlot['startTime']);
            if (slot != null) {
              bool isAvailable = true;

              // Si c'est aujourd'hui, vérifier selon les règles
              if (isToday) {
                final slotTime = parseTime(slot.startTime ?? '');

                switch (currentWeekDay) {
                  case 1: // Mardi
                    isAvailable = !isAfternoon && slotTime.hour >= 16;
                    break;
                  case 2: // Mercredi
                    isAvailable = !isAfternoon && slotTime.hour >= 16;
                    break;
                  case 3: // Jeudi
                    isAvailable = !isAfternoon && slotTime.hour >= 16;
                    break;
                  case 4: // Vendredi
                    isAvailable = !isAfternoon && slotTime.hour >= 16;
                    break;
                  case 5: // Samedi
                    isAvailable = !isAfternoon && slotTime.hour >= 16;
                    break;
                  default:
                    isAvailable = false; // Dimanche et Lundi: pas de messe disponible
                }
              }

              if (isAvailable && isSpecialMassSelectable(mass.day ?? '')) {
                // Marquer le slot comme sélectionné
                slot.isHourSelected = true;

                // Ajouter la clé au selectedSlotKeys
                final slotKey = _createSpecialSlotKey(mass.day ?? '', slot.startTime ?? '');
                selectedSlotKeys.add(slotKey);

                // Mettre à jour l'état global
                onWorshipSpecialHoursSelected(mass);
              }
            }
          }
        }
      }
    }
    worshipSpecialHours.refresh();
  }

  // Déterminer la plage horaire en fonction de l'heure actuelle
  // ignore: unused_element
  TimeRange _determineTimeRange(DateTime now) {
    final currentHour = now.hour;
    final currentMinute = now.minute;

    // Utiliser le format 24h pour la comparaison
    final currentTimeInMinutes = currentHour * 60 + currentMinute;

    if (currentTimeInMinutes >= 0 && currentTimeInMinutes < 12 * 60) {
      return TimeRange.morning; // 00h01 - 12h00
    } else {
      return TimeRange.afternoon; // 12h01 - 24h00
    }
  }

  // Vérifie si une messe spéciale est sélectionnable en fonction de la période
  bool isSpecialMassSelectable(String specialMassDate) {
    if (initialSelectedDate.value == null || endSelectedDate.value == null) {
      return false;
    }

    DateTime specialDate = Jiffy.parse(specialMassDate).dateTime;
    DateTime startDate = Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime;
    DateTime endDate = Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime;

    // La messe spéciale doit être dans la période sélectionnée
    return !specialDate.isBefore(startDate) && !specialDate.isAfter(endDate);
  }

  List<Slot> getSelectedHoursForDay(String dayOfWeek) {
    final daySlots = worshipRecurrentHours
            .firstWhere((hour) => hour.dayOfWeek == dayOfWeek,
                orElse: () => PriceData())
            .slots ??
        [];

    return daySlots
        .where((slot) => selectedSlotKeys
            .contains(_createSlotKey(dayOfWeek, slot.startTime ?? '')))
        .toList();
  }

  // Ajouter une méthode pour réinitialiser les sélections
  void resetSelections() {
    selectedSlotKeys.clear();
    update();
  }

  doRefreshHoursOnInit() {
    for (PriceData i in worshipRecurrentHours) {
      if (int.parse(i.dayOfWeek ?? '0') ==
          (int.parse(initialSelectedDate.value?.dayOfWeek.toString() ?? '1') -
              1)) {
        for (Slot l in i.slots ?? []) {
          if (l.identifier ==
              initialSelectedDate.value?.slots?.first.identifier) {
            l.isHourSelected = true;
            //i.day = initialSelectedDate.value?.day;
            //i.dayToDisplay = initialSelectedDate.value?.dayToDisplay;
            //i.isDaySelected = initialSelectedDate.value?.isDaySelected;
            onWorshipRecurrentHoursSelected(i, true);
            break;
          }
        }
      }
    }
    canDoApplyAction();
  }

  doRefreshHoursAfterAction() {
    // Obtenir l'heure actuelle pour calculer correctement les disponibilités
    final now = DateTime.now();
    final currentWeekDay = now.weekday - 1; // 0 pour lundi, 6 pour dimanche
    final isAfternoon = now.hour >= 12;

    // Déterminer la première date selon les règles
    DateTime firstAllowedDate = Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime;

    for (PriceData? i in worshipRecurrentHours) {
      for (Slot l in i?.slots ?? []) {

        if (int.parse(i?.dayOfWeek ?? '0') == 1) { // Si c'est mardi (1)
          if ((currentWeekDay == 6 || currentWeekDay == 0)) { // Si aujourd'hui est dimanche ou lundi
            // Obtenir la date du prochain mardi
            DateTime nextTuesday = _findNextDayOfWeek(now, 1);
            // Obtenir la date de fin sélectionnée
            DateTime endDate = Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime;

            // Si la date de fin est après le prochain mardi et contient plusieurs mardis,
            // permettre tous les créneaux pour les mardis futurs
            bool isExtendedPeriod = endDate.isAfter(nextTuesday.add(const Duration(days: 1)));

            // Si nous ne sommes pas dans une période étendue, appliquer la restriction
            if (!isExtendedPeriod && parseTimeFromString(l.startTime ?? '00:00:00').hour < 12) {
              // Désactiver les créneaux avant 12h uniquement pour le premier mardi
              l.isHourSelected = false;
              continue; // Passer au créneau suivant
            }
          }
        }

        if (isDayOfWeekInDateRange(
            int.parse(i?.dayOfWeek ?? '0'),
            firstAllowedDate,
            Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime)) {

          // Vérifier si l'heure est disponible pour le jour actuel
          bool isAvailable = true;
          if (isSameDay(firstAllowedDate, now)) {
            // Pour aujourd'hui, appliquer les règles spécifiques
            int targetWeekDay = int.parse(i?.dayOfWeek ?? '0');
            final slotTime = parseTime(l.startTime ?? '');

            switch (currentWeekDay) {
              case 6: // Dimanche (6)
                if (targetWeekDay == 1) { // Mardi
                  isAvailable = slotTime.hour >= 12;
                }
                break;
              case 0: // Lundi (0)
                if (targetWeekDay == 1) { // Mardi
                  isAvailable = slotTime.hour >= 12;
                }
                break;
              case 1: // Mardi (1)
                if (targetWeekDay == 1) { // Mardi (même jour)
                  isAvailable = !isAfternoon && slotTime.hour >= 16;
                } else if (targetWeekDay == 2) { // Mercredi
                  isAvailable = isAfternoon && slotTime.hour >= 12;
                }
                break;
              case 2: // Mercredi (2)
                if (targetWeekDay == 2) { // Mercredi (même jour)
                  isAvailable = !isAfternoon && slotTime.hour >= 16;
                } else if (targetWeekDay == 3) { // Jeudi
                  isAvailable = isAfternoon && slotTime.hour >= 12;
                }
                break;
              case 3: // Jeudi (3)
                if (targetWeekDay == 3) { // Jeudi (même jour)
                  isAvailable = !isAfternoon && slotTime.hour >= 16;
                } else if (targetWeekDay == 4) { // Vendredi
                  isAvailable = isAfternoon && slotTime.hour >= 12;
                }
                break;
              case 4: // Vendredi (4)
                if (targetWeekDay == 4) { // Vendredi (même jour)
                  isAvailable = !isAfternoon && slotTime.hour >= 16;
                } else if (targetWeekDay == 5) { // Samedi
                  isAvailable = isAfternoon && slotTime.hour >= 12;
                }
                break;
              case 5: // Samedi (5)
                if (targetWeekDay == 5) { // Samedi (même jour)
                  isAvailable = !isAfternoon && slotTime.hour >= 16;
                } else if (targetWeekDay == 1) { // Mardi
                  isAvailable = isAfternoon && slotTime.hour >= 12;
                }
                break;
            }
          }

          // Mettre à jour l'état de sélection en fonction de la disponibilité
          if (l.isHourSelected == true && isAvailable) {
            l.isHourSelected = true;
            onWorshipRecurrentHoursSelected(i, true);
          } else {
            l.isHourSelected = false;
            onWorshipRecurrentHoursSelected(i, false);
          }
        } else {
          l.isHourSelected = false;
          onWorshipRecurrentHoursSelected(i, false);
        }
      }
    }
    worshipRecurrentHours.refresh();
    canDoApplyAction();
  }

  onWorshipRecurrentHoursRemoved(PriceData priceData) {
    var hasData = datesChoosenForWorshipRecurrentHours
        .firstWhereOrNull((element) => element?.day == priceData.day);
    if (hasData != null) {
      worshipRecurrentHours.refresh();
      for (PriceData item in worshipRecurrentHours) {
        if (priceData.day == item.day) {
          item.isDaySelected = false;
          item.day = '';
          item.dayToDisplay = '';
          for (Slot hour in item.slots ?? []) {
            hour.isHourSelected = false;
          }
        }
      }
      datesChoosenForWorshipRecurrentHours.remove(priceData);
    }
    canDoApplyAction();
  }

  onWorshipRecurrentHoursSelected(PriceData? hour, bool isDateSelected,
      {String? hourSelected = ''}) {
    worshipRecurrentHours.refresh();
    if (isDateSelected) {
      var hasData = datesChoosenForWorshipRecurrentHours.firstWhereOrNull(
          (element) =>
              (element?.identifier == hour?.identifier) &&
              (element?.dayOfWeek == hour?.dayOfWeek));
      if (hasData == null) {
        worshipRecurrentHours.refresh();
        datesChoosenForWorshipRecurrentHours.add(hour);
        datesChoosenForWorshipRecurrentHours.value =
            countOccurrencesAndAssignDates(
                Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime,
                Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime,
                datesChoosenForWorshipRecurrentHours);
      } else {}
    } else {
      worshipRecurrentHours.refresh();
    }
    log('datesChoosenForWorshipRecurrentHours ::: ${jsonEncode(datesChoosenForWorshipRecurrentHours)}');
    canDoApplyAction();
  }

  onWorshipSpecialHoursSelected(PriceData? hour) {
    var hasData = datesChoosenWorshipSpecialHours
        .firstWhereOrNull((element) => element?.day == hour?.day);
    if (hasData == null) {
      worshipSpecialHours.refresh();
      datesChoosenWorshipSpecialHours.add(hour);
    } else {
      worshipSpecialHours.refresh();
    }

    canDoApplyAction();
  }

  DateTime _findNextValidDate(DateTime startDate, int weekDay) {
    DateTime date = startDate;
    while (date.weekday != weekDay) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  selectEndDate(BuildContext context, PriceData? item) async {
    // Utiliser la date de début comme minimum
    DateTime startDate = Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime;

    // Déterminer la date initiale du picker
    DateTime initialDate;
    if (endSelectedDate.value?.dayToDisplay != null &&
        endSelectedDate.value?.dayToDisplay != '-') {
      // Si une date de fin est déjà sélectionnée, on l'utilise comme date initiale
      List<String> dateParts = endSelectedDate.value!.dayToDisplay!.split('-');
      initialDate = DateTime(
          int.parse(dateParts[2]), // année
          int.parse(dateParts[1]), // mois
          int.parse(dateParts[0]) // jour
      );

      // Vérifier si la date est après la date de début
      if (initialDate.isBefore(startDate)) {
        initialDate = startDate;
      }
    } else {
      // Sinon on utilise la date de début
      initialDate = startDate;
    }

    final DateTime? selected = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: initialDate,
      firstDate: startDate, // La date de début est la date minimum
      lastDate: DateTime(startDate.year + 5),
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
                primary: colorPurpleLight),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorWhite,
                textStyle:
                TextStyles.montserratRegular(textSize: TextSizes.fourteen),
                backgroundColor: colorPurpleLight,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.transparent,
                      width: 1,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      // Réinitialiser toutes les sélections
      resetSelections(); // Réinitialiser les slots
      resetRecurrentHours(); // Réinitialiser les heures récurrentes
      resetSpecialHours(); // Réinitialiser les heures spéciales

      String day = selected.day.toString().padLeft(2, '0');
      String month = selected.month.toString().padLeft(2, '0');

      endSelectedDate.value?.day = "${selected.year}-$month-$day";
      endSelectedDate.value?.dayToDisplay = "$day-$month-${selected.year}";
      endSelectedDate.refresh();

      doRefreshHoursAfterAction();
      datesChoosenForWorshipRecurrentHours.value =
          countOccurrencesAndAssignDates(
              Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime,
              selected,
              datesChoosenForWorshipRecurrentHours);

      // Mettre à jour l'état du bouton de continuation
      canDoApplyAction();
    }
  }

  Future<void> selectStartDate(BuildContext context) async {
    // Obtenir la date actuelle
    final now = DateTime.now();
    final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche
    final isAfternoon = now.hour >= 12;

    // Déterminer la première date autorisée
    DateTime minimumAllowedDate;

    switch (currentWeekDay) {
      case 6: // Dimanche (6)
      // Prochain jour valide: Mardi
        minimumAllowedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi
        break;
      case 0: // Lundi (0)
      // Prochain jour valide: Mardi
        minimumAllowedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi
        break;
      case 1: // Mardi (1)
        if (!isAfternoon) {
          // Avant 12h: le même jour à 16h
          minimumAllowedDate = now;
        } else {
          // Après 12h: mercredi
          minimumAllowedDate = _findNextDayOfWeek(now, 2); // 2 = Mercredi
        }
        break;
      case 2: // Mercredi (2)
        if (!isAfternoon) {
          // Avant 12h: le même jour à 16h
          minimumAllowedDate = now;
        } else {
          // Après 12h: jeudi
          minimumAllowedDate = _findNextDayOfWeek(now, 3); // 3 = Jeudi
        }
        break;
      case 3: // Jeudi (3)
        if (!isAfternoon) {
          // Avant 12h: le même jour à 16h
          minimumAllowedDate = now;
        } else {
          // Après 12h: vendredi
          minimumAllowedDate = _findNextDayOfWeek(now, 4); // 4 = Vendredi
        }
        break;
      case 4: // Vendredi (4)
        if (!isAfternoon) {
          // Avant 12h: le même jour à 16h
          minimumAllowedDate = now;
        } else {
          // Après 12h: samedi
          minimumAllowedDate = _findNextDayOfWeek(now, 5); // 5 = Samedi
        }
        break;
      case 5: // Samedi (5)
        if (!isAfternoon) {
          // Avant 12h: le même jour à 16h
          minimumAllowedDate = now;
        } else {
          // Après 12h: mardi
          minimumAllowedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi
        }
        break;
      default:
        minimumAllowedDate = now;
        break;
    }

    final DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: minimumAllowedDate,
      firstDate: minimumAllowedDate,
      lastDate: DateTime(now.year + 5),
      cancelText: 'cancel'.tr,
      confirmText: 'confirm'.tr,
      barrierDismissible: false,
      locale: const Locale('fr', 'FR'),
      selectableDayPredicate: (date) {
        // Vérifier si la date est éligible selon les règles du tableau
        if (isSameDay(date, now)) {
          // Pour aujourd'hui, vérifier selon le jour de la semaine et l'heure
          switch (currentWeekDay) {
            case 6: // Dimanche
            case 0: // Lundi
              return false; // Pas de messe disponible le même jour
            case 1: // Mardi
            case 2: // Mercredi
            case 3: // Jeudi
            case 4: // Vendredi
            case 5: // Samedi
              return !isAfternoon; // Disponible uniquement avant 12h
            default:
              return false;
          }
        }
        return true; // Les autres jours sont sélectionnables
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              onPrimary: colorWhite,
              onSurface: colorBlack,
              primary: colorGreen,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorWhite,
                textStyle: TextStyles.montserratRegular(textSize: TextSizes.fourteen),
                backgroundColor: colorGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Réinitialiser toutes les sélections
      resetSelections();
      resetRecurrentHours();
      resetSpecialHours();

      // Mettre à jour la date de début
      String day = picked.day.toString().padLeft(2, '0');
      String month = picked.month.toString().padLeft(2, '0');

      initialSelectedDate.value = PriceData(
          day: "${picked.year}-$month-$day",
          dayToDisplay: "$day-$month-${picked.year}",
          dayOfWeek: (picked.weekday - 1).toString(), // Convertir au format 0-6
          isDaySelected: true
      );

      // Ajuster la date de fin pour qu'elle soit égale à la date de début
      endSelectedDate.value = PriceData.fromJson(initialSelectedDate.value!.toJson());

      // Rafraîchir l'interface
      doRefreshHoursAfterAction();
      canDoApplyAction();
    }
  }

  bool isStartDateSelectable(DateTime date) {
    final now = DateTime.now();

    // Si ce n'est pas aujourd'hui, la date est sélectionnable
    if (date.year != now.year || date.month != now.month || date.day != now.day) {
      return true;
    }

    // Pour aujourd'hui, vérifier selon le jour de la semaine
    final currentWeekDay = now.weekday - 1; // Convertir au format 0-6

    switch (currentWeekDay) {
      case 6: // Dimanche (6)
      case 0: // Lundi (0)
        return false; // Jamais sélectionnable le même jour
      case 1: // Mardi (1)
      case 2: // Mercredi (2)
      case 3: // Jeudi (3)
      case 4: // Vendredi (4)
      case 5: // Samedi (5)
        return now.hour < 12; // Sélectionnable uniquement avant 12h
      default:
        return false;
    }
  }

  void showStartDateRestrictionMessage() {
    final now = DateTime.now();
    final currentWeekDay = now.weekday - 1; // Convertir au format 0-6
    final isAfternoon = now.hour >= 12;

    String message = '';

    switch (currentWeekDay) {
      case 6: // Dimanche (6)
        message = 'Les messes ne sont disponibles qu\'à partir de mardi à 12h';
        break;
      case 0: // Lundi (0)
        message = 'Les messes ne sont disponibles qu\'à partir de mardi à 12h';
        break;
      case 1: // Mardi (1)
        if (!isAfternoon) {
          message = 'Les messes ne sont disponibles qu\'à partir de 16h aujourd\'hui';
        } else {
          message = 'Les messes ne sont disponibles qu\'à partir de mercredi à 12h';
        }
        break;
      case 2: // Mercredi (2)
        if (!isAfternoon) {
          message = 'Les messes ne sont disponibles qu\'à partir de 16h aujourd\'hui';
        } else {
          message = 'Les messes ne sont disponibles qu\'à partir de jeudi à 12h';
        }
        break;
      case 3: // Jeudi (3)
        if (!isAfternoon) {
          message = 'Les messes ne sont disponibles qu\'à partir de 16h aujourd\'hui';
        } else {
          message = 'Les messes ne sont disponibles qu\'à partir de vendredi à 12h';
        }
        break;
      case 4: // Vendredi (4)
        if (!isAfternoon) {
          message = 'Les messes ne sont disponibles qu\'à partir de 16h aujourd\'hui';
        } else {
          message = 'Les messes ne sont disponibles qu\'à partir de samedi à 12h';
        }
        break;
      case 5: // Samedi (5)
        if (!isAfternoon) {
          message = 'Les messes ne sont disponibles qu\'à partir de 16h aujourd\'hui';
        } else {
          message = 'Les messes ne sont disponibles qu\'à partir de mardi à 12h';
        }
        break;
    }

    showNotification(
      message: message,
      bgColor: colorBlue2,
    );
  }

  bool isTimeAllowedForStartDate(DateTime startDate, String startTime) {
    final now = DateTime.now();

    // Si la date n'est pas aujourd'hui, tout est permis
    if (!isSameDay(startDate, now)) {
      return true;
    }

    // Obtenir le jour de la semaine actuel au format 0-6 (0=lundi, 6=dimanche)
    int currentWeekDay = now.weekday - 1;

    final isAfternoon = now.hour >= 12;
    final slotTime = parseTime(startTime);

    // Appliquer les règles selon le jour actuel
    switch (currentWeekDay) {
      case 1: // Mardi (1)
        if (!isAfternoon) {
          // Avant 12h: le même jour (mardi) à 16h
          return slotTime.hour >= 16;
        } else {
          // Après 12h: pas de messe le même jour
          return false;
        }
      case 2: // Mercredi (2)
        if (!isAfternoon) {
          // Avant 12h: le même jour (mercredi) à 16h
          return slotTime.hour >= 16;
        } else {
          // Après 12h: pas de messe le même jour
          return false;
        }
      case 3: // Jeudi (3)
        if (!isAfternoon) {
          // Avant 12h: le même jour (jeudi) à 16h
          return slotTime.hour >= 16;
        } else {
          // Après 12h: pas de messe le même jour
          return false;
        }
      case 4: // Vendredi (4)
        if (!isAfternoon) {
          // Avant 12h: le même jour (vendredi) à 16h
          return slotTime.hour >= 16;
        } else {
          // Après 12h: pas de messe le même jour
          return false;
        }
      case 5: // Samedi (5)
        if (!isAfternoon) {
          // Avant 12h: le même jour (samedi) à 16h
          return slotTime.hour >= 16;
        } else {
          // Après 12h: pas de messe le même jour
          return false;
        }
      default:
        return false; // Pas de messe disponible le même jour pour dimanche et lundi
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void showCustomDatePicker(BuildContext context, PriceData item) {
    final weekDay = int.parse(item.dayOfWeek ?? '0');
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Trouver la prochaine date valide
    DateTime initialDate = _findNextValidDate(today, (weekDay + 1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetAnimationCurve: Curves.bounceIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Separators.normalVertical(),
              CustomCalendarDatePicker(
                initialDate: initialDate,
                firstDate: today,
                lastDate: DateTime(today.year + 5),
                onDateChanged: (DateTime date) {
                  bool isSelectable = date.weekday == (weekDay + 1);
                  if (isSelectable) {
                    String day = date.day.toString();
                    String month = date.month.toString();
                    if (date.day < 10) {
                      day = "0$day";
                    }
                    if (date.month < 10) {
                      month = "0$month";
                    }
                    item.isDaySelected = true;
                    item.day = "${date.year}-$month-$day";
                    item.dayToDisplay = "$day-$month-${date.year}";
                    onWorshipRecurrentHoursSelected(item, true);
                    Get.back();
                  } else {
                    showNotification(
                      message: 'Il n\'y a pas de Messe à cette date',
                      bgColor: colorBlue2,
                    );
                  }
                },
                selectableDayPredicate: (date) {
                  bool isSelectable = date.weekday == (weekDay + 1);
                  return isSelectable;
                },
              ),
              TextButton(
                child: Text(
                  'Fermer',
                  textAlign: TextAlign.center,
                  style: TextStyles.montserratMedium(
                    textSize: TextSizes.fifteen,
                    textColor: colorBlack,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Separators.normalVertical(),
            ],
          ),
        );
      },
    );
  }

  List<PriceData> _filterSelectedSlots(List<PriceData?> days) {
    return days.map((day) {
      return PriceData(
        day: day?.day,
        dayToDisplay: day?.dayToDisplay,
        dayOfWeek: day?.dayOfWeek,
        isDaySelected: day?.isDaySelected,
        repeat: day?.repeat,
        dates: day?.dates,
        slots:
            day?.slots?.where((slot) => slot.isHourSelected == true).toList(),
      );
    }).toList();
  }

  resetRecurrentHours() {
    datesChoosenForWorshipRecurrentHours.clear();
    for (PriceData item in worshipRecurrentHours) {
      item.isDaySelected = false;
      item.day = '';
      item.dayToDisplay = '';
      for (Slot hour in item.slots ?? []) {
        hour.isHourSelected = false;
      }
    }
    worshipRecurrentHours.refresh();
  }

  resetSpecialHours() {
    datesChoosenWorshipSpecialHours.clear();
    for (PriceData item in worshipSpecialHours) {
      for (Slot hour in item.slots ?? []) {
        hour.isHourSelected = false;
      }
    }
    worshipSpecialHours.refresh();
  }

  void doResetFilter() {
    // Réinitialiser la date de fin avec la date initiale
    endSelectedDate.value = PriceData.fromJson(initialSelectedDate.value!.toJson());
    endSelectedDate.refresh();

    // Réinitialiser les heures récurrentes
    resetRecurrentHours();

    // Réinitialiser les heures spéciales
    resetSpecialHours();

    // Réinitialiser les clés de slots
    selectedSlotKeys.clear();

    // Réinitialiser les dates choisies
    datesChoosenForWorshipRecurrentHours.clear();
    datesChoosenWorshipSpecialHours.clear();

    // Réinitialiser manuellement tous les slots
    for (var priceData in worshipRecurrentHours) {
      for (var slot in priceData.slots ?? []) {
        slot.isHourSelected = false;
      }
    }

    for (var priceData in worshipSpecialHours) {
      for (var slot in priceData.slots ?? []) {
        slot.isHourSelected = false;
      }
    }

    // Rafraîchir toutes les listes réactives
    worshipRecurrentHours.refresh();
    worshipSpecialHours.refresh();

    // Recharger les données des horaires
    doRefreshHoursAfterAction();

    // Vérifier l'état du bouton Continuer
    canDoApplyAction();
  }

  doResetAndCloseFilter() {
    doResetFilter();
    //Get.delete<FilterMassRequestDateController>(force: true);
    Get.back();
  }

  doBack() {
    if (enabledApplyButton.isFalse) {
      Get.back();
      return;
    }
    showCustomDialog(
      Get.context!,
      message: 'Attention !\nVous êtes sur le point de quitter cette page. Tous les horaires sélectionnés seront perdus.\n\nVoulez-vous vraiment continuer ?\n',
      negativeLabel: 'NON',
      positiveLabel: 'OUI',
      positiveCallBack: () {
        doResetAndCloseFilter();
      },
    );
  }

  void canDoApplyAction() {
    bool hasSelectedRecurrentSlots = worshipRecurrentHours.any((mass) =>
    mass.slots?.any((slot) => slot.isHourSelected ?? false) ?? false);

    bool hasSelectedSpecialSlots = worshipSpecialHours.any((mass) =>
    mass.slots?.any((slot) => slot.isHourSelected ?? false) ?? false);

    enabledApplyButton.value = hasSelectedRecurrentSlots || hasSelectedSpecialSlots;
  }

  void setDatas() {
    datesChoosen.clear();

    // Traiter les messes récurrentes
    var selectedRecurrentHours = _filterSelectedSlots(datesChoosenForWorshipRecurrentHours);
    var recurrentDates = duplicateEventsByRepeat(selectedRecurrentHours)
        .where((e) => e.slots?.isNotEmpty == true)
        .toList();

    // Traiter les messes spéciales
    var selectedSpecialHours = _filterSelectedSlots(datesChoosenWorshipSpecialHours);

    // Combiner les deux types de messes
    datesChoosen.value = [
      ...recurrentDates,
      ...selectedSpecialHours,
    ];
  }

  void prepareRecapData() {
    datesChoosenForWorshipRecurrentHours.clear();
    datesChoosenWorshipSpecialHours.clear();

    // Traitement des messes récurrentes
    for (var day in worshipRecurrentHours) {
      var selectedSlots = day.slots?.where((slot) => slot.isHourSelected == true).toList() ?? [];
      if (selectedSlots.isNotEmpty) {
        datesChoosenForWorshipRecurrentHours.add(PriceData(
          dayOfWeek: day.dayOfWeek,
          slots: selectedSlots,
          repeat: day.repeat,
          dates: day.dates,
          day: day.day,
          dayToDisplay: day.dayToDisplay,
          isDaySelected: true,
        ));
      }
    }

    // Traitement des messes spéciales
    for (var day in worshipSpecialHours) {
      // Vérifier si la messe spéciale est dans la période valide
      if (isSpecialMassSelectable(day.day ?? '')) {
        var selectedSlots = day.slots?.where((slot) => slot.isHourSelected == true).toList() ?? [];
        if (selectedSlots.isNotEmpty) {
          datesChoosenWorshipSpecialHours.add(PriceData(
            dayOfWeek: day.dayOfWeek,
            slots: selectedSlots,
            day: day.day,
            dayToDisplay: day.dayToDisplay,
            isDaySelected: true,
            isSpecial: true,
          ));
        }
      }
    }

    // Combinaison des deux types de messes
    datesChoosen.value = [
      ...datesChoosenForWorshipRecurrentHours.where((date) => date != null).map((date) => date!).toList(),
      ...datesChoosenWorshipSpecialHours.where((date) => date != null).map((date) => date!).toList(),
    ];

    update();
  }

  void moveToRecap() {
    if (enabledApplyButton.value) {
      prepareRecapData();

      // Ajoutez des logs de débogage
      log('datesChoosenForWorshipRecurrentHours before setDatas: ${jsonEncode(datesChoosenForWorshipRecurrentHours)}');

      setDatas();
      recapDialog();
    }
  }

  void goBackToMassRequest() {
    final specialMasses = worshipSpecialHours.map((mass) {
      return {
        'day': mass.day,
        'slots': mass.slots?.map((slot) => {
          'startTime': slot.startTime,
          'isHourSelected': slot.isHourSelected,
        }).toList(),
      };
    }).toList();

    final result = {
      'dates': datesChoosen,
      'endDate': endSelectedDate.value?.toJson(),
      'specialMasses': specialMasses,
      'selectedSlotKeys': selectedSlotKeys.toList(),
    };

    Get.back(result: result);
  }

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
}
