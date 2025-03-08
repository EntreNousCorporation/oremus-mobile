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

class PaymentErrorScreen extends StatelessWidget {
  const PaymentErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: GetX<PaymentStatusController>(builder: (logic) {
        return Scaffold(
          backgroundColor: colorWhite,
          resizeToAvoidBottomInset: false,
          body: PopScope(
            canPop: false,
            child: FadeIn(
              child: Column(
                children: <Widget>[
                  Separators.customSizeVertical(200),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          Assets.imagesError,
                          repeat: true,
                          fit: BoxFit.fill,
                          height: 200,
                          width: 200,
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
                      shadowColor: colorGrey2.withValues(alpha: 0.5),
                      child: CustomButton(
                        text: 'Terminer',
                        borderRadius: 10,
                        textSize: TextSizes.sixteen,
                        bgcolor: colorGreen,
                        borderColor: colorGreen,
                        actionColor: colorGreen.withValues(alpha: 0.5),
                        action: () {
                          logic.doRedirection();
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
