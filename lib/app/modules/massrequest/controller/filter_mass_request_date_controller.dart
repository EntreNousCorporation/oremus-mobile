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
      if (!isSpecialMassSelectable(identifier)) {
        showNotification(
          message: 'Cette messe spéciale n\'est pas disponible pour la période sélectionnée',
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
      // Logique existante pour les messes récurrentes
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
      // Logique existante pour les messes récurrentes
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
          worshipHours.where((element) => element.isRecurrent == true).toList();
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

      // Restaurer les dates initiale et finale
      initialSelectedDate.value = PriceData.fromJson(Get.arguments[1]);

      // Restaurer l'état sauvegardé si disponible
      if (Get.arguments.length > 2 && Get.arguments[2] != null) {
        final savedState = Get.arguments[2];

        // Restaurer la date de fin
        if (savedState['endDate'] != null) {
          endSelectedDate.value = PriceData.fromJson(savedState['endDate']);
        } else {
          endSelectedDate.value = PriceData.fromJson(Get.arguments[1]);
        }

        // Restaurer les selectedSlotKeys
        if (savedState['specialMasses'] != null) {
          final savedSpecialMasses = List<Map<String, dynamic>>.from(savedState['specialMasses']);
          _restoreSpecialMasses(savedSpecialMasses);
        }

        if (savedState['selectedSlotKeys'] != null) {
          selectedSlotKeys.clear();
          selectedSlotKeys.addAll(List<String>.from(savedState['selectedSlotKeys']));
        }
      } else {
        endSelectedDate.value = PriceData.fromJson(Get.arguments[1]);
      }

      doRefreshHoursAfterAction();
      canDoApplyAction();
    }
  }

  void _restoreSpecialMasses(List<Map<String, dynamic>> savedSpecialMasses) {
    for (var savedMass in savedSpecialMasses) {
      var mass = worshipSpecialHours.firstWhereOrNull(
              (m) => m.day == savedMass['day']
      );

      if (mass != null) {
        final savedSlots = List<Map<String, dynamic>>.from(savedMass['slots'] ?? []);

        for (var savedSlot in savedSlots) {
          if (savedSlot['isHourSelected'] == true) {
            // Retrouver le slot correspondant
            var slot = mass.slots?.firstWhereOrNull(
                    (s) => s.startTime == savedSlot['startTime']
            );

            if (slot != null) {
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
    worshipSpecialHours.refresh();
  }

  // Mettre à jour l'état d'une messe spéciale
  void _updateSpecialMassState(String slotKey) {
    final parts = slotKey.split('-');
    if (parts.length >= 4) {
      final date = parts[2];
      final startTime = parts[3];

      var specialMass = worshipSpecialHours.firstWhere(
            (mass) => mass.day == date,
        orElse: () => PriceData(),
      );

      var slot = specialMass.slots?.firstWhere(
            (s) => s.startTime == startTime,
        orElse: () => Slot(),
      );

      if (slot != null) {
        slot.isHourSelected = true;
      }
    }
  }

  // Restaurer l'état des messes spéciales
  void _restoreSpecialMassesState() {
    for (var mass in worshipSpecialHours) {
      if (mass.slots != null) {
        for (var slot in mass.slots!) {
          final slotKey = _createSpecialSlotKey(mass.day ?? '', slot.startTime ?? '');
          slot.isHourSelected = selectedSlotKeys.contains(slotKey);
        }
      }
    }
    worshipSpecialHours.refresh();
  }

  // Vérifier si une date donnée est aujourd'hui
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Déterminer la plage horaire en fonction de l'heure actuelle
  TimeRange _determineTimeRange(DateTime now) {
    final currentTime = now.hour * 60 + now.minute;  // Convertir en minutes

    if (currentTime >= 0 && currentTime <= 9 * 60) {
      return TimeRange.morning;    // 00h01 - 09h00
    } else if (currentTime > 9 * 60 && currentTime <= 15 * 60) {
      return TimeRange.afternoon;  // 09h01 - 15h00
    } else {
      return TimeRange.evening;    // 15h01 - 00h00
    }
  }

  // Vérifier si un slot respecte les règles
  bool _isSlotSelectableByRules(String slotKey) {
    // Pour les messes spéciales
    if (slotKey.startsWith('special-')) {
      final parts = slotKey.split('-');
      if (parts.length >= 4) {
        final date = parts[2];
        return isSpecialMassSelectable(date);
      }
      return false;
    }

    // Pour les messes récurrentes
    final parts = slotKey.split('-');
    if (parts.length >= 2) {
      final currentTime = DateTime.now();
      final dayOfWeek = parts[0];
      final startTime = parts[1];

      // Convertir l'heure du slot
      final slotTime = parseTime(startTime);

      // Appliquer les règles du tableau
      if (_isToday(currentTime) && int.parse(dayOfWeek) == currentTime.weekday - 1) {
        final timeRange = _determineTimeRange(currentTime);

        switch (timeRange) {
          case TimeRange.morning: // 00h01 - 09h00
            return slotTime.hour >= 12;
          case TimeRange.afternoon: // 09h01 - 15h00
            return slotTime.hour >= 18;
          case TimeRange.evening: // 15h01 - 00h00
          // La sélection doit être pour le lendemain
            return false;
          default:
            return true;
        }
      }

      return true;
    }

    return false;
  }

  // Méthode d'aide pour restaurer les sélections des messes
  void _restoreWorshipHours(RxList<PriceData> target, List<Map<String, dynamic>> savedData) {
    for (var savedMass in savedData) {
      var mass = target.firstWhereOrNull(
              (m) => m.day == savedMass['day'] && m.dayOfWeek == savedMass['dayOfWeek']
      );
      if (mass != null) {
        // Restaurer les propriétés de la messe
        mass.isDaySelected = savedMass['isDaySelected'] ?? false;
        mass.repeat = savedMass['repeat'];
        mass.dayToDisplay = savedMass['dayToDisplay'];

        // Restaurer l'état des slots
        final savedSlots = List<Map<String, dynamic>>.from(savedMass['slots'] ?? []);
        for (var savedSlot in savedSlots) {
          var slot = mass.slots?.firstWhereOrNull(
                  (s) => s.startTime == savedSlot['startTime']
          );
          if (slot != null) {
            slot.isHourSelected = savedSlot['isHourSelected'] ?? false;
          }
        }
      }
    }
    target.refresh();
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
    for (PriceData? i in worshipRecurrentHours) {
      for (Slot l in i?.slots ?? []) {
        if (isDayOfWeekInDateRange(
            int.parse(i?.dayOfWeek ?? '0'),
            Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime,
            Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime)) {
          if (l.isHourSelected == true) {
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
                datesChoosenForWorshipRecurrentHours.value);
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

  selectDate(BuildContext context, PriceData? item) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Déterminer la date initiale du picker
    DateTime initialDate;
    if (endSelectedDate.value?.dayToDisplay != null &&
        endSelectedDate.value?.dayToDisplay != '-') {
      // Si une date de fin est déjà sélectionnée, on l'utilise comme date initiale
      List<String> dateParts = endSelectedDate.value!.dayToDisplay!.split('-');
      DateTime selectedDateTime = DateTime(
          int.parse(dateParts[2]), // année
          int.parse(dateParts[1]), // mois
          int.parse(dateParts[0]) // jour
          );

      // Vérifier si la date sélectionnée est valide (après la date de début)
      if (selectedDateTime.isAfter(
              Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime) ||
          selectedDateTime.isAtSameMomentAs(
              Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime)) {
        initialDate = selectedDateTime;
      } else {
        initialDate =
            Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime;
      }
    } else {
      initialDate = Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime;
    }

    final DateTime? selected = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: initialDate,
      firstDate: Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime,
      lastDate: DateTime(today.year + 5),
      cancelText: 'cancel'.tr,
      confirmText: 'confirm'.tr,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                onPrimary: colorWhite,
                onSurface: colorBlack,
                primary: colorPurpleLight),
            dialogBackgroundColor: Colors.white,
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
            ),
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
              datesChoosenForWorshipRecurrentHours.value);

      // Mettre à jour l'état du bouton de continuation
      canDoApplyAction();
    }
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
    for (PriceData item in worshipRecurrentHours.value) {
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
    for (PriceData item in worshipSpecialHours.value) {
      for (Slot hour in item.slots ?? []) {
        hour.isHourSelected = false;
      }
    }
    worshipSpecialHours.refresh();
  }

  void doResetFilter() {
    // Réinitialiser la date de fin avec la date initiale
    endSelectedDate.value = PriceData.fromJson(Get.arguments[1]);
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
    Get.delete<FilterMassRequestDateController>(force: true);
    goBackToMassRequest();
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
}
