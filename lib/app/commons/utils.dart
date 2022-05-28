import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

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
    String value ;
    var formatter = NumberFormat('#,###');

    value = replaceAll(" ", "");
    try {
      value = formatter.format(int.parse(value)).replaceAll(',', ' '); // tu as été smart, c'est bien 🙂
    } catch(error) {
      value = "";
    }
    log("AMOUNT_FORMATED --> ${value}");
    return value;
  }

  String phoneFormat() {
    String value ;
    var formatter = NumberFormat('#,##');

    value = replaceAll(" ", "");
    try{
      value = formatter.format(int.parse(value)).replaceAll(',', '  '); // tu as été smart, c'est bien 🙂
    } catch(error){
      value = "";
    }
    if(value.length.isOdd){
      value="${this[0]}$value";
    }
    log("PHONE_FORMATED --> ${value}");

    return value;
  }
}

String getDay(int code) {
  //log('getCurrentDay 2 => ${getDay(Jiffy(DateTime.now()).day - 1)}');
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

String getCurrentDay() {
  return getDay(Jiffy(DateTime.now()).day -1);
}

hideKeyboard() {
  //FocusManager.instance.primaryFocus?.unfocus();
  WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
}

double applyElevation() {
  return GetPlatform.isAndroid ? 10 : 0;
}