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
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrayController extends GetxController {
  final PrayRepository prayRepository;

  PrayController({required this.prayRepository});

  var unlockBackButton = true.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var readMore = false.obs;

  var refreshController = RefreshController();

  var page = 0.obs;
  RxList<Prayer> prayers = RxList<Prayer>([]);

  @override
  void onInit() {
    super.onInit();
    initPullToRefresh();
  }

  @override
  void onReady() {
    getPrayers();
    super.onReady();
  }

  @override
  void dispose() {
   refreshController.dispose();
   super.dispose();
  }

  initPullToRefresh() {
    refreshController = RefreshController(initialRefresh: false);
  }

  ///Chargement initial des prières
  getPrayers() {
    hideKeyboard();
    isDataProcessing(true);

    log('request getPrayers');

    prayRepository.getPrayers(page: page.value).then((value) {
      isDataProcessing(false);
      prayers.value = value;
      if (prayers.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
      if (value.isNotEmpty) {
            page.value += 1;
          } else {
            refreshController.loadNoData();
          }
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      var err = error as CustomException;
      if (byPassAuth == true) {
        if (err.code == 900) {
          showNotification(message: err.message.toString());
        }
        return;
      }

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
  onRefresh() {
    log('request onRefresh');

    resetSearch();
    prayRepository.getPrayers().then((value) {
      refreshController.refreshCompleted();
      prayers.value = value;
      if (value.isNotEmpty) {
            page.value += 1;
          } else {
            refreshController.loadNoData();
          }
    }, onError: (error) {
      refreshController.refreshCompleted();
      var err = error as CustomException;
      if (byPassAuth == true) {
        if (err.code == 900) {
          showNotification(message: err.message.toString());
        }
        return;
      }

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
  onLoading() {
    hideKeyboard();

    log('request onLoading');

    prayRepository.getPrayers(page: page.value).then((value) {
      prayers.addAll(value);
      prayers.refresh();
      refreshController.loadComplete();
      log('${prayers.length}');
      if (value.isNotEmpty) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      refreshController.loadFailed();
      var err = error as CustomException;
      if (byPassAuth == true) {
        if (err.code == 900) {
          showNotification(message: err.message.toString());
        }
        return;
      }

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

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    page.value = 0;
    hideKeyboard();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
