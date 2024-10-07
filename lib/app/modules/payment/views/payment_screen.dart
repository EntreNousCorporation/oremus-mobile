import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorWhite,
        body: GetX<PaymentController>(builder: (logic) {
          return Column(
            children: [
              Separators.maximumVertical(),
              GetPlatform.isAndroid
                  ? Separators.normalVertical()
                  : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        logic.doBack();
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: colorBlack),
                    ),
                    Text(
                      'Paiement',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratBold(
                        textSize: TextSizes.eighteen,
                        textColor: colorBlack,
                      ),
                    ),
                  ],
                ),
              ),
              Separators.minimunVertical(),
              Expanded(
                child: WebViewWidget(
                    controller: logic.webViewController.value),
              ),
            ],
          );
        }),
      ),
    );
  }
}
