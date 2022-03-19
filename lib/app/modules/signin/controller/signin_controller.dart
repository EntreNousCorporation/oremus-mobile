import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
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

  late TextEditingController phoneController;
  late TextEditingController passwordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  GlobalKey<FormState> formSigninKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');

    if (flavor == AppConstants.ENV_DEV) {
      //loginController = TextEditingController(text: 'TOHERO');
      //passwordController = TextEditingController(text: 'ALO123');

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
      indicator: const LoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String login = phoneController.text.trim().toString().replaceAll(' ', '');
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
      Get.toNamed(Routes.INITIAL);
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse =
            ErrorResponse.fromJson(json.decode(error.toString()));
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
    String login = phoneController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();
    isValidForm.value = login.isNotEmpty && password.isNotEmpty;
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
