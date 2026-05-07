import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
      OremusLogger.error('amountFormat Catch error => $error');
      value = "-";
    }
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
    case 'DONATION_INITIATED':
      return colorBlue2;
    default:
      return colorGreen;
  }
}

doLaunchEmail(String email) async {
  if (await canLaunchUrlString(Uri.encodeFull(
      "mailto:$email?subject=Besoin d'information&body=")) ==
      true) {
    launchUrlString(
        Uri.encodeFull("mailto:$email?subject=Besoin d'information&body="));
  } else {
    log("Can't launch email");
  }
}

doLaunchPhone(String phone) async {
  if (await canLaunchUrlString("tel:$phone") == true) {
    launchUrlString("tel:$phone");
  } else {
    log("Can't launch phone number");
  }
}

doLaunchUrl(String link) async {
  if (await canLaunchUrlString(link) == true) {
    launchUrlString(link);
  } else {
    log("Can't launch url");
    showNotification(
      message: 'Aucune information trouvée',
    );
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
  if (liturgicalCelebration == null || liturgicalCelebration.startDate == null) {
    return true;
  }

  final eventDate = Jiffy.parse(liturgicalCelebration.startDate!, pattern: AppConstants.TIME_ZONE_FORMAT);
  final now = Jiffy.now();

  // Si l'événement est dans le futur (jour futur), il n'est pas expiré
  if (eventDate.startOf(Unit.day).isAfter(now.startOf(Unit.day))) {
    return false;
  }

  // Si l'événement est d'un jour passé, il est expiré
  if (eventDate.startOf(Unit.day).isBefore(now.startOf(Unit.day))) {
    return true;
  }

  // Si on est le même jour que l'événement, vérifier les slots
  if (liturgicalCelebration.slots == null || liturgicalCelebration.slots!.isEmpty) {
    // Pas de slots, comparer juste avec la startDate complète
    return eventDate.isBefore(now);
  }

  // Vérifier si au moins un slot n'est pas encore commencé
  for (final slot in liturgicalCelebration.slots!) {
    if (slot.startTime != null) {
      // Parser l'heure de début du slot
      final timeParts = slot.startTime!.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);
      final seconds = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;

      // Combiner la date de l'événement avec l'heure de début du slot
      final slotStartDateTime = eventDate.clone()
          .startOf(Unit.day)
          .add(hours: hours, minutes: minutes, seconds: seconds);

      // Si au moins un slot n'a pas encore commencé, l'événement n'est pas expiré
      if (slotStartDateTime.isAfter(now)) {
        return false;
      }
    }
  }

  // Tous les slots ont commencé (ou sont passés)
  return true;
}

shareApp(String message, {bool? includeFile = true, String filePath = ''}) async {
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

List<PriceData> transformWorshipSpecialHours(List<LiturgicalCelebrationResponse> specialCelebrations) {
  List<PriceData> result = [];

  for (var celebration in specialCelebrations) {
    if (celebration.startDate == null) continue;

    // Convertir la date de début en format 'yyyy-MM-dd'
    DateTime? startDate = Jiffy.parse(
        celebration.startDate ?? "",
        pattern: AppConstants.TIME_ZONE_FORMAT
    ).dateTime;

    String formattedDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

    // Vérifier si cette date existe déjà dans notre liste résultante
    int dateIndex = result.indexWhere((item) => item.day == formattedDate);

    if (dateIndex >= 0) {
      // Si la date existe déjà, ajouter les slots à cette date
      List<Slot> existingSlots = result[dateIndex].slots ?? [];
      List<Slot> newSlots = celebration.slots ?? [];

      // Fusionner les slots sans doublon
      for (var newSlot in newSlots) {
        if (!existingSlots.any((existingSlot) =>
        existingSlot.startTime == newSlot.startTime)) {
          existingSlots.add(newSlot);
        }
      }

      result[dateIndex].slots = existingSlots;
    } else {
      // Sinon, créer une nouvelle entrée pour cette date
      result.add(PriceData(
        day: formattedDate,
        // Calculer le jour de la semaine (0-6, dimanche-samedi)
        dayOfWeek: (startDate.weekday % 7).toString(),
        name: celebration.name,
        slots: celebration.slots ?? [],
        // Format pour l'affichage: 'dd-MM-yyyy'
        dayToDisplay: "${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}",
      ));
    }
  }
  return result;
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

List<PriceData> transformWorshipRecurrentHours(List<LiturgicalCelebrationResponse> recurrentCelebrations) {
  List<PriceData> result = [];

  for (var celebration in recurrentCelebrations) {
    // Pour chaque célébration récurrente, parcourir les heures d'ouverture
    for (var openingTime in celebration.openingTime ?? []) {
      // Vérifier si ce jour existe déjà dans notre liste résultante
      int dayIndex = result.indexWhere((item) =>
      item.dayOfWeek == openingTime.dayOfWeek?.toString()
      );

      if (dayIndex >= 0) {
        // Si le jour existe déjà, ajouter les slots à ce jour
        List<Slot> existingSlots = result[dayIndex].slots ?? [];
        List<Slot> newSlots = openingTime.slots ?? [];

        // Fusionner les slots sans doublon
        for (var newSlot in newSlots) {
          if (!existingSlots.any((existingSlot) =>
          existingSlot.startTime == newSlot.startTime)) {
            existingSlots.add(newSlot);
          }
        }

        result[dayIndex].slots = existingSlots;
      } else {
        // Sinon, créer une nouvelle entrée pour ce jour
        result.add(PriceData(
          dayOfWeek: openingTime.dayOfWeek?.toString() ?? "0",
          slots: openingTime.slots ?? [],
          repeat: 1, // Par défaut, une répétition
        ));
      }
    }
  }
  return result;
}

List<DateTime> getNextDatesForDays(List<int> daysOfWeek) {
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
  // Vérifier si les dates sont valides
  int standardDayOfWeek = dayOfWeek + 1;

  // Parcourir la période jour par jour
  for (DateTime day = startDate; !day.isAfter(endDate); day = day.add(const Duration(days: 1))) {
    if (day.weekday == standardDayOfWeek) {
      return true;
    }
  }

  return false;
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
List<PriceData?> countOccurrencesAndAssignDates(DateTime start, DateTime end, List<PriceData?> allowedDays) {

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
        cleanedJson[key] = removeNullFields(value);
      } else if (value is List) {
        cleanedJson[key] = value
            .where((element) => element != null)
            .map((e) => e is Map<String, dynamic> ? removeNullFields(e) : e)
            .toList();
      } else {
        cleanedJson[key] = value;
      }
    }
  });
  return cleanedJson;
}

/// Prépare le fichier d'image pour l'artwork du lecteur audio
/// Retourne le chemin du fichier copié dans le stockage local
Future<String> prepareArtworkFile() async {
  try {
    // Obtenir le répertoire de documents
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/rosary_artwork.png';

    // Vérifier si le fichier existe déjà
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }

    // Charger l'image depuis les assets
    final ByteData data = await rootBundle.load(Assets.imagesLogoSquare);
    final Uint8List bytes = data.buffer.asUint8List();

    // Écrire le fichier
    await file.writeAsBytes(bytes);
    return filePath;
  } catch (e) {
    // En cas d'erreur, retourner un chemin vide
    return '';
  }
}

extension ColorExtension on Color {
  Color withValues({
    int? red,
    int? green,
    int? blue,
    double? alpha,
  }) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? opacity,
    );
  }
}