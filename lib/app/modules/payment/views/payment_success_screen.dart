import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:lottie/lottie.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_status_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: GetX<PaymentStatusController>(builder: (logic) {
        return Scaffold(
          backgroundColor: colorWhite,
          resizeToAvoidBottomInset: false,
          body: WillPopScope(
            onWillPop: () async => false,
            child: FadeIn(
              child: Column(
                children: <Widget>[
                  Separators.customSizeVertical(100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          Assets.assetsImagesCheck,
                          repeat: true,
                          fit: BoxFit.fill,
                        ),
                        Text(
                          logic.paymentStatusMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.twenty,
                            textColor: colorBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  SizedBox(
                    width: Get.width / 1.5,
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      elevation: 10,
                      color: colorWhite,
                      shadowColor: colorGrey2.withOpacity(0.5),
                      child: CustomButton(
                        text: 'Terminer',
                        borderRadius: 10,
                        textSize: TextSizes.sixteen,
                        bgcolor: colorGreen,
                        borderColor: colorGreen,
                        actionColor: colorGreen.withOpacity(0.5),
                        action: () {
                          logic.moveToMassRequestHistory();
                        },
                      ),
                    ),
                  ),
                  Separators.normalVertical(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
