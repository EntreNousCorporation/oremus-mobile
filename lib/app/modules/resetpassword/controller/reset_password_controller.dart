import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/storage_request.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/reset_password_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:overlay_support/overlay_support.dart';

class ResetPasswordController extends GetxController {
  final ResetPasswordRepository resetPasswordRepository;

  ResetPasswordController({required this.resetPasswordRepository});

  late TextEditingController newPasswordController;
  late TextEditingController confPasswordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var otpEntered = ''.obs;
  var usernameEntered = ''.obs;

  var newPasswordErrorMessage = ''.obs;
  var confPasswordErrorMessage = ''.obs;

  GlobalKey<FormState> formSigninKey = GlobalKey<FormState>();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confPasswordFocusNode = FocusNode();

  @override
  void onInit() {
    getArguments();
    initControllers();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      usernameEntered.value = Get.arguments[0];
      otpEntered.value = Get.arguments[1];
    }
  }

  initControllers() {
    newPasswordController = TextEditingController(text: '');
    confPasswordController = TextEditingController(text: '');
  }

  doResetPassword() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Réinitialisation en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String newPassword = newPasswordController.text.trim().toString().replaceAll(' ', '');
    String username = usernameEntered.value;
    String otp = otpEntered.value;

    Signin request = Signin(
      username: username,
      password: newPassword,
      otp: otp,
    );

    log('request doResetPassword => ${request.toJson().toString()}');
    loading(true);
    lockScreen(true);

    resetPasswordRepository.resetPassword(request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      showNotification(
        message: "Votre mot de passe a été réinitialisé avec succès",
        bgColor: colorGreen
      );
      Get.toNamed(Routes.SIGNIN);
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse = ErrorResponse.fromJson(json.decode(error.toString()));
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

  goToCheckOtp() {
    Get.toNamed(Routes.CHECK_OTP);
  }

  void checkForm() {
    String newPassword = newPasswordController.text.trim().toString();
    String confPassword = confPasswordController.text.trim().toString();

    if (newPasswordFocusNode.hasFocus) {
      if (newPassword.isEmpty) {
        newPasswordErrorMessage.value =
        "Le nouveau mot de passe est obligatoire";
      } else {
        newPasswordErrorMessage.value = '';
      }
    }

    if (confPasswordFocusNode.hasFocus) {
      if (confPassword.isEmpty) {
        confPasswordErrorMessage.value =
        'La confirmation du mot de passe est obligatoire';
      } else {
        confPasswordErrorMessage.value = '';
      }
    }

    bool isSamePassword = newPassword == confPassword;

    if (isSamePassword == false) {
      confPasswordErrorMessage.value = 'Les mots de passe sont différents';
    } else {
      confPasswordErrorMessage.value = '';
    }

    isValidForm.value = newPassword.isNotEmpty && confPassword.isNotEmpty && isSamePassword;
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confPasswordController.dispose();
    super.dispose();
  }
}
