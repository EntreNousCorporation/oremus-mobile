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
import 'package:oremusapp/app/commons/services/notification_consent_manager.dart';
import 'package:oremusapp/app/commons/services/os_notification_service.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/favorite/controller/favorite_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
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
  var selectedIndex = AppConstants.HOME.obs;
  var title = ''.obs;

  var applyAnim = true.obs;

  final OSNotificationService notificationService = OSNotificationService();

  @override
  void onInit() {
    initNotification();

    if (flavor == AppConstants.ENV_PROD && GetPlatform.isAndroid) {
      doPerformAppUpdate();
    }
    initMenus();
    update();
    super.onInit();
  }

  initNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notificationService.initializeWithConsent(oneSignalAppID, Get.context!);
      if (!isUserConnected.value) {
        var deviceId = await notificationService.getDeviceId();
        if (deviceId?.isNotEmpty == true) {
          log('deviceId is NOT NULL');
          _sendDeviceId(deviceId);
        } else {
          log('deviceId is NULL');
        }
      }
    });
  }
  ///Function to send one signal device id
  _sendDeviceId(String? deviceId) {
    SigninRepository signinRepository = Get.put<SigninRepository>(SigninRepository(ApiClientImpl()));
    Signin request = Signin(deviceId: deviceId);
    log('request annonymous _sendDeviceId => ${request.toJson()}');

    signinRepository.devices(request).then((value) {
      log('_sendDeviceId annonymous successfully');
    }, onError: (error) {
      debugPrint("error annonymous _sendDeviceId => ${error.toString()}");
    });
  }

  initMenus() {
    menus.value = [
      MenusItem(
        code: AppConstants.HOME,
        libelle: 'Accueil',
        icon: Assets.imagesIconNavHome,
      ),
      MenusItem(
        code: AppConstants.REQUEST_MASS_WITHOUT_WORSHIP,
        libelle: "Demande de messe",
        icon: Assets.imagesMesse,
      ),
      MenusItem(
        code: AppConstants.PROFILE,
        libelle: 'Mon profil',
        icon: Assets.imagesIconUser,
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.PRAY,
        libelle: "Prières",
        icon: Assets.imagesIconPray,
      ),
      MenusItem(
        code: AppConstants.DONATION_WITHOUT_WORSHIP,
        libelle: "Faire un don",
        icon: Assets.imagesVolunteer,
      ),
      MenusItem(
        code: AppConstants.ROSAIRE,
        libelle: "Rosaire",
        icon: Assets.imagesRosary,
        isVisible: true,
      ),
      MenusItem(
        code: AppConstants.LIFE_PLAN,
        libelle: "Plan de vie",
        icon: Assets.imagesAssignment,
        isVisible: true,
      ),
      MenusItem(
        code: AppConstants.PROMO,
        libelle: 'Codes promo',
        icon: Assets.imagesIconSettings,
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.FAQ,
        libelle: 'F.A.Q',
        icon: Assets.imagesFaqIcon,
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.CONTACTS,
        libelle: 'Contacts',
        icon: Assets.imagesIconPhone,
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.ABOUT,
        libelle: 'A propos',
        icon: Assets.imagesIconSettings,
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.SHARE_APP,
        libelle: "Partager l'application",
        icon: Assets.imagesShareIcon,
        isVisible: true,
      ),
      MenusItem(
        code: AppConstants.SETTINGS,
        libelle: 'Paramètres',
        icon: Assets.imagesIconSettings,
        isVisible: true,
      ),
      MenusItem(
        code: AppConstants.SIGNIN,
        libelle: 'Connexion',
        icon: Assets.imagesUserLogin,
        isVisible: isUserConnected.value == true ? false : true,
      ),
    ];
    menus.value = menus.where((element) => element.isVisible).toList();
  }

  goToFavorites() {
    Get.toNamed(Routes.FAVORITES);
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
        requestMassWithoutWorship.value = false;
        donationWithoutWorship.value = false;
        doShareApp();
      } else if (menuCode == AppConstants.REQUEST_MASS_WITHOUT_WORSHIP || menuCode == AppConstants.DONATION_WITHOUT_WORSHIP) {
        requestMassWithoutWorship.value = true;
        donationWithoutWorship.value = true;
        controller.setSelectedMenuPosition(index);
      } else {
        requestMassWithoutWorship.value = false;
        donationWithoutWorship.value = false;
        controller.setSelectedMenuPosition(index);
      }
      update();
    }
  }

  void navigateToRosaryDirectly() {
    // Trouver l'index du rosaire dans les menus
    int rosaryIndex = menus.indexWhere((menu) => menu.code == AppConstants.ROSAIRE);

    if (rosaryIndex != -1) {
      // Mettre à jour l'index sélectionné
      selectedIndex.value = rosaryIndex;

      // Mettre à jour le titre
      title.value = menus[rosaryIndex].libelle ?? 'Rosaire';

      // Définir directement la position sélectionnée sans ouvrir le menu
      drawerController.setSelectedMenuPosition(rosaryIndex, openMenu: false);

      // Désactiver les flags pour les autres écrans
      requestMassWithoutWorship.value = false;
      donationWithoutWorship.value = false;

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
    // Mémoriser l'ID de l'utilisateur avant la déconnexion
    ParoisseController.prepareForLogout();

    // Effacer les données spécifiques à l'utilisateur dans DB
    DB.clearAllUserSpecificData();

    // Gérer la déconnexion dans le repository
    paroisseRepository.handleLogout();

    // Notifier le FavoriteController si disponible
    try {
      final favoriteController = Get.isRegistered<FavoriteController>() ? Get.find<FavoriteController>() : Get.put<FavoriteController>(FavoriteController(paroisseRepository: ParoisseRepository(ApiClientImpl())));
      favoriteController.handleLogout();
    } catch (e) {
      // Le contrôleur n'est pas disponible, rien à faire
      log('FavoriteController not available: $e');
    }

    // Effacer les données de connexion
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: false);
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
