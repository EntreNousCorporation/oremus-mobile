import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class EditProfileController extends GetxController {
  final ProfileRepository profileRepository;
  final SigninRepository signinRepository;

  EditProfileController({
    required this.profileRepository,
    required this.signinRepository,
  });

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var userInfo = Profile().obs;

  var refreshController = RefreshController();

  var firstnameErrorMessage = ''.obs;
  var lastnameErrorMessage = ''.obs;
  var emailErrorMessage = ''.obs;
  var phoneErrorMessage = ''.obs;

  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  FocusNode firstnameFocusNode = FocusNode();
  FocusNode lastnameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  @override
  void dispose() {
    refreshController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      userInfo.value = Profile.fromJson(jsonDecode(Get.arguments));
      updateUI(userInfo.value);
    }
  }

  updateUI(Profile userInfo) {
    firstnameController = TextEditingController(text: userInfo.firstname);
    lastnameController = TextEditingController(text: userInfo.lastname);
    phoneController = TextEditingController(text: userInfo.phone);
    emailController = TextEditingController(text: userInfo.email);
    checkForm();
  }

  updateProfile() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Mise à jour en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String email = emailController.text.trim().toString().replaceAll(RegExp(r'\s'), '');
    String phone = phoneController.text.trim().toString().replaceAll(RegExp(r'\s'), '');

    loading(true);
    lockScreen(true);
    Signin request = Signin(
      phone: phone,
      firstname: firstname,
      lastname: lastname,
      email: email,
    );

    var userId = DB.getUserSigninInfo()?.id ?? '';
    profileRepository.updateProfile(userId, request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      profileRepository.saveUserProfile(value);
      showNotification(
          message: 'Profil modifié avec succès',
          bgColor: colorGreen4
      );
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
      } else if (err.code == 900 || err.code == 409) {
        showNotification(message: err.message.toString());
      } else {
        showNotification(message: "Une erreur inconnue est survenue");
      }
    });
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  void checkForm() {
    String lastname = lastnameController.text.trim().toString();
    String firstname = firstnameController.text.trim().toString();
    String email = emailController.text.trim().toString();
    String phone = phoneController.text.trim().toString().replaceAll(' ', '');
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

    isValidForm.value = lastname.isNotEmpty && firstname.isNotEmpty && email.isNotEmpty && isValidEmail && phone.isNotEmpty;
    update();
  }
}
