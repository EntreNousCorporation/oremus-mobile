import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
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
      final slotKey = _createSpecialSlotKey(identifier, startTime);
      if (selectedSlotKeys.contains(slotKey)) {
        selectedSlotKeys.remove(slotKey);
      } else {
        selectedSlotKeys.add(slotKey);
      }
      // Mettre à jour l'état de la messe spéciale
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
    resetSelections();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  getArguments() {
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
      initialSelectedDate.value = PriceData.fromJson(Get.arguments[1]);
      endSelectedDate.value = PriceData.fromJson(Get.arguments[1]);

      log('initialSelectedDate ::: ${initialSelectedDate.value?.toJson()}');
      for (var i in worshipRecurrentHours) {
        log('i ::: ${i.toJson()}');
      }

      //on marque la date selectionnée
      doRefreshHoursOnInit();
    }
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

  doResetFilter() {
    resetRecurrentHours();
    resetSpecialHours();
    selectedSlotKeys.clear();
    datesChoosenForWorshipRecurrentHours.clear();
    datesChoosenWorshipSpecialHours.clear();

    // Réinitialiser manuellement tous les slots pour être sûr
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

    // Rafraîchir les listes réactives
    worshipRecurrentHours.refresh();
    worshipSpecialHours.refresh();
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
    var selectedRecurentHours =
        _filterSelectedSlots(datesChoosenForWorshipRecurrentHours);

    log('selectedRecurentHours ::: ${jsonEncode(selectedRecurentHours)}');

    datesChoosen.value = duplicateEventsByRepeat(selectedRecurentHours)
        .where((e) => e.slots?.isNotEmpty == true)
        .toList();

    log('Before datesChoosen ::: ${jsonEncode(selectedRecurentHours)}');
    log('After datesChoosen ::: ${jsonEncode(datesChoosen)}');
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

    // Conversion en liste non-nullable et combinaison
    List<PriceData> recurrentDates = datesChoosenForWorshipRecurrentHours
        .where((date) => date != null)
        .map((date) => date!)
        .toList();

    List<PriceData> specialDates = datesChoosenWorshipSpecialHours
        .where((date) => date != null)
        .map((date) => date!)
        .toList();

    datesChoosen.value = [
      ...recurrentDates,
      ...specialDates,
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

  goBackToMassRequest() {
    Get.back(result: datesChoosen);
  }
}
