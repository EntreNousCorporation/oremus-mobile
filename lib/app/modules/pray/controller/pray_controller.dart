import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';
import 'package:oremusapp/app/modules/pray/data/repository/pray_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class PrayController extends GetxController {
  final PrayRepository prayRepository;

  PrayController({required this.prayRepository});

  var unlockBackButton = true.obs;
  var isMisselPrayersDataProcessing = false.obs;
  var hasMisselPrayersData = false.obs;
  var isCustomPrayersDataProcessing = false.obs;
  var hasCustomPrayersData = false.obs;

  var refreshMisselPrayerController = RefreshController();
  var refreshCustomPrayersController = RefreshController();

  var pageMisselPrayer = 0.obs;
  RxList<Prayer> misselPrayers = RxList<Prayer>([]);
  var pageCustomPrayers = 0.obs;
  RxList<Prayer> customPrayers = RxList<Prayer>([]);

  @override
  void onInit() {
    super.onInit();
    initPullToRefresh();
  }

  @override
  void onReady() {
    getMisselPrayers();
    getCustomPrayers();
    super.onReady();
  }

  @override
  void dispose() {
   refreshMisselPrayerController.dispose();
   refreshCustomPrayersController.dispose();
   super.dispose();
  }

  initPullToRefresh() {
    refreshMisselPrayerController = RefreshController(initialRefresh: false);
    refreshCustomPrayersController = RefreshController(initialRefresh: false);
  }

  ///Chargement initial des prières
  getMisselPrayers() {
    hideKeyboard();
    isMisselPrayersDataProcessing(true);

    log('request getPrayers');

    prayRepository.getPrayers(page: pageMisselPrayer.value).then((value) {
      isMisselPrayersDataProcessing(false);
      misselPrayers.value = value;
      if (misselPrayers.isNotEmpty == true) {
        hasMisselPrayersData(true);
      } else {
        hasMisselPrayersData(false);
      }
      if (value.isNotEmpty) {
            pageMisselPrayer.value += 1;
          } else {
            refreshMisselPrayerController.loadNoData();
          }
    }, onError: (error) {
      isMisselPrayersDataProcessing(false);
      hasMisselPrayersData(false);
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
      log("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des prières (desactiver pour l'instant)
  onMisselPrayersRefresh() {
    log('request onRefresh');

    resetMisselPrayers();
    prayRepository.getPrayers().then((value) {
      refreshMisselPrayerController.refreshCompleted();
      misselPrayers.value = value;
      if (value.isNotEmpty) {
            pageMisselPrayer.value += 1;
          } else {
            refreshMisselPrayerController.loadNoData();
          }
    }, onError: (error) {
      refreshMisselPrayerController.refreshCompleted();
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
      log("error => ${error.toString()}");
    });
  }

  ///Pagination des prières (desactiver pour l'instant)
  onMisselPrayersLoading() {
    hideKeyboard();

    log('request onLoading');

    prayRepository.getPrayers(page: pageMisselPrayer.value).then((value) {
      misselPrayers.addAll(value);
      misselPrayers.refresh();
      refreshMisselPrayerController.loadComplete();
      log('${misselPrayers.length}');
      if (value.isNotEmpty) {
        pageMisselPrayer.value += 1;
      } else {
        refreshMisselPrayerController.loadNoData();
      }
    }, onError: (error) {
      refreshMisselPrayerController.loadFailed();
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
      log("error => ${error.toString()}");
    });
  }

  resetMisselPrayers() {
    refreshMisselPrayerController.loadComplete();
    pageMisselPrayer.value = 0;
    hideKeyboard();
  }


  ///Chargement initial des prières ordinaires
  getCustomPrayers() {
    hideKeyboard();
    isCustomPrayersDataProcessing(true);

    prayRepository.getCustomPrayers(page: pageCustomPrayers.value).then((value) {
      isCustomPrayersDataProcessing(false);
      customPrayers.value = value;
      if (customPrayers.isNotEmpty == true) {
        hasCustomPrayersData(true);
      } else {
        hasCustomPrayersData(false);
      }
      if (value.isNotEmpty) {
            pageCustomPrayers.value += 1;
          } else {
            refreshCustomPrayersController.loadNoData();
          }
    }, onError: (error) {
      isCustomPrayersDataProcessing(false);
      hasCustomPrayersData(false);
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
      log("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des prières Custom (desactiver pour l'instant)
  onCustomPrayersRefresh() {
    resetCustomPrayers();
    prayRepository.getCustomPrayers().then((value) {
      refreshCustomPrayersController.refreshCompleted();
      customPrayers.value = value;
      if (value.isNotEmpty) {
            pageCustomPrayers.value += 1;
          } else {
            refreshCustomPrayersController.loadNoData();
          }
    }, onError: (error) {
      refreshCustomPrayersController.refreshCompleted();
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
      log("error => ${error.toString()}");
    });
  }

  ///Pagination des prières Custom (desactiver pour l'instant)
  onCustomPrayersLoading() {
    hideKeyboard();

    prayRepository.getCustomPrayers(page: pageCustomPrayers.value).then((value) {
      customPrayers.addAll(value);
      customPrayers.refresh();
      refreshCustomPrayersController.loadComplete();
      log('${customPrayers.length}');
      if (value.isNotEmpty) {
        pageCustomPrayers.value += 1;
      } else {
        refreshCustomPrayersController.loadNoData();
      }
    }, onError: (error) {
      refreshCustomPrayersController.loadFailed();
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
      log("error => ${error.toString()}");
    });
  }

  resetCustomPrayers() {
    refreshCustomPrayersController.loadComplete();
    pageCustomPrayers.value = 0;
    hideKeyboard();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
