import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FilterMassRequestWorshipController extends GetxController {
  final ParoisseRepository paroisseRepository;

  FilterMassRequestWorshipController({
    required this.paroisseRepository,
  });

  var previousSimpleSearchValue = ''.obs;
  var currentSimpleSearchValue = ''.obs;
  late TextEditingController searchController;
  var refreshController = RefreshController();
  var searchCriteria = SearchCriteria().obs;
  var isSearchFieldEmpty = true.obs;
  var page = 0.obs;

  var title = ''.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  RxList<ContentPlace?> paroisses = RxList<ContentPlace?>([]);
  Rx<ContentPlace?> worshipSelected = ContentPlace().obs;

  @override
  void onInit() {
    getArguments();
    initController();
    getParoisses();
    super.onInit();
  }

  @override
  void onReady() {
    getArguments();
    super.onReady();
  }

  initController() {
    searchController = TextEditingController(text: '');
  }

  getArguments() {
    if (Get.arguments != null) {
      title.value = Get.arguments;
    }
    title.refresh();
  }

  doLaunchSimpleSearch() {
    if (currentSimpleSearchValue.value != previousSimpleSearchValue.value) {
      previousSimpleSearchValue.value = currentSimpleSearchValue.value;
      getParoisses();
    }
  }

  ///Chargement initial des paroisses
  getParoisses() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();
    isDataProcessing(true);

    log('request getParoisses');

    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then(
        (value) {
      isDataProcessing(false);
      paroisses.value = value.contents ?? [];
      if (paroisses.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
      if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);

      var err = error as CustomException;
      if (err.code.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code.toString().contains('900')) {
        showCustomDialog(
          Get.context!,
          message: err.message.toString(),
        );
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des paroisses
  onRefresh() {
    log('request onRefresh');

    resetSearch();
    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then(
        (value) {
      refreshController.refreshCompleted();
      paroisses.value = value.contents ?? [];
      if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      var err = error as CustomException;
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code.toString().contains('900')) {
        showCustomDialog(
          Get.context!,
          message: err.message.toString(),
        );
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Pagination des paroisses
  onLoading() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();

    log('request onLoading');

    paroisseRepository
        .getParoisses(page: page.value, searchCriteria: searchCriteria.value)
        .then((value) {
      paroisses.addAll(value.contents ?? []);
      paroisses.refresh();
      refreshController.loadComplete();
      log('${paroisses.length}');
      if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      refreshController.loadFailed();
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

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    searchCriteria.value = SearchCriteria();
    page.value = 0;
    searchController.clear();
    isSearchFieldEmpty.value = true;
    previousSimpleSearchValue.value = '';
    currentSimpleSearchValue.value = '';
    hideKeyboard();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  goBackToMassRequest() {
    Get.back(result: worshipSelected);
  }
}
