import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class SigninController extends GetxController {
  final SigninRepository signinRepository;

  SigninController({required this.signinRepository});

  late TextEditingController emailController;
  late TextEditingController passwordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var emailErrorMessage = ''.obs;
  var passwordErrorMessage = ''.obs;

  GlobalKey<FormState> formSigninKey = GlobalKey<FormState>();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  var tempLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    getArgument();
    emailController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');

    if (flavor == AppConstants.ENV_DEV) {
      emailController = TextEditingController(text: 'amourssou11@gmail.com');
      passwordController = TextEditingController(text: 'test');
      //checkForm();
    } else {}
  }

  getArgument() {
    if (Get.arguments != null) {
      tempLogin.value = Get.arguments;
    }
    update();
  }

  connectUser() {
    hideKeyboard();
    EasyLoading.show(
      status: 'connection_processing'.tr,
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String login = emailController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();

    loading(true);
    lockScreen(true);
    Signin request = Signin(username: login, password: password);

    log('request connectUser => ${request.toJson().toString()}');

    signinRepository.loginUser(request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      log('value => ${value.accessToken}');
      lockScreen(false);
      DB.saveData(AppConstants.KEY_TOKEN, value.accessToken);
      Map<String, dynamic> payload = Jwt.parseJwt(value.accessToken ?? '');
      var userConnection = Signin(
        username: payload['username'],
        id: payload['sub'],
        isBoUser: value.isBoUser,
      );
      isUserConnected.value = true;
      DB.saveUserSigninInfo(userConnection);
      if (tempLogin.value == true) {
        Get.find<CustomHomeController>().onInit();
        //goToHome();
        Get.back(result: true);
        return;
      }
      goToHome();
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      var err = error as CustomException;
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse =
            ErrorResponse.fromJson(json.decode(error.toString()));
        showNotification(message: errorResponse.debugMessage.toString());
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      } else {
        showNotification(message: "Login et/ou mot de passe incorrect");
      }
    });
  }

  goToHome() {
    Get.offNamed(Routes.CUSTOM_HOME);
  }

  goToSignup() {
    Get.toNamed(Routes.SIGNUP);
  }

  goToForgotPassword() {
    Get.toNamed(Routes.INIT_RESET_PASSWORD);
  }

  void checkForm() {
    String email = emailController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();
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

    if (passwordFocusNode.hasFocus) {
      if (password.isEmpty) {
        passwordErrorMessage.value = 'Le mot de passe est obligatoire';
      } else {
        passwordErrorMessage.value = '';
      }
    }

    isValidForm.value = email.isNotEmpty && isValidEmail && password.isNotEmpty;
    log('email => $email');
    log('isValidEmail => $isValidEmail');
    log('isValidForm => ${isValidForm.value}');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
