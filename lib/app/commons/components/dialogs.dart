import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

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
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(30),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info,
                color: type == 'info' ? Colors.green : Colors.red,
                size: 35.0,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  type == 'info' ? title : 'ALERTE',
                  style: const TextStyle(fontFamily: 'avenir_demi_bold'),
                ),
              )
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'avenir_demi_bold'),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  if (positiveCallBack != null) positiveCallBack();
                },
                child: Text(
                  positiveLabel.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                )),
            Visibility(
              visible: negativeLabel != '',
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    if (negativeCallBack != null) negativeCallBack();
                  },
                  child: Text(
                    negativeLabel,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  )),
            ),
          ],
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
    required String message, String positiveText = 'OUI',
    bool? result}) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'avenir_demi_bold'),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'avenir_regular', fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                positiveText,
                style: const TextStyle(
                  color: colorGreen,
                  fontSize: 16,
                  fontFamily: 'avenir_bold',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'NON',
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 16,
                  fontFamily: 'avenir_bold',
                ),
              ),
            ),
          ],
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
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'avenir_demi_bold'),
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'avenir_regular', fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: colorBlack,
                  fontSize: 16,
                  fontFamily: 'avenir_bold',
                ),
              ),
            ),
          ],
        );
      });
}
