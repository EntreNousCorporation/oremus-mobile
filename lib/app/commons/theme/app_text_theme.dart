import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';

import 'app_colors.dart';

const TextStyle cardTextStyle =
    TextStyle(color: colorGreyHint, fontSize: 16, fontWeight: FontWeight.bold);

class TextStyles {
  static TextStyle avenirMedium(
          {double textSize = TextSizes.sixteen,
          Color textColor = colorGrey1}) =>
      const TextStyle().copyWith(
          fontFamily: "avenir_regular", fontSize: textSize, color: textColor);

  static TextStyle avenirBold(
          {double textSize = TextSizes.twenty, Color textColor = colorBlack}) =>
      const TextStyle().copyWith(
          fontFamily: "avenir_bold",
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.bold);

  static TextStyle avenirDemiBold(
          {double textSize = TextSizes.twelve, Color textColor = colorBlack}) =>
      const TextStyle().copyWith(
          fontFamily: "avenir_demi_bold",
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.bold);
}

class Separators {
  static Widget minimunHorizontal() {
    return const SizedBox(
      width: 10,
    );
  }

  static Widget minimunVertical() {
    return const SizedBox(
      height: 10,
    );
  }

  static Widget normalVertical() {
    return const SizedBox(
      height: 20,
    );
  }

  static Widget normalHorizontal() {
    return const SizedBox(
      width: 20,
    );
  }

  static Widget maximumVertical() {
    return const SizedBox(
      height: 30,
    );
  }
}
