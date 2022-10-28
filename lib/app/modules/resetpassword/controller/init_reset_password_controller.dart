import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/reset_password_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class InitResetPasswordController extends GetxController {
  final ResetPasswordRepository resetPasswordRepository;

  InitResetPasswordController({required this.resetPasswordRepository});

  late TextEditingController emailController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var emailErrorMessage = ''.obs;

  GlobalKey<FormState> formSigninKey = GlobalKey<FormState>();
  FocusNode emailFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController(text: '');
  }

  doInitResetPassword() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String username = emailController.text.trim().toString().replaceAll(' ', '');

    loading(true);
    lockScreen(true);

    resetPasswordRepository.initResetPassword(username).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      goToCheckOtp();
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      var err = error as CustomException;
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse = ErrorResponse.fromJson(json.decode(error.toString()));
        showNotification(
            message: errorResponse.debugMessage.toString(),
        );
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      } else {
        showNotification(
            message: "L'e-mail est incorrect",
        );
      }
    });
  }

  goToCheckOtp() {
    Get.toNamed(Routes.CHECK_OTP, arguments: emailController.text.trim().toString().replaceAll(' ', ''));
  }

  void checkForm() {
    String email = emailController.text.trim().toString().replaceAll(' ', '');
    bool isValidEmail = EmailValidator.validate(email) == true;

    if (emailFocusNode.hasFocus) {
      if (email.isEmpty) {
        emailErrorMessage.value = "L'email est obligatoire";
      } else {
        if (isValidEmail == false) {
          emailErrorMessage.value = "L'email est incorrect";
        } else {
          emailErrorMessage.value = '';
        }
      }
    }
    isValidForm.value = email.isNotEmpty && isValidEmail;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
