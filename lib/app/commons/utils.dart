import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

extension StringExtension on String {
  String toCapitalize() {
    String? value ;
    try{
      value = "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    } catch(error){
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
    String value ;
    var formatter = NumberFormat('#,##');

    value = replaceAll(RegExp(r'\s'), '');
    try{
      value = formatter.format(int.parse(value)).replaceAll(',', '  '); // tu as été smart, c'est bien 🙂
    } catch(error){
      value = '';
    }
    if(value.length.isOdd){
      value="${this[0]}$value";
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
      return colorTurquois;
  }
}

String getCustomDate(String? date, {String? pattern = AppConstants.TIME_DEFAULT_FORMAT}) {
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
  return getDay(Jiffy.now().dateTime.weekday -1);
}

hideKeyboard() {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
}

double applyElevation() {
  return GetPlatform.isAndroid ? 10 : 0;
}

bool isEventExpired(LiturgicalCelebrationResponse? liturgicalCelebration) {
  return Jiffy.parse(liturgicalCelebration?.startDate ?? '').isBefore(Jiffy.now());
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