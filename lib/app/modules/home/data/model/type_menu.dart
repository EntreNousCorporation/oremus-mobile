
import 'package:flutter/material.dart';

class TypeMenu {
  final String code;
  final String title;
  final String icon;
  final bool isPngImage;
  final Color activeTint;
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
  });
}