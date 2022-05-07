import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/reset_password_repository.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class OtpController extends GetxController {
  final ResetPasswordRepository resetPasswordRepository;

  OtpController({required this.resetPasswordRepository});

  late TextEditingController otpController;

  var unlockBackButton = true.obs;

  var loading = false.obs;
  var otpLength = 4.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var usernameEntered = ''.obs;

  GlobalKey<FormState> formSigninKey = GlobalKey<FormState>();
  FocusNode otpFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    getArguments();
    otpController = TextEditingController(text: '');
  }

  getArguments() {
    if (Get.arguments != null) {
      usernameEntered.value = Get.arguments;
    }
  }

  doCheckOtp() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Vérification en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String otp = otpController.text.trim().toString().replaceAll(' ', '');

    loading(true);
    lockScreen(true);

    resetPasswordRepository.checkOtp(usernameEntered.value, otp).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      if (value.status?.toLowerCase() == 'valid') {
        goToResetPassword();
      } else {
        showNotification(
            message: "Code OTP incorrect",
        );
      }
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse =
            ErrorResponse.fromJson(json.decode(error.toString()));
        showNotification(
            message: errorResponse.debugMessage.toString(),
        );
      } else {
        showNotification(
          message: "Une erreur interne est survenue",
        );
      }
    });
  }

  goToResetPassword() {
    Get.toNamed(
      Routes.RESET_PASSWORD,
      arguments: [
        usernameEntered.value,
        otpController.text,
      ],
    );
  }

  void checkForm() {
    String otp = otpController.text.trim();
    isValidForm.value = otp.isNotEmpty && (otp.length == otpLength.value);
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
