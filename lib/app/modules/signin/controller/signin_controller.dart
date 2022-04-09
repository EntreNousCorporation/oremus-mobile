import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/storage_request.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:overlay_support/overlay_support.dart';

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

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');

    if (flavor == AppConstants.ENV_DEV) {
      emailController = TextEditingController(text: 'test@gmail.com');
      passwordController = TextEditingController(text: 'test');

      //loginController = TextEditingController(text: 'SUVAWY');
      //passwordController = TextEditingController(text: 'A22222');

      //loginController = TextEditingController(text: "0103244851");
      //passwordController = TextEditingController(text: "DOSSO21");

      //loginController = TextEditingController(text: "W39JZM");
      //passwordController = TextEditingController(text: "56C2");

    } else {
      //loginController = TextEditingController(text: "0749435261");
      //passwordController = TextEditingController(text: "DE2021");

      //loginController = TextEditingController(text: "W39JZM");
      //passwordController = TextEditingController(text: "56C2");
    }
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
      StorageRequest.saveData(AppConstants.KEY_TOKEN, value.accessToken);
      Map<String, dynamic> payload = Jwt.parseJwt(value.accessToken ?? '');
      var userConnection = Signin(
        username: payload['username'],
        id: payload['sub']
      );
      encryptedBox.put(AppConstants.USER_LOG_INFOS, jsonEncode(userConnection.toJson()));
      Get.toNamed(Routes.CUSTOM_HOME);
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse = ErrorResponse.fromJson(json.decode(error.toString()));
        showSimpleNotification(
          Center(child: Text(errorResponse.debugMessage.toString())),
          background: Colors.red,
        );
      } else {
        showSimpleNotification(
          const Center(child: Text("Login et/ou mot de passe incorrect")),
          background: Colors.red,
        );
      }
    });
  }

  goToSignup() {
    Get.toNamed(Routes.SIGNUP);
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
