import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/connexion/data/model/connection.dart';
import 'package:oremusapp/app/modules/connexion/data/repository/connexion_repository.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:overlay_support/overlay_support.dart';

class ConnexionController extends GetxController {
  final ConnexionRepository connexionRepository;

  ConnexionController({required this.connexionRepository});

  late TextEditingController phoneController;
  late TextEditingController passwordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;
  var submitText = 'Se connecter'.obs;

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
    String login = phoneController.text.trim().toString().replaceAll(' ', '');
    String password = passwordController.text.trim().toString();

    submitText.value = 'Connexion...';
    loading(true);
    lockScreen(true);
    Connection request = Connection(username: login, password: password);

    log('request connectUser => ${request.toJson().toString()}');

    connexionRepository.loginUser(request).then((value) {
      log('value => ${value.accessToken}');
      lockScreen(false);
      Get.toNamed(Routes.INITIAL);
    }, onError: (error) {
      lockScreen(false);
      submitText.value = 'Se connecter';
      debugPrint("error => ${error.toString()}");
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse = ErrorResponse.fromJson(json.decode(error.toString()));
        showSimpleNotification(Text(errorResponse.debugMessage.toString()), background: Colors.red);
      } else {
        showSimpleNotification(const Text("Login et/ou mot de passe incorrect"), background: Colors.red);
      }
    });
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
