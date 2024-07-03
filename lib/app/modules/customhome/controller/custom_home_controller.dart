import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class CustomHomeController extends GetxController {
  SigninRepository signinRepository;
  final ParoisseRepository paroisseRepository;

  CustomHomeController({
    required this.signinRepository,
    required this.paroisseRepository,
  });

  RxList<MenusItem> menus = RxList<MenusItem>([]);
  late SimpleHiddenDrawerController drawerController;
  var selectedIndex = AppConstants.HOME.obs; //home
  var title = ''.obs;

  var applyAnim = true.obs;
  final GlobalKey<AnimatorWidgetState> basicIconAnimation =
      GlobalKey<AnimatorWidgetState>();

  @override
  void onInit() {
    if (flavor == AppConstants.ENV_PROD && GetPlatform.isAndroid) {
      doPerformAppUpdate();
    }
    initMenus();
    update();
    super.onInit();
  }

  initMenus() {
    menus.value = [
      MenusItem(
        code: AppConstants.HOME,
        libelle: 'Accueil',
        icon: 'assets/images/icon_nav_home.svg',
      ),
      MenusItem(
        code: AppConstants.PROFILE,
        libelle: 'Mon profil',
        icon: 'assets/images/icon_user.svg',
        isVisible: isUserConnected.value == true ? true : false,
      ),
      MenusItem(
        code: AppConstants.PRAY,
        libelle: "Mini Missel",
        icon: 'assets/images/icon_pray.svg',
      ),
      MenusItem(
        code: AppConstants.PROMO,
        libelle: 'Codes promo',
        icon: 'assets/images/icon_settings.svg',
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.FAQ,
        libelle: 'F.A.Q',
        icon: 'assets/images/faq_icon.svg',
      ),
      MenusItem(
        code: AppConstants.CONTACTS,
        libelle: 'Contacts',
        icon: 'assets/images/icon_phone.svg',
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.ABOUT,
        libelle: 'A propos',
        icon: 'assets/images/icon_settings.svg',
      ),
      MenusItem(
        code: AppConstants.SIGNIN,
        libelle: 'Connexion',
        icon: 'assets/images/user_login.svg',
        isVisible: isUserConnected.value == true ? false : true,
      ),
      MenusItem(
        code: AppConstants.SHARE_APP,
        libelle: "Partager l'application",
        icon: 'assets/images/share_icon.svg',
        isVisible: true,
      ),
    ];
    menus.value = menus.where((element) => element.isVisible).toList();
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

  bool userCanUpdateProfile() {
    return DB.getUserSigninInfo()?.isBoUser == false;
  }

  doRedirection(int index, SimpleHiddenDrawerController controller) {
    log('index selected => $index');
    selectedIndex.value = index;
    var menuCode = menus[index].code;
    if (menuCode == AppConstants.SIGNIN) {
      goToSignin();
    } else {
      if (menuCode == AppConstants.SHARE_APP) {
        doShareApp();
      } else {
        controller.setSelectedMenuPosition(index);
      }
      update();
    }
  }

  doShareApp() {
    shareApp(
      AppConstants.APP_SHARE_MSG.replaceAll('{link}', shareAppLink),
      includeFile: GetPlatform.isAndroid ? true : false,
      filePath: Assets.imagesLogo,
    );
  }

  goToSignin() {
    Get.offAllNamed(Routes.SIGNIN);
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    isUserConnected.value = false;
    Get.offAllNamed(Routes.SIGNIN);
  }

  Future<void> performAppUpdate() async {
    log('==== perform Oremus Update ====');
    try {
      InAppUpdate.checkForUpdate().then((updateInfo) {
        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateUpdateAllowed) {
            // Perform immediate update
            showCustomDialog(Get.context!,
                message: 'label_update_app_available'.tr,
                positiveLabel: 'label_update'.tr, positiveCallBack: () {
              InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
                if (appUpdateResult == AppUpdateResult.success) {
                  //App Update successful
                  showNotification(
                    message: 'label_update_app_successfully'.tr,
                    bgColor: colorGreenSemiLight,
                  );
                }
              });
            });
          } else if (updateInfo.flexibleUpdateAllowed) {
            //Perform flexible update
            InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
              if (appUpdateResult == AppUpdateResult.success) {
                //App Update successful
                InAppUpdate.completeFlexibleUpdate();
                showNotification(
                  message: 'label_update_app_successfully'.tr,
                  bgColor: colorGreenSemiLight,
                );
              }
            });
          }
        }
      }, onError: (error) {
        log('checkForUpdate Error performAppUpdate ${error.toString()}');
      });
    } catch (ex) {
      log('Catch Error performAppUpdate ${ex.toString()}');
    }
  }

  doPerformAppUpdate() {
    log('==== Check Oremus Update ====');
    if (GetPlatform.isAndroid) {
      Timer(const Duration(seconds: 2), () {
        performAppUpdate();
      });
    }
  }
}
