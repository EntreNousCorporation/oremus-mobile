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

class FilterMassRequestDateController extends GetxController/* with WidgetsBindingObserver*/ {
  FilterMassRequestDateController();

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

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      worshipHours.value = Get.arguments[0];
      worshipRecurrentHoursTemp.value = worshipHours.where((element) => element.isRecurrent == true).toList();
      worshipSpecialHoursTemp.value = worshipHours.where((element) => element.isRecurrent == false && (Jiffy.parse(element.startDate ?? Jiffy.now().format(), pattern: AppConstants.TIME_ZONE_FORMAT).isAfter(Jiffy.now().add(hours: 24)))).toList();

      worshipRecurrentHours.value = transformWorshipRecurrentHours(worshipRecurrentHoursTemp);
      worshipSpecialHours.value = transformWorshipSpecialHours(worshipSpecialHoursTemp);
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

  doRefreshHoursOnInit() {
    for (PriceData i in worshipRecurrentHours) {
      if (int.parse(i.dayOfWeek ?? '0') == (int.parse(initialSelectedDate.value?.dayOfWeek.toString() ?? '1') - 1)) {
        for (Slot l in i.slots ?? []) {
          if (l.identifier == initialSelectedDate.value?.slots?.first.identifier) {
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
        if (isDayOfWeekInDateRange(int.parse(i?.dayOfWeek ?? '0'), Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime, Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime)) {
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

  onWorshipRecurrentHoursSelected(PriceData? hour, bool isDateSelected, {String? hourSelected = ''}) {
    //todo:- choisir les dates correspondantes pour chaque weekday à la plage selectionnée
    worshipRecurrentHours.refresh();
    if (isDateSelected) {
      var hasData = datesChoosenForWorshipRecurrentHours.firstWhereOrNull((element) => (element?.identifier == hour?.identifier) && (element?.dayOfWeek == hour?.dayOfWeek));
      if (hasData == null) {
        worshipRecurrentHours.refresh();
        datesChoosenForWorshipRecurrentHours.add(hour);
        datesChoosenForWorshipRecurrentHours.value = countOccurrencesAndAssignDates(Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime, Jiffy.parse(endSelectedDate.value?.day ?? '').dateTime, datesChoosenForWorshipRecurrentHours.value);
      } else {}
    } else {
      worshipRecurrentHours.refresh();
    }
    for (var i in datesChoosenForWorshipRecurrentHours) {
      log('datesChoosenForWorshipRecurrentHours ::: ${i?.toJson()}');
    }
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
    log('initialSelectedDate ::: ${initialSelectedDate.value?.dayToDisplay}');
    final weekDay = int.parse(item?.dayOfWeek ?? '0');
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Trouver la prochaine date valide
    DateTime initialDate = _findNextValidDate(today, (weekDay + 1));

    final DateTime? selected = await showDatePicker(
      //locale: Locale('fr', 'FR'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime,
      firstDate: Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime,
      lastDate: DateTime(today.year + 5),
      cancelText: 'cancel'.tr,
      confirmText: 'confirm'.tr,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
                onPrimary: colorWhite, // selected text color
                onSurface: colorBlack, // default text color
                primary: colorPurpleLight // circle color
                ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorWhite, textStyle:
                    TextStyles.montserratRegular(textSize: TextSizes.fourteen), // color of button's letters
                backgroundColor: colorPurpleLight, // Background color
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
      String day = selected.day.toString();
      String month = selected.month.toString();
      if (selected.day < 10) {
        day = "0$day";
      }
      if (selected.month < 10) {
        month = "0$month";
      }
      endSelectedDate.value?.day = "${selected.year}-$month-$day";
      endSelectedDate.value?.dayToDisplay = "$day-$month-${selected.year}";
      endSelectedDate.refresh();
      for (var i in datesChoosenForWorshipRecurrentHours) {
        log('Before datesChoosenForWorshipRecurrentHours i ::: ${i?.toJson()}');
      }
      doRefreshHoursAfterAction();
      datesChoosenForWorshipRecurrentHours.value = countOccurrencesAndAssignDates(Jiffy.parse(initialSelectedDate.value?.day ?? '').dateTime, selected, datesChoosenForWorshipRecurrentHours.value);
      for (var i in datesChoosenForWorshipRecurrentHours) {
        log('After datesChoosenForWorshipRecurrentHours i ::: ${i?.toJson()}');
      }
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
                  style: TextStyles
                      .montserratMedium(
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
        slots: day?.slots?.where((slot) => slot.isHourSelected == true).toList(),
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
    canDoApplyAction();
    hideKeyboard();
  }

  doResetAndCloseFilter() {
    doResetFilter();
    Get.delete<FilterMassRequestDateController>(force: true);
    goBackToMassRequest();
  }

  canDoApplyAction() {
    bool hasSelectedSpecialHours = false;
    bool hasSelectedRecurrentHours = false;
    bool hasSelectedRecurrentDay = false;
    for (PriceData? item in datesChoosenWorshipSpecialHours) {
      var slots =
          item?.slots?.where((element) => element.isHourSelected == true);
      if (slots?.isNotEmpty == true) {
        hasSelectedSpecialHours = true;
        break;
      }
    }
    for (PriceData? item in datesChoosenForWorshipRecurrentHours) {
      hasSelectedRecurrentDay = item?.isDaySelected == true;
      var slots = item?.slots?.where((element) => element.isHourSelected == true);
      if (slots?.isNotEmpty == true) {
        hasSelectedRecurrentHours = true;
        break;
      }
    }
    enabledApplyButton.value = hasSelectedRecurrentHours || hasSelectedSpecialHours;
  }

  moveToRecap() {
    if (enabledApplyButton.value) {
      datesChoosen.clear();
      var selectedRecurentHours = _filterSelectedSlots(datesChoosenForWorshipRecurrentHours);
      var selectedSpecialHours = _filterSelectedSlots(datesChoosenWorshipSpecialHours);
      datesChoosen.addAll(selectedRecurentHours);
      //log('Before datesChoosen ::: ${jsonEncode(datesChoosen)}');
      datesChoosen.value = duplicateEventsByRepeat(datesChoosen.value);
      //datesChoosen.value = _mergeDayLists(selectedRecurentHours, selectedSpecialHours);
      log('After datesChoosen ::: ${jsonEncode(datesChoosen)}');

      recapDialog();
    }
  }

  goBackToMassRequest() {
    Get.back(result: datesChoosen);
  }

  List<PriceData> _mergeDayLists(List<PriceData> list1, List<PriceData> list2) {
    // Créer une map pour stocker les jours fusionnés
    Map<String, PriceData> mergedDays = {};

    // Fusionner les jours de la première liste
    for (var day in list1) {
      mergedDays[day.day ?? ''] = day;
    }

    // Fusionner les jours de la deuxième liste
    for (var day in list2) {
      if (mergedDays.containsKey(day.day)) {
        // Si le jour existe déjà, fusionner les slots
        mergedDays[day.day]?.slots?.addAll(day.slots ?? []);
      } else {
        // Sinon, ajouter le nouveau jour
        mergedDays[day.day ?? ''] = day;
      }
    }

    // Convertir la map en liste et la trier par date
    List<PriceData> result = mergedDays.values.toList();
    result.sort((a, b) => b.day?.compareTo(a.day ?? '') ?? -1);

    return result;
  }
}
