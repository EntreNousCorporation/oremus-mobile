import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signup/data/repository/signup_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class SignupController extends GetxController {
  final SignupRepository signupRepository;

  SignupController({required this.signupRepository});

  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController confPasswordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var firstnameErrorMessage = ''.obs;
  var lastnameErrorMessage = ''.obs;
  var emailErrorMessage = ''.obs;
  var phoneErrorMessage = ''.obs;
  var passwordErrorMessage = ''.obs;
  var confPasswordErrorMessage = ''.obs;

  GlobalKey<FormState> formSignupKey = GlobalKey<FormState>();
  FocusNode firstnameFocusNode = FocusNode();
  FocusNode lastnameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confPasswordFocusNode = FocusNode();

  @override
  void onInit() {
    initControllers();
    super.onInit();
  }

  initControllers() {
    phoneController = TextEditingController(text: '');
    firstnameController = TextEditingController(text: '');
    lastnameController = TextEditingController(text: '');
    emailController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');
    confPasswordController = TextEditingController(text: '');
  }

  signupUser() {
    hideKeyboard();
    EasyLoading.show(
      status: 'signup_processing'.tr,
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String firstname =
        firstnameController.text.trim().toString().replaceAll(' ', '');
    String lastname =
        lastnameController.text.trim().toString().replaceAll(' ', '');
    String email = emailController.text.trim().toString().replaceAll(' ', '');
    String phone = phoneController.text.trim().toString().replaceAll(' ', '');
    String password =
        passwordController.text.trim().toString().replaceAll(' ', '');

    loading(true);
    lockScreen(true);
    Signin request = Signin(
      phone: phone,
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
    );

    log('request signupUser => ${request.toJson().toString()}');

    signupRepository.signupUser(request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      log('value => ${value.accessToken}');
      lockScreen(false);
      showNotification(
        message: "Inscription effectué avec succès",
        bgColor: colorGreen,
      );
      Get.back();
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");

      var err = error as CustomException;
      debugPrint("error => ${err.toString()}");
      if (err.code == 409) {
        showNotification(
          message: "Ce compte existe déjà. Si vous avez oublié votre mot de passe, vous pouvez le réinitialiser",
        );
      } else {
        showNotification(
          message: "Une erreur est survenue",
        );
      }

      /*if (error.toString().isNotEmpty && error is Map) {
        var errorResponse =
            ErrorResponse.fromJson(json.decode(error.toString()));
        showNotification(
          message: errorResponse.debugMessage.toString(),
        );
      } else {

        showNotification(
          message: "Une erreur est survenue",
        );
      }*/

    });
  }

  void checkForm() {
    String lastname = lastnameController.text.trim().toString();
    String firstname = firstnameController.text.trim().toString();
    String email = emailController.text.trim().toString();
    String phone = phoneController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();
    String confPassword = confPasswordController.text.trim().toString();
    bool isValidEmail = EmailValidator.validate(email) == true;

    if (lastnameFocusNode.hasFocus) {
      if (lastname.isEmpty) {
        lastnameErrorMessage.value = 'Le nom est obligatoire';
      } else {
        lastnameErrorMessage.value = '';
      }
    }

    if (firstnameFocusNode.hasFocus) {
      if (firstname.isEmpty) {
        firstnameErrorMessage.value = 'Le prénom est obligatoire';
      } else {
        firstnameErrorMessage.value = '';
      }
    }

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

    if (phoneFocusNode.hasFocus) {
      if (phone.isEmpty) {
        phoneErrorMessage.value = 'Le téléphone est obligatoire';
      } else {
        phoneErrorMessage.value = '';
      }
    }

    if (passwordFocusNode.hasFocus) {
      if (password.isEmpty) {
        passwordErrorMessage.value = 'Le mot de passe est obligatoire';
      } else {
        passwordErrorMessage.value = '';
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

    bool isSamePassword = password == confPassword;

    if (isSamePassword == false) {
      confPasswordErrorMessage.value = 'Les mots de passe sont différents';
    } else {
      confPasswordErrorMessage.value = '';
    }
    isValidForm.value = lastname.isNotEmpty &&
        firstname.isNotEmpty &&
        email.isNotEmpty &&
        isValidEmail &&
        phone.isNotEmpty &&
        password.isNotEmpty &&
        confPassword.isNotEmpty &&
        isSamePassword;
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    firstnameController.dispose();
    confPasswordController.dispose();
    super.dispose();
  }
}
