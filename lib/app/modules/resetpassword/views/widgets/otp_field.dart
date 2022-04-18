import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/otp_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpField extends StatelessWidget {
  OtpField({required this.controller, required this.otpLength, Key? key}) : super(key: key);

  OtpController controller;
  int otpLength;

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      pastedTextStyle: TextStyles.montserratBold(
          textSize: TextSizes.eighteen,
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
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      //errorAnimationController: errorController,
      controller: controller.otpController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(AppConstants.INPUT_NUM_REGEX)),
      ],
      textCapitalization: TextCapitalization.characters,
      boxShadows: null,
      onCompleted: (v) {
        log("Completed");
      },
      onChanged: (value) {
        log(value);
        controller.checkForm();
      },
      beforeTextPaste: (text) {
        log("Allowing to paste $text");
        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
        //but you can show anything you want here, like your pop up saying wrong paste format or etc
        return true;
      },
    );
  }
}
