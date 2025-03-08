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
    case 'REJECTED':
      return Icons.close_rounded;
    case 'BEING_PROCESSED':
    case 'REQUEST_INITIATED':
    case 'REQUEST_ASSUMED':
    case 'CLAIM_INITIATED':
    case 'IN_PROGRESS':
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
    case 'REJECTED':
      return colorRed;
    case 'IN_PROGRESS':
      return colorOrange;
    case 'BEING_PROCESSED':
    case 'REQUEST_INITIATED':
    case 'REQUEST_ASSUMED':
    case 'CLAIM_INITIATED':
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

void configStatusBar({
  Color? statusColor,
  Brightness? iOSStatusBarBrightness,
  Brightness? statusBarIconBrightness,
}) {
  // Vérifiez si la plateforme est Android
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: statusBarIconBrightness ?? Brightness.dark,
      statusBarIconBrightness: statusBarIconBrightness ?? Brightness.dark,
      statusBarColor: statusColor ?? colorTransparent,
    ));
  }

  // Vérifiez si la plateforme est iOS
  if (Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: iOSStatusBarBrightness ?? Brightness.dark,
      statusBarColor: statusColor ?? colorBlack,
    ));
  }
}

List<PriceData> transformWorshipSpecialHours(
    List<LiturgicalCelebrationResponse> worshipDataList) {

  // Map pour stocker les célébrations par date
  Map<String, List<LiturgicalCelebrationResponse>> celebrationsByDate = {};

  // Première passe : formater les dates et grouper les célébrations
  for (var event in worshipDataList) {
    // Formater la date (garder seulement la partie date)
    String formattedDate = event.startDate?.split('T')[0] ?? '';
    event.startDateFormatted = formattedDate;

    // Ne prendre que les messes spéciales
    if (event.type?.code == 'SPECIAL_MASS') {
      String day = event.startDateFormatted ?? '';
      if (!celebrationsByDate.containsKey(day)) {
        celebrationsByDate[day] = [];
      }
      celebrationsByDate[day]?.add(event);
    }
  }

  // Transformer en liste de PriceData
  return celebrationsByDate.entries.map((entry) {
    String day = entry.key;
    List<LiturgicalCelebrationResponse> celebrations = entry.value;

    // Collecter tous les slots de toutes les messes spéciales pour cette date
    List<Slot> allSlots = [];
    String? celebrationName;  // Pour stocker le nom de la célébration

    for (var celebration in celebrations) {
      if (celebration.slots != null) {
        allSlots.addAll(celebration.slots!);
      }
      // Prendre le nom de la première célébration comme nom représentatif
      celebrationName ??= celebration.name;
    }

    // Trier les slots par heure
    allSlots.sort((a, b) {
      final timeA = parseTime(a.startTime ?? '');
      final timeB = parseTime(b.startTime ?? '');
      return compareTimes(timeA, timeB);
    });

    // Créer le PriceData avec tous les slots et les informations des célébrations
    return PriceData(
        day: day,
        slots: allSlots,
        celebrationType: 'SPECIAL_MASS',
        name: celebrationName  // Ajouter le nom de la célébration ici
    );
  }).toList();
}


// Function utilitaire pour parser et comparer les heures
TimeOfDay parseTime(String time) {
  final parts = time.split(':');
  return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1])
  );
}

int compareTimes(TimeOfDay a, TimeOfDay b) {
  if (a.hour != b.hour) return a.hour.compareTo(b.hour);
  return a.minute.compareTo(b.minute);
}

List<PriceData> transformWorshipRecurrentHours(
    List<LiturgicalCelebrationResponse> worshipDataList) {

  // Dictionnaire pour regrouper les créneaux par jour de la semaine
  Map<String, List<Slot>> groupedByDay = {};
  Map<String, int> identifierByDay = {};
  Map<String, LiturgicalCelebrationResponse> celebrationByDay = {};

  // Parcourir chaque célébration liturgique
  for (var worshipData in worshipDataList) {
    // Parcourir les heures d'ouverture, si elles existent
    for (var openingTime in worshipData.openingTime ?? []) {
      String dayOfWeek = openingTime.dayOfWeek.toString();

      // Si nous n'avons pas encore de célébration pour ce jour
      // ou si la célébration existante n'est pas une messe
      // ou si c'est une messe et que la nouvelle célébration est aussi une messe
      bool shouldUpdate = !celebrationByDay.containsKey(dayOfWeek) ||
          celebrationByDay[dayOfWeek]?.type?.code != 'MASS' ||
          (celebrationByDay[dayOfWeek]?.type?.code == 'MASS' && worshipData.type?.code == 'MASS');

      if (shouldUpdate) {
        // Mettre à jour ou ajouter les créneaux pour ce jour
        groupedByDay[dayOfWeek] = openingTime.slots;
        identifierByDay[dayOfWeek] = worshipData.identifier;
        celebrationByDay[dayOfWeek] = worshipData;
      }
    }
  }

  // Transformer le dictionnaire en une liste de PriceData
  return groupedByDay.entries.map((entry) {
    String dayOfWeek = entry.key;
    List<Slot> slots = entry.value;
    int identifier = identifierByDay[dayOfWeek]!;
    LiturgicalCelebrationResponse celebration = celebrationByDay[dayOfWeek]!;

    return PriceData(
        dayOfWeek: dayOfWeek,
        slots: slots,
        identifier: identifier,
        celebrationType: celebration.type?.code,
        name: celebration.name
    );
  }).toList();
}

