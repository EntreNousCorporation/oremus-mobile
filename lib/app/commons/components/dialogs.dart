import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:overlay_support/overlay_support.dart';

Future showCustomDialog(BuildContext context,
    {String title = 'INFORMATION',
    required String message,
    String positiveLabel = 'OK',
    String negativeLabel = '',
    Function? positiveCallBack,
    Function? negativeCallBack,
    bool dismissible = false,
    bool? result,
    String? type = 'info'}) async {
  return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white70, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.info,
                  color: type == 'info' ? colorGreenSemiLight : colorRed1,
                  size: 35.0,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    type == 'info' ? title : 'ALERTE',
                    style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.sixteen, textColor: colorBlack),
                  ),
                )
              ],
            ),
            content: Text(
              message,
              style: TextStyles.montserratSemiBold(
                textSize: TextSizes.fourteen,
                textColor: colorBlack,
              ),
            ),
            actions: <Widget>[
              Visibility(
                visible: negativeLabel != '',
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    if (negativeCallBack != null) negativeCallBack();
                  },
                  child: Text(
                    negativeLabel,
                    style: TextStyles.montserratSemiBold(
                      textSize: TextSizes.fourteen,
                      textColor: colorBlack,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  if (positiveCallBack != null) positiveCallBack();
                },
                style: TextButton.styleFrom(
                  backgroundColor: colorGreenSemiLight,
                ),
                child: Text(
                  positiveLabel,
                  style: TextStyles.montserratSemiBold(
                      textSize: TextSizes.fourteen, textColor: colorWhite),
                ),
              ),
            ],
          ),
        );
      });
}

Future showLoadingDialog(BuildContext context,
    {String message = 'Veuillez patienter...',
    bool dismissible = false}) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    child: const CircularProgressIndicator(),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    message,
                    style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                ],
              )
            ],
          ),
        );
      });
}

showExitDialog(BuildContext context,
    {String title = 'INFORMATION',
    required String message,
    String positiveText = 'OUI',
    bool? result}) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white70, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              title,
              style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.fourteen, textColor: colorBlack),
            ),
            content: Text(
              message,
              style: TextStyles.montserratRegular(
                  textSize: TextSizes.eighteen, textColor: colorBlack),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  positiveText,
                  style: TextStyles.montserratSemiBold(
                      textSize: TextSizes.sixteen, textColor: colorGreen),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'NON',
                  style: TextStyles.montserratBold(
                      textSize: TextSizes.sixteen, textColor: colorBlack),
                ),
              ),
            ],
          ),
        );
      });
}

showNormalDialog(BuildContext context,
    {String title = 'INFORMATION',
    required String message,
    bool? result}) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            title,
            style: TextStyles.montserratSemiBold(
                textSize: TextSizes.fourteen, textColor: colorGreen),
          ),
          content: Text(
            message,
            style: TextStyles.montserratRegular(
                textSize: TextSizes.eighteen, textColor: colorGreen),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'OK',
                style: TextStyles.montserratBold(
                    textSize: TextSizes.sixteen, textColor: colorBlack),
              ),
            ),
          ],
        );
      });
}

showNotification({
  required String message,
  Color? bgColor = colorRed,
  Widget? leading,
  Widget? trailing,
  Duration? duration = const Duration(seconds: 3),
  NotificationPosition position = NotificationPosition.top,
}) {
  return showSimpleNotification(
      Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyles.montserratSemiBold(
            textSize: TextSizes.fourteen,
            textColor: colorWhite,
          ),
        ),
      ),
      elevation: 0,
      duration: duration,
      leading: leading,
      trailing: trailing,
      background: bgColor,
      position: position);
}
