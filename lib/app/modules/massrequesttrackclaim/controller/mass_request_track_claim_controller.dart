import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MassRequestTrackClaimController extends GetxController {
  final MassRequestClaimRepository massRequestClaimRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestTrackClaimController({
    required this.massRequestClaimRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var refreshController = RefreshController();
  late TextEditingController searchController;
  var page = 0.obs;
  var searchCriteria = SearchCriteria().obs;

  RxList<ClaimData?> claims = RxList<ClaimData?>([]);
  var paroisseSelected = ContentPlace().obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments);
      doGetClaims();
    }
  }

  moveToTrackClaimDetails(ClaimData? claimData) {
    Get.toNamed(
      Routes.MASS_REQUEST_TRACK_CLAIM_DETAILS,
      arguments: [
        paroisseSelected.toJson(),
        claimData?.toJson(),
      ],
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  goToWorshipChoice() async {
    paroisseSelected = await Get.toNamed(
      Routes.FILTER_MASS_REQUEST_CHOOSE_WORSHIP,
      arguments: 'Suivi de réclamation',
    );
    log('goToWorshipChoice ::: ${paroisseSelected.value.identifier}');
    if (paroisseSelected.value.identifier != null) {
      paroisseSelected.refresh();
    }
    doGetClaims();
    update();
  }

  doGetClaims() {
    hideKeyboard();
    searchCriteria.value.worshipPlace = paroisseSelected.value.identifier;
    isDataProcessing(true);

    log('request doGetClaims ::: ${jsonEncode(searchCriteria.toJson())}');

    massRequestClaimRepository
        .getClaims(searchCriteria: searchCriteria.value)
        .then((value) {
      isDataProcessing(false);
      claims.value = value.contents ?? [];
      if (claims.isNotEmpty == true) {
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
    massRequestClaimRepository
        .getClaims(searchCriteria: searchCriteria.value)
        .then((value) {
      refreshController.refreshCompleted();
      claims.value = value.contents ?? [];
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

    massRequestClaimRepository
        .getClaims(page: page.value, searchCriteria: searchCriteria.value)
        .then((value) {
      claims.addAll(value.contents ?? []);
      claims.refresh();
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

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    searchCriteria.value = SearchCriteria();
    page.value = 0;
    searchController.clear();
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
      arguments: paroisseSelected.toJson(),
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