// Fonction pour obtenir les dates des jours spécifiques
/*List<DateTime> getNextDatesForDays(List<int> daysOfWeek) {
  List<DateTime> upcomingDates = [];
  DateTime today = DateTime.now();
  int daysInMonth = 365; //AppConstants.END_DATE_LIMIT;

  for (int i = 0; i < daysInMonth; i++) {
    DateTime futureDate = today.add(Duration(days: i));
    if (daysOfWeek.contains(futureDate.weekday % 7)) {
      upcomingDates.add(DateTime(futureDate.year, futureDate.month,
          futureDate.day)); // Ignorer les heures pour comparaison
    }
  }
  return upcomingDates;
}*/

List<DateTime> getNextDatesForDays(List<int> daysOfWeek) {
  log('getNextDatesForDays ::: ${daysOfWeek}');
  List<DateTime> upcomingDates = [];
  DateTime now = DateTime.now();
  int daysInMonth = AppConstants.END_DATE_LIMIT;

  // Determine the start date based on the current time
  DateTime startDate;

  // Between 00h01 and 09h00, requests are valid for the same day from 12h
  if (now.hour >= 0 && now.hour <= 9) {
    startDate = DateTime(now.year, now.month, now.day, 12); // Set time to 12h00 today
  }
  // Between 09h01 and 15h00, requests are valid for the same day from 18h
  else if (now.hour > 9 && now.hour <= 15) {
    startDate = DateTime(now.year, now.month, now.day, 18); // Set time to 18h00 today
  }
  // Between 15h01 and 00h00, requests are valid for the next day from 12h
  else {
    startDate = DateTime(now.year, now.month, now.day + 1, 12); // Set time to 12h00 next day
  }

  // Generate future dates based on the start date and the daysOfWeek
  for (int i = 0; i < daysInMonth; i++) {
    DateTime futureDate = startDate.add(Duration(days: i));
    if (daysOfWeek.contains(futureDate.weekday)) {
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

bool isDayOfWeekInDateRangeB(int dayOfWeek, DateTime startDate, DateTime endDate) {
  // Vérifier que la date de début est avant ou égale à la date de fin
  if (startDate.isAfter(endDate)) {
    return false;
  }

  // Ajuster l'heure de début en fonction des contraintes horaires du tableau
  DateTime adjustedStartDate = startDate;
  if (startDate.hour >= 0 && startDate.hour < 9) {
    // Demande entre 00h01 et 09h00 => début possible à 12h du même jour
    adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day, 12);
  } else if (startDate.hour >= 9 && startDate.hour < 15) {
    // Demande entre 09h01 et 15h00 => début possible à 18h du même jour
    adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day, 18);
  } else if (startDate.hour >= 15 && startDate.hour < 24) {
    // Demande entre 15h01 et 00h00 => début possible à 12h du lendemain
    adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day + 1, 12);
  }

  // Parcourir chaque jour dans la plage de dates ajustée
  for (DateTime currentDate = adjustedStartDate;
  currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
  currentDate = currentDate.add(const Duration(days: 1))) {
    log('dayOfWeek ::: $dayOfWeek');
    log('dayOfWeek ::: ${(currentDate.weekday - 1)}');
    // Vérifier si le jour de la semaine actuel correspond au jour recherché
    if ((currentDate.weekday - 1) == dayOfWeek) {
      return true; // Jour correspondant trouvé
    }
  }
  return false; // Pas de correspondance trouvée
}

bool isDayOfWeekInDateRangeBB(
    int dayOfWeek, DateTime startDate, DateTime endDate, DateTime requestTime) {
  // Vérifier que la date de début est avant ou égale à la date de fin
  if (startDate.isAfter(endDate)) {
    return false;
  }

  // Calculer les contraintes basées sur l'heure de la demande
  DateTime adjustedStartDate = startDate;
  if (requestTime.hour >= 0 && requestTime.hour < 9) {
    // Demande entre 00h01 et 09h00 => début possible à 12h du même jour
    adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day, 12);
  } else if (requestTime.hour >= 9 && requestTime.hour < 15) {
    // Demande entre 09h01 et 15h00 => début possible à 18h du même jour
    adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day, 18);
  } else if (requestTime.hour >= 15 && requestTime.hour < 24) {
    // Demande entre 15h01 et 00h00 => début possible à 12h du lendemain
    adjustedStartDate = DateTime(startDate.year, startDate.month, startDate.day + 1, 12);
  }

  // Parcourir chaque jour dans la plage de dates ajustée
  for (DateTime currentDate = adjustedStartDate;
  currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
  currentDate = currentDate.add(const Duration(days: 1))) {
    // Vérifier si le jour de la semaine actuel correspond au jour recherché
    if ((currentDate.weekday - 1) == dayOfWeek) {
      return true; // Jour correspondant trouvé
    }
  }
  return false; // Pas de correspondance trouvée
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

Map<String, dynamic> removeNullFields(Map<String, dynamic> json) {
  Map<String, dynamic> cleanedJson = {};
  json.forEach((key, value) {
    if (value != null) {
      if (value is Map<String, dynamic>) {
        // Traitement récursif des objets imbriqués
        var cleaned = removeNullFields(value);
        if (cleaned.isNotEmpty) {
          cleanedJson[key] = cleaned;
        }
      } else if (value is List) {
        // Traitement des listes
        var cleanedList = value.map((item) {
          if (item == null) return null;
          if (item is Map<String, dynamic>) {
            return removeNullFields(item);
          }
          return item;
        }).where((item) => item != null).toList();

        if (cleanedList.isNotEmpty) {
          cleanedJson[key] = cleanedList;
        }
      } else {
        // Valeurs simples non nulles
        cleanedJson[key] = value;
      }
    }
  });
  return cleanedJson;
}