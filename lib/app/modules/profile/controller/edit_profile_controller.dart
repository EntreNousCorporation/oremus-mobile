import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/email_validator.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/profile/views/edit_profile_screen.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EditProfileController extends GetxController {
  final ProfileRepository profileRepository;

  EditProfileController({
    required this.profileRepository,
  });

  var unlockBackButton = true.obs;

  var loading = false.obs;

  //For validation
  var lockScreen = false.obs;
  var isValidForm = false.obs;

  var userConnection = Signin().obs;
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
    getUserInfo();
    getArguments();
    super.onInit();
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
      status: 'Mise à jour en cours',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    String firstname = firstnameController.text.trim().toString().replaceAll(' ', '');
    String lastname = lastnameController.text.trim().toString().replaceAll(' ', '');
    String email = emailController.text.trim().toString().replaceAll(' ', '');
    String phone = phoneController.text.trim().toString().replaceAll(' ', '');

    loading(true);
    lockScreen(true);
    Signin request = Signin(
      phone: phone,
      firstname: firstname,
      lastname: lastname,
      email: email,
    );

    log('request signupUser => ${request.toJson().toString()}');

    profileRepository.updateProfile(userConnection.value.id ?? '', request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      lockScreen(false);
      encryptedBox.put(AppConstants.USER_INFOS, jsonEncode(value.toJson()));
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
      if (error.toString().isNotEmpty && error is Map) {
        var errorResponse = ErrorResponse.fromJson(json.decode(error.toString()));
        showNotification(
            message: errorResponse.debugMessage.toString(),
        );
      } else {
        showNotification(
            message: "Une erreur est survenue",
            bgColor: colorGreen4
        );
      }
    });
  }

  doLogout() {
    encryptedBox.put(AppConstants.USER_LOG_INFOS, null);
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
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      Signin userConnected = Signin.fromJson(jsonDecode(userInfo));
      userConnection.value = userConnected;
    }
  }
}
