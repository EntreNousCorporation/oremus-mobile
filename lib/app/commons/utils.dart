import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

hideKeyboard() {
  //FocusManager.instance.primaryFocus?.unfocus();
  WidgetsBinding.instance?.focusManager.primaryFocus?.unfocus();
}