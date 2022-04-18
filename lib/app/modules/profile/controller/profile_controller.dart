import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository;

  ProfileController({
    required this.profileRepository,
  });

  var userConnection = Signin().obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var userInfo = Profile().obs;
  var isActive = true.obs;

  var refreshController = RefreshController();

  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void onInit() {
    getUserInfo();
    super.onInit();
  }

  @override
  void onReady() {
    getProfile();
    super.onReady();
  }

  updateUI(Profile userInfo) {
    firstnameController = TextEditingController(text: userInfo.firstname);
    lastnameController = TextEditingController(text: userInfo.lastname);
    phoneController = TextEditingController(text: userInfo.phone);
    emailController = TextEditingController(text: userInfo.email);
  }

  getProfile() {
    isDataProcessing(true);

    log('request getProfile');

    profileRepository.getProfile(userConnection.value.id ?? '').then((value) {
      if (refreshController.isRefresh) {
        refreshController.refreshCompleted();
      }
      isDataProcessing(false);
      hasData(true);
      userInfo.value = value;
      encryptedBox.put(AppConstants.USER_INFOS, jsonEncode(userInfo.value.toJson()));
      updateUI(userInfo.value);
    }, onError: (error) {
      if (refreshController.isRefresh) {
        refreshController.refreshCompleted();
      }
      isDataProcessing(false);
      hasData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  updateBiometriqueUI() {
    isActive.toggle();
  }

  showMessageBiometrique(bool state) {
    if (state) {
      showNotification(
          message: 'Authentification biométrique activée',
          bgColor: colorGreenSemiLight
      );
    } else {
      showNotification(
          message: 'Authentification biométrique désactivée',
      );
    }
  }

  goToEditPassword() {
    Get.toNamed(Routes.EDIT_PASSWORD);
  }

  doLogout() {
    encryptedBox.put(AppConstants.USER_LOG_INFOS, null);
    encryptedBox.put(AppConstants.USER_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      Signin userConnected = Signin.fromJson(jsonDecode(userInfo));
      userConnection.value = userConnected;
    }
  }

  //EDIT PROFIL SECTION
  goToEditProfile() async {
    await Get.toNamed(Routes.EDIT_PROFILE, arguments: jsonEncode(userInfo.value));
    var userInfos = encryptedBox.get(AppConstants.USER_INFOS);
    if (userInfos != null) {
      userInfo.value = Profile.fromJson(jsonDecode(userInfos));
      updateUI(userInfo.value);
    }
  }
}
