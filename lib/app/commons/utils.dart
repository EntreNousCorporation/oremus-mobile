import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

extension StringExtension on String {
  String toCapitalize() {
    String? value;
    try {
      value = "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    } catch (error) {
      value = "";
    }
    return value;
  }

  String amountFormat() {
    String value = '';
    var formatter = NumberFormat('#,###');

    value = split('.').first.replaceAll(" ", "");
    try {
      value = formatter
          .format(int.parse(value))
          .replaceAll(',', ' '); // tu as été smart, c'est bien 🙂
    } catch (error) {
      log('amountFormat Catch error => $error');
      value = "-";
    }
    log("AMOUNT_FORMATED --> $value");
    return value;
  }

  String phoneFormat() {
    String value;
    var formatter = NumberFormat('#,##');

    value = replaceAll(RegExp(r'\s'), '');
    try {
      value = formatter
          .format(int.parse(value))
          .replaceAll(',', '  '); // tu as été smart, c'est bien 🙂
    } catch (error) {
      value = '';
    }
    if (value.length.isOdd) {
      value = "${this[0]}$value";
    }
    log("PHONE_FORMATED --> $value");

    return value;
  }
}

String getDay(int code) {
  switch (code) {
    case 0:
      return 'Lundi';
    case 1:
      return 'Mardi';
    case 2:
      return 'Mercredi';
    case 3:
      return 'Jeudi';
    case 4:
      return 'Vendredi';
    case 5:
      return 'Samedi';
    case 6:
      return 'Dimanche';
    default:
      return '';
  }
}

IconData getIcon(String? code) {
  switch (code) {
    case 'REFUSED_PAYMENT':
    case 'NOT_PROCESSED':
    case 'REQUEST_REFUSED':
      return Icons.close_rounded;
    case 'BEING_PROCESSED':
    case 'REQUEST_INITIATED':
    case 'REQUEST_ASSUMED':
      return Icons.autorenew_rounded;
    default:
      return Icons.check;
  }
}

Color getColor(String? code) {
  switch (code) {
    case 'REFUSED_PAYMENT':
    case 'NOT_PROCESSED':
    case 'REQUEST_REFUSED':
      return colorRed;
    case 'BEING_PROCESSED':
    case 'REQUEST_INITIATED':
    case 'REQUEST_ASSUMED':
      return colorBlue2;
    default:
      return colorGreen;
  }
}

String getCustomDate(String? date,
    {String? pattern = AppConstants.TIME_DEFAULT_FORMAT}) {
  if (date == null || date.isEmpty == true) return '-';
  return Jiffy.parse(date).format(pattern: pattern);
}

String getDate(String? date) {
  if (date == null || date.isEmpty == true) return '-';
  return Jiffy.parse(date, pattern: "yyyy-MM-dd'T'HH:mm:ss").yMd;
}

String getDateTime(String? date) {
  if (date == null || date.isEmpty == true) return '-';
  return Jiffy.parse(date, pattern: "yyyy-MM-dd'T'HH:mm:ss").yMMMdjm;
}

String getHour(String? date) {
  if (date == null || date.isEmpty == true) return '-';
  return Jiffy.parse(date, pattern: "yyyy-MM-dd'T'HH:mm:ss").jm;
}

String getCurrentDay() {
  return getDay(Jiffy.now().dateTime.weekday - 1);
}

hideKeyboard() {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
}

double applyElevation() {
  return GetPlatform.isAndroid ? 10 : 0;
}

bool isEventExpired(LiturgicalCelebrationResponse? liturgicalCelebration) {
  return Jiffy.parse(liturgicalCelebration?.startDate ?? '')
      .isBefore(Jiffy.now());
}

