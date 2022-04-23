import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseController({
    required this.paroisseRepository,
  });

  var userConnection = Signin().obs;

  RxList<ContentPlace> paroisses = RxList<ContentPlace>([]);

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var refreshController = RefreshController();

  late TextEditingController searchController;
  var isSearchFieldEmpty = true.obs;
  var searchCriteria = SearchCriteria().obs;

  @override
  void onInit() {
    getUserInfo();
    initController();
    super.onInit();
  }

  @override
  void onReady() {
    getParoisses();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  initController() {
    searchController = TextEditingController(text: '');
  }

  getParoisses() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();
    isDataProcessing(true);

    log('request getParoisses');

    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then((value) {
      isDataProcessing(false);
      if (value.empty == false) {
        hasData(true);
        paroisses.value = value.content ?? [];
        //paroisses.value.sort((p1, p2) => p1.name!.compareTo(p2.name!));
      } else {
        hasData(false);
      }
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
            Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  saveFavorite(ContentPlace paroisse, bool state) {
    paroisseRepository.addFavorite(paroisse);
    //showMessageFavorite(state);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    paroisseRepository.addFavorite(paroisse);
    //showMessageFavorite(state);
  }

  showMessageFavorite(bool state) {
    if (state) {
      showNotification(
          message: 'Ce lieu de culte a été rajouté dans vos favoris',
          bgColor: colorGreenSemiLight
      );
    } else {
      showNotification(
          message: 'Ce lieu de culte a été retiré des favoris',
      );
    }
  }

  doLogout() {
    encryptedBox.put(AppConstants.USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  onRefresh() {

    log('request onRefresh');

    resetSearchField();
    paroisseRepository.getParoisses().then((value) {
      refreshController.refreshCompleted();
      if (value.empty == false) {
        paroisses.value = value.content ?? [];
        //paroisses.value.sort((p1, p2) => p1.name!.compareTo(p2.name!));
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    log('==> $userInfo');
    if (userInfo != null) {
      Signin userConnected =
      Signin.fromJson(jsonDecode(userInfo));
      userConnection.value = userConnected;
      log('==> ${userConnection.value.toJson()}');
    }
  }

  goToAdvancedSearch() async {
    searchCriteria.value = await Get.toNamed(Routes.FILTER_PAROISSE);
    searchCriteria.refresh();
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    log('searchCriteria isEmpty => ${searchCriteria.value.isCriteriaEmpty}');
  }

  //SEARCH SECTION
  resetSearchField() {
    searchController.clear();
    isSearchFieldEmpty.value = true;
    hideKeyboard();
  }
}
