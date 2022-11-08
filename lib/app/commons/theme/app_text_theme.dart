import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';

import 'app_colors.dart';

const TextStyle cardTextStyle =
    TextStyle(color: colorGreyHint, fontSize: 16, fontWeight: FontWeight.bold);

class TextStyles {
  static TextStyle montserratRegular(
          {double textSize = TextSizes.sixteen,
          Color textColor = colorGrey1}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_regular",
          fontSize: textSize,
          color: textColor);

  static TextStyle montserratMedium(
          {double textSize = TextSizes.sixteen,
          Color textColor = colorGrey1}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_medium",
          fontSize: textSize,
          color: textColor);

  static TextStyle montserratBold({
    double textSize = TextSizes.twenty,
    Color textColor = colorBlack,
  }) => const TextStyle().copyWith(
          fontFamily: "montserrat_bold",
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.bold,
  );

  static TextStyle montserratSemiBold(
          {double textSize = TextSizes.twelve, Color textColor = colorBlack}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_semi_bold",
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.bold);

  static TextStyle montserratItalic(
          {double textSize = TextSizes.sixteen,
          Color textColor = colorGrey1}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_italic",
          fontSize: textSize,
          color: textColor);

  static TextStyle montserratMediumItalic(
          {double textSize = TextSizes.sixteen,
          Color textColor = colorGrey1}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_medium_italic",
          fontSize: textSize,
          color: textColor);

  static TextStyle montserratBoldItalic(
          {double textSize = TextSizes.twenty, Color textColor = colorBlack}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_bold_italic",
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.bold);

  static TextStyle montserratSemiBoldItalic(
          {double textSize = TextSizes.twelve, Color textColor = colorBlack}) =>
      const TextStyle().copyWith(
          fontFamily: "montserrat_semi_bold_italic",
          fontSize: textSize,
          color: textColor,
          fontWeight: FontWeight.bold);
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

  static Widget maximumHorizontal() {
    return const SizedBox(
      width: 30,
    );
  }
}