shareApp(String message,
    {bool? includeFile = true, String filePath = ''}) async {
  final box = Get.context?.findRenderObject() as RenderBox?;

  ByteData imagebyte = await rootBundle.load(filePath);
  final temp = await getTemporaryDirectory();
  final path = '${temp.path}/logo.png';
  File(path).writeAsBytesSync(imagebyte.buffer.asUint8List());

  if (includeFile == true) {
    await Share.shareXFiles(
      [XFile(path)],
      text: message,
      subject: '',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  } else {
    await Share.share(
      message,
      subject: '',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}

List<PriceData> transformWorshipSpecialHours(
    List<LiturgicalCelebrationResponse> worshipDataList) {
  Map<String, List<Slot>> groupedSlots = {};

  for (var event in worshipDataList) {
    String formattedDate = event.startDate?.split('T')[0] ?? '';
    event.startDateFormatted = formattedDate;
  }

  for (var event in worshipDataList) {
    String day = event.startDateFormatted ?? '';
    if (!groupedSlots.containsKey(day)) {
      groupedSlots[day] = [];
    }
    groupedSlots[day]?.addAll(event.slots ?? []);
  }

  return groupedSlots.entries.map((entry) {
    return PriceData(day: entry.key, slots: entry.value);
  }).toList();
}

List<PriceData> transformWorshipRecurrentHours(
    List<LiturgicalCelebrationResponse> worshipDataList) {

  // Dictionnaire pour regrouper les créneaux par jour de la semaine
  Map<String, List<Slot>> groupedByDay = {};
  Map<String, int> identifierByDay = {}; // Pour garder la correspondance avec l'identifiant

  // Parcourir chaque célébration liturgique
  for (var worshipData in worshipDataList) {
    // Parcourir les heures d'ouverture, si elles existent
    for (var openingTime in worshipData.openingTime ?? []) {
      String dayOfWeek = openingTime.dayOfWeek.toString(); // Jour en string

      // Ajouter les créneaux horaires au bon jour de la semaine
      groupedByDay.putIfAbsent(dayOfWeek, () => []).addAll(openingTime.slots);

      // Associer l'identifiant de la célébration avec le jour correspondant
      identifierByDay[dayOfWeek] = worshipData.identifier;
    }
  }

  // Transformer le dictionnaire en une liste de PriceData avec l'identifiant
  return groupedByDay.entries.map((entry) {
    String dayOfWeek = entry.key;
    List<Slot> slots = entry.value;
    int identifier = identifierByDay[dayOfWeek]!;

    return PriceData(dayOfWeek: dayOfWeek, slots: slots, identifier: identifier);
  }).toList();
}

// Fonction pour obtenir les dates des jours spécifiques
List<DateTime> getNextDatesForDays(List<int> daysOfWeek) {
  List<DateTime> upcomingDates = [];
  DateTime today = DateTime.now();
  int daysInMonth = AppConstants.END_DATE_LIMIT;

  for (int i = 0; i < daysInMonth; i++) {
    DateTime futureDate = today.add(Duration(days: i));
    if (daysOfWeek.contains(futureDate.weekday % 7)) {
      upcomingDates.add(DateTime(futureDate.year, futureDate.month,
          futureDate.day)); // Ignorer les heures pour comparaison
    }
  }
  return upcomingDates;
}

List<PriceData> duplicateAllowedDaysBasedOnRepeat(List<PriceData> allowedDays) {
  List<PriceData> duplicatedList = [];

  // Parcourir chaque AllowedDay dans la liste
  for (var allowedDay in allowedDays) {
    for (int i = 0; i < int.parse(allowedDay.repeat.toString()); i++) {
      // Dupliquer chaque objet pour chaque occurrence, en assignant une date différente
      if (i < allowedDay.dates!.length) {
        duplicatedList.add(allowedDay.cloneWithDate(allowedDay.dates![i]));
      }
    }
  }
  return duplicatedList;
}

List<PriceData> duplicateEventsByRepeat(List<PriceData> events) {
  List<PriceData> duplicatedEvents = [];
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  for (var event in events) {
    // Vérifier que l'événement a une liste de dates et au moins une date
    if (event.dates?.isNotEmpty == true) {
      for (int i = 0; i < int.parse(event.repeat.toString()); i++) {
        // Si le nombre de répétitions dépasse le nombre de dates, utiliser modulo pour réutiliser les dates
        String dateToAssign = formatter.format(event.dates![i % event.dates!.length]);

        // Créer une copie de l'événement et mettre à jour le champ 'day'
        PriceData duplicatedEvent = PriceData(
          day: dateToAssign,
          dayToDisplay: event.dayToDisplay,
          dayOfWeek: event.dayOfWeek,
          isDaySelected: event.isDaySelected,
          repeat: event.repeat,
          identifier: event.identifier,
          slots: event.slots?.map((slot) => Slot(
            identifier: slot.identifier,
            createdAt: slot.createdAt,
            updatedAt: slot.updatedAt,
            createdBy: slot.createdBy,
            modifiedBy: slot.modifiedBy,
            startTime: slot.startTime,
            endTime: slot.endTime,
            isHourSelected: slot.isHourSelected,
          )).toList(),
          dates: event.dates, // Garder la liste originale des dates
        );

        // Ajouter l'événement dupliqué à la liste
        duplicatedEvents.add(duplicatedEvent);
      }
    }
  }

  return duplicatedEvents;
}

bool isDayOfWeekInDateRange(int dayOfWeek, DateTime startDate, DateTime endDate) {
  // Vérifier que la date de début est avant ou égale à la date de fin
  if (startDate.isAfter(endDate)) {
    return false;
  }

  // Parcourir chaque jour dans la plage de dates
  for (DateTime currentDate = startDate;
  currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
  currentDate = currentDate.add(const Duration(days: 1))) {
    // Vérifier si le jour de la semaine actuel correspond au jour recherché
    if ((currentDate.weekday - 1) == dayOfWeek) {
      return true; // Trouvé, retourner vrai
    }
  }
  return false; // Pas trouvé, retourner faux
}

// Fonction pour compter les occurrences des jours autorisés dans la plage de dates
List<PriceData?> countOccurrencesAndAssignDates(
    DateTime start, DateTime end, List<PriceData?> allowedDays) {

  // Vider la liste des dates et du repeat pour chaque allowedDay avant de commencer
  for (var allowedDay in allowedDays) {
    allowedDay?.dates = [];
    allowedDay?.repeat = 0;
  }

  // Itérer sur chaque jour de la plage de dates
  for (DateTime currentDate = start;
  currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end);
  currentDate = currentDate.add(const Duration(days: 1))) {
    int currentDayOfWeek = currentDate.weekday - 1;

    // Vérifier si le jour de la semaine est dans la liste des allowedDays
    for (var allowedDay in allowedDays) {
      if (int.parse(allowedDay?.dayOfWeek ?? '0') == currentDayOfWeek) {
        // Incrémenter le compteur 'repeat'
        allowedDay?.repeat = (allowedDay.repeat ?? 0) + 1;

        // Ajouter la date correspondante à la liste des dates
        allowedDay?.dates?.add(currentDate);
      }
    }
  }
  return allowedDays;
}