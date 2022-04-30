import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class EditPasswordController extends GetxController {
  final ProfileRepository profileRepository;
  final SigninRepository signinRepository;

  EditPasswordController({
    required this.profileRepository,
    required this.signinRepository,
  });

  var userConnection = Signin().obs;

  late TextEditingController passwordController;
  late TextEditingController newPasswordController;
  late TextEditingController confPasswordController;

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var passwordErrorMessage = ''.obs;
  var newPasswordErrorMessage = ''.obs;
  var confPasswordErrorMessage = ''.obs;

  GlobalKey<FormState> formSigninKey = GlobalKey<FormState>();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();
  FocusNode confPasswordFocusNode = FocusNode();

  @override
  void onInit() {
    initControllers();
    super.onInit();
  }

  initControllers() {
    passwordController = TextEditingController(text: '');
    newPasswordController = TextEditingController(text: '');
    confPasswordController = TextEditingController(text: '');
  }

  updatePassword() {
    hideKeyboard();
    EasyLoading.show(
      status: 'connection_processing'.tr,
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String oldPassword = passwordController.text.trim().toString();
    String newPassword = newPasswordController.text.trim().toString();

    loading(true);
    lockScreen(true);
    Signin request = Signin(
        username: signinRepository.getUserSigninInfo()?.username,
        oldPassword: oldPassword,
        newPassword: newPassword);

    log('request updatePassword => ${request.toJson().toString()}');

    profileRepository.updatePassword(request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      initControllers();
      showNotification(
          message: "Mot de passe changé avec succès",
          bgColor: colorGreen4
      );
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      debugPrint("error => ${error.toString()}");
      if (error.toString().contains('401')) {
        showNotification(
            message: "Le mot de passe est incorrect",
        );
        return;
      }
      if (error.toString().contains('400')) {
        showNotification(
            message: "L'ancien et le nouveau mot de passe ne doivent pas être identiques",
        );
        return;
      }
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse =
            ErrorResponse.fromJson(json.decode(error.toString()));
        showNotification(
            message: errorResponse.debugMessage.toString(),
        );
      } else {
        //messge générique

      }
    });
  }

  doLogout() {
    DB.saveData(AppConstants.USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  void checkForm() {
    String password = passwordController.text.trim().toString();
    String newPassword = newPasswordController.text.trim().toString();
    String confPassword = confPasswordController.text.trim().toString();

    if (passwordFocusNode.hasFocus) {
      if (password.isEmpty) {
        passwordErrorMessage.value = "L'ancien mot de passe est obligatoire";
      } else {
        passwordErrorMessage.value = '';
      }
    }

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

    isValidForm.value = password.isNotEmpty &&
        newPassword.isNotEmpty &&
        confPassword.isNotEmpty &&
        isSamePassword;
  }
}
