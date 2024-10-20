import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';

import 'app_colors.dart';

const TextStyle cardTextStyle =
    TextStyle(color: colorGreyHint, fontSize: 16, fontWeight: FontWeight.bold);

class TextStyles {
  static TextStyle montserratRegular({
    double textSize = TextSizes.sixteen,
    Color textColor = colorGrey1,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_regular",
        fontSize: textSize,
        color: textColor,
        decoration: textDecoration,
      );

  static TextStyle montserratMedium({
    double textSize = TextSizes.sixteen,
    Color textColor = colorGrey1,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_medium",
        fontSize: textSize,
        color: textColor,
        decoration: textDecoration,
      );

  static TextStyle montserratBold({
    double textSize = TextSizes.twenty,
    Color textColor = colorBlack,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_bold",
        fontSize: textSize,
        color: textColor,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
      );

  static TextStyle montserratSemiBold({
    double textSize = TextSizes.sixteen,
    Color textColor = colorBlack,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_semi_bold",
        fontSize: textSize,
        color: textColor,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
      );

  static TextStyle montserratItalic({
    double textSize = TextSizes.sixteen,
    Color textColor = colorGrey1,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_italic",
        fontSize: textSize,
        color: textColor,
        decoration: textDecoration,
      );

  static TextStyle montserratMediumItalic({
    double textSize = TextSizes.sixteen,
    Color textColor = colorGrey1,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_medium_italic",
        fontSize: textSize,
        color: textColor,
        decoration: textDecoration,
      );

  static TextStyle montserratBoldItalic({
    double textSize = TextSizes.twenty,
    Color textColor = colorBlack,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_bold_italic",
        fontSize: textSize,
        color: textColor,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
      );

  static TextStyle montserratSemiBoldItalic({
    double textSize = TextSizes.twelve,
    Color textColor = colorBlack,
    TextDecoration textDecoration = TextDecoration.none,
  }) =>
      const TextStyle().copyWith(
        fontFamily: "montserrat_semi_bold_italic",
        fontSize: textSize,
        color: textColor,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
      );
}

class Separators {
  static Widget minimunHorizontal() {
    return const SizedBox(
      width: 8,
    );
  }

  static Widget minimunVertical() {
    return const SizedBox(
      height: 8,
    );
  }

  static Widget normalVertical() {
    return const SizedBox(
      height: 20,
    );
  }

  static Widget normal1Vertical() {
    return const SizedBox(
      height: 24,
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

  static Widget maximum1Vertical() {
    return const SizedBox(
      height: 40,
    );
  }

  static Widget customSizeVertical(double size) {
    return SizedBox(
      height: size,
    );
  }

  static Widget customSizeHorizontal(double size) {
    return SizedBox(
      width: size,
    );
  }

  static Widget maximumHorizontal() {
    return const SizedBox(
      width: 30,
    );
  }
}
