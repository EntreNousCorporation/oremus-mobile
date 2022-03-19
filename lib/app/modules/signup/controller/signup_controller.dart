import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signup/data/repository/signup_repository.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:overlay_support/overlay_support.dart';

class SignupController extends GetxController {
  final SignupRepository signupRepository;

  SignupController({required this.signupRepository});

  late TextEditingController phoneController;
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController passwordController;
  late TextEditingController confPasswordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  GlobalKey<FormState> formSignupKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController(text: '');
    firstnameController = TextEditingController(text: '');
    lastnameController = TextEditingController(text: '');
    passwordController = TextEditingController(text: '');
    confPasswordController = TextEditingController(text: '');

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

  signupUser() {
    hideKeyboard();
    EasyLoading.show(
      status: 'signup_processing'.tr,
      maskType: EasyLoadingMaskType.black,
      indicator: const LoadingView()
    ).then((v) {
      unlockBackButton.value = false;
    });

    String firstname = firstnameController.text.trim().toString().replaceAll(' ', '');
    String lastname = lastnameController.text.trim().toString();
    String phone = phoneController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();

    loading(true);
    lockScreen(true);
    Signin request = Signin(
      phone: phone,
      firstname: firstname,
      lastname: lastname,
      password: password,
    );

    log('request signupUser => ${request.toJson().toString()}');

    signupRepository.signupUser(request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      log('value => ${value.accessToken}');
      lockScreen(false);
      showSimpleNotification(const Center(child: Text('Inscription effectué avec succès')), background: colorGreen);
      Get.back();
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse = ErrorResponse.fromJson(json.decode(error.toString()));
        showSimpleNotification(Center(child: Text(errorResponse.debugMessage.toString())), background: Colors.red);
      } else {
        showSimpleNotification(const Center(child: Text("Une erreur est survenue")), background: Colors.red);
      }
    });
  }

  void checkForm() {
    String lastname = lastnameController.text.trim().toString();
    String firstname = firstnameController.text.trim().toString();
    String phone = phoneController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();
    String confPassword = confPasswordController.text.trim().toString();
    bool isSamePassword = password == confPassword;
    isValidForm.value = lastname.isNotEmpty && firstname.isNotEmpty && phone.isNotEmpty && password.isNotEmpty && confPassword.isNotEmpty && isSamePassword;
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    lastnameController.dispose();
    firstnameController.dispose();
    confPasswordController.dispose();
    super.dispose();
  }
}
