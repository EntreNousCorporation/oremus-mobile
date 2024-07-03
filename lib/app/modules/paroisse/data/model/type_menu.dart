
import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

class TypeMenu {
  final String code;
  final String title;
  final String icon;
  final bool isPngImage;
  final Color activeTint;
  final Color bgColor;
  final bool isVisible;
  final Function goToPage;

  TypeMenu( {
    required this.goToPage,
    this.isVisible = true,
    required this.code,
    required this.title,
    this.icon = "",
    this.isPngImage=false,
    required this.activeTint,
    this.bgColor = colorWhite,
  });
}