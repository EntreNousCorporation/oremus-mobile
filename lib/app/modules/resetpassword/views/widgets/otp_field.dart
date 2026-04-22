import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/otp_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpField extends StatelessWidget {
  const OtpField({
    required this.controller,
    required this.otpLength,
    Key? key,
  }) : super(key: key);

  final OtpController controller;
  final int otpLength;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(
      builder: (logic) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: PinCodeTextField(
                appContext: context,
                pastedTextStyle: TextStyles.montserratBold(
                  textSize: TextSizes.twenty,
                  textColor: colorGreen,
                ),
                length: otpLength,
                obscureText: false,
                obscuringCharacter: '*',
                obscuringWidget: null,
                blinkWhenObscuring: true,
                animationType: AnimationType.fade,
                validator: null,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 55,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  inactiveFillColor: colorGrey5,
                  selectedFillColor: colorGreen.withOpacity(0.05),
                  inactiveColor: Colors.grey[300]!,
                  activeColor: colorGreen,
                  selectedColor: colorGreen,
                  borderWidth: 1.5,
                ),
                cursorColor: colorGreen,
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(AppConstants.INPUT_NUM_REGEX)),
                ],
                textCapitalization: TextCapitalization.characters,
                boxShadows: [
                  BoxShadow(
                    color: colorGreen.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 5,
                  )
                ],
                onCompleted: (v) {
                  log("Completed");
                  // Ajout d'un léger feedback haptique lorsque le code est complet
                  HapticFeedback.lightImpact();
                },
                onChanged: (value) {
                  log(value);
                  controller.checkForm();
                },
                beforeTextPaste: (text) {
                  log("Allowing to paste $text");
                  return true;
                },
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                textStyle: TextStyles.montserratBold(
                  textSize: TextSizes.twenty,
                  textColor: colorGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Indicateur de progression
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                otpLength,
                    (index) =>
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      width: 24,
                      decoration: BoxDecoration(
                        color: controller.otpController.text.length > index
                            ? colorGreen
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            // Texte d'aide
            Text(
              "Entrez le code à $otpLength chiffres",
              style: TextStyles.montserratRegular(
                textSize: TextSizes.thirteen,
                textColor: Colors.grey[600]!,
              ),
            ),
          ],
        );
      },
    );
  }
}