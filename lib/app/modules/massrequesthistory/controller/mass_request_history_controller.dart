import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MassRequestHistoryController extends GetxController {
  final MassRequestHistoryRepository massRequestHistoryRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestHistoryController({
    required this.massRequestHistoryRepository,
    required this.paroisseRepository,
  });

  RxList<MassRequestData> massRequests = RxList<MassRequestData>([]);
  var refreshController = RefreshController();
  late TextEditingController searchController;
  var isSearchFieldEmpty = true.obs;
  var searchCriteria = SearchCriteria().obs;
  var page = 0.obs;

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var paroisseSelected = ContentPlace().obs;

  @override
  void onInit() {
    getArguments();
    initController();
    super.onInit();
  }

  @override
  void onReady() {
    getMassRequests();
    super.onReady();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments);
    }
  }

  initController() {
    searchController = TextEditingController(text: '');
  }

  moveToMassRequest(MassRequestData massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData.toJson(),
      ],
    );
  }

  moveToMassRequestClaims(MassRequestData massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST_CLAIM,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData.toJson(),
      ],
    );
  }

  getMassRequests() {
    hideKeyboard();
    var dates = searchController.text.trim().split('-');
    searchCriteria.value = SearchCriteria(
      startDate: dates.first,
      endDate: dates.last,
      worshipPlace: paroisseSelected.value.identifier,
    );
    isDataProcessing(true);

    log('request getMassRequests ::: ${jsonEncode(searchCriteria.toJson())}');

    massRequestHistoryRepository
        .getMassRequests(searchCriteria: searchCriteria.value)
        .then((value) {
      isDataProcessing(false);
      massRequests.value = value.content ?? [];
      if (massRequests.isNotEmpty == true) {
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
      debugPrint("getMassRequests error => ${error.toString()}");
    });
  }

  onRefresh() {
    log('request onRefresh');

    resetSearch();
    massRequestHistoryRepository
        .getMassRequests(searchCriteria: searchCriteria.value)
        .then((value) {
      refreshController.refreshCompleted();
      massRequests.value = value.content ?? [];
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

  onLoading() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();

    log('request onLoading');

    massRequestHistoryRepository
        .getMassRequests(page: page.value, searchCriteria: searchCriteria.value)
        .then((value) {
      massRequests.addAll(value.content ?? []);
      massRequests.refresh();
      refreshController.loadComplete();
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

  goToAdvancedSearch() async {
    searchCriteria.value = await Get.toNamed(Routes.FILTER_PAROISSE);
    searchCriteria.refresh();
    getMassRequests();
  }

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    searchCriteria.value = SearchCriteria();
    page.value = 0;
    searchController.clear();
    isSearchFieldEmpty.value = true;
    hideKeyboard();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  bool isWorshipPlaceFavorite(ContentPlace paroisse) {
    var isFavorite = false;
    var favorites = paroisseRepository.getAllFavorites();
    var hasParoisse = favorites
        .indexWhere((element) => element.identifier == paroisse.identifier);
    if (hasParoisse != -1) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    return isFavorite;
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: paroisseSelected.value.toJson(),
    );
  }

  saveFavorite(ContentPlace paroisse, bool state) {
    log('saveFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.addFavorite(paroisse);
    //showMessageFavorite(state);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    log('removeFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.deleteFavorite(paroisse);
    //showMessageFavorite(state);
  }
}
