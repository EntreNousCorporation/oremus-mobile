
import 'package:flutter/material.dart';

class OperationTypeMenu {
  final String title;
  final String imageSVG;
  final bool isPngImage;
  final Color activeTint;
  final bool isVisble;
  final Function goToPage;

  OperationTypeMenu( {
    required this.goToPage,
    this.isVisble = true,
    required this.title,
    this.imageSVG = "assets/images/icon_transfertcontroller.svg",
    this.isPngImage=false,
    required this.activeTint,
  });
}