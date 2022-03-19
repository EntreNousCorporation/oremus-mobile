import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
final ThemeData appThemeData = ThemeData(
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.dark, // 2
  ),
  primaryColor: colorGreen,
  splashColor: colorWhite,
  highlightColor: colorGreen,
  primaryColorDark: colorGreen,
  fontFamily: 'avenir_regular',
 //brightness: Brightness.light,
 /* textTheme: TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
  ),*/ colorScheme: ColorScheme.fromSwatch().copyWith(secondary: colorGreen),
);
