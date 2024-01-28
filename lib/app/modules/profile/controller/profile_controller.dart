import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileController extends GetxController {
  final ProfileRepository profileRepository;
  final SigninRepository signinRepository;
  final ParoisseRepository paroisseRepository;

  ProfileController({
    required this.profileRepository,
    required this.signinRepository,
    required this.paroisseRepository,
  });

  var applyAnim = true.obs;
  final GlobalKey<AnimatorWidgetState> basicIconAnimation = GlobalKey<AnimatorWidgetState>();

  var lockScreen = false.obs;
  var unlockBackButton = true.obs;

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
  void onReady() {
    getProfile();
    super.onReady();
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

  updateUI(Profile? userInfo) {
    firstnameController = TextEditingController(text: userInfo?.firstname ?? 'N/A');
    lastnameController = TextEditingController(text: userInfo?.lastname ?? 'N/A');
    phoneController = TextEditingController(text: userInfo?.phone ?? 'N/A');
    emailController = TextEditingController(text: userInfo?.email ?? 'N/A');
  }

  getProfile() {
    if (refreshController.isRefresh == false) {
      isDataProcessing(true);
    }

    log('request getProfile');

    var userId = DB.getUserSigninInfo()?.id ?? '';
    profileRepository.getProfile(userId).then((value) {
      if (refreshController.isRefresh) {
        refreshController.refreshCompleted();
      }
      isDataProcessing(false);
      hasData(true);
      userInfo.value = value;
      updateUI(userInfo.value);
      profileRepository.saveUserProfile(value);
    }, onError: (error) {
      if (refreshController.isRefresh) {
        refreshController.refreshCompleted();
      }
      isDataProcessing(false);
      hasData(false);
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
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
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    DB.saveData(AppConstants.KEY_USER_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  goToEditProfile() async {
    await Get.toNamed(Routes.EDIT_PROFILE, arguments: jsonEncode(userInfo.value));
    if (profileRepository.getUserProfile() != null) {
      userInfo.value = profileRepository.getUserProfile()!;
      updateUI(userInfo.value);
    }
  }

  goToFavorites() {
    Get.toNamed(Routes.FAVORITES);
  }

  applyAnimation() {
    if (paroisseRepository.getAllFavorites().isNotEmpty) {
      basicIconAnimation.currentState?.animator?.loop();
      return AnimationPlayStates.Loop;
    }
    return AnimationPlayStates.None;
  }

  showDeleteAccountDialog() {
    showCustomDialog(
      Get.context!,
      type: '',
      message: 'Vous êtes sur le point de supprimer définitivement votre compte.\n\nNotez que cette action est irréversible.\n\nÊtes-vous sûr de vouloir continuer ?',
      negativeLabel: 'Annuler',
      positiveLabel: 'Oui, je consens',
      positiveBgColor: colorRed1,
      positiveCallBack: () {
        doDeleteAccount();
      }
    );
  }

  doDeleteAccount() {

    hideKeyboard();
    EasyLoading.show(
      status: 'Suppression du compte...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    log('request doDeleteAccount');

    lockScreen(true);

    var userId = DB.getUserSigninInfo()?.id ?? '';
    profileRepository.deleteAccount(userId).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      //redirection sur login
      showNotification(message: 'Le compte a été supprimé', duration: const Duration(seconds: 5));
      doLogout();

    }, onError: (error) {
      lockScreen(false);
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }
}
