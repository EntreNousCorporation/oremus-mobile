import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FilterParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  FilterParoisseController({
    required this.paroisseRepository,
  });

  var userConnection = Signin().obs;

  RxList<PlaceType> paroisseTypes = RxList<PlaceType>([]);
  var placeTypeSelected = PlaceType().obs;
  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  late TextEditingController dioceseController;
  late TextEditingController cityController;
  late TextEditingController municipalityController;
  late TextEditingController neighborhoodController;

  var searchCriteria = SearchCriteria().obs;
  var enabledApplyButton = false.obs;

  @override
  void onInit() {
    getUserInfo();
    initController();
    super.onInit();
  }

  @override
  void onReady() {
    getParoisseType();
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initController() {
    dioceseController = TextEditingController(text: '');
    cityController = TextEditingController(text: '');
    municipalityController = TextEditingController(text: '');
    neighborhoodController = TextEditingController(text: '');
  }

  getParoisseType() {
    hideKeyboard();

    log('request getParoisseType');

    paroisseRepository.getPlaceOfWorshipTypes().then((value) {
      isDataProcessing(false);
      if (value.isNotEmpty == true) {
        hasData(true);
        paroisseTypes.value = value;
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

  resetControllers() {
    dioceseController.clear();
    searchCriteria.value.diocese = null;
    cityController.clear();
    searchCriteria.value.city = null;
    municipalityController.clear();
    searchCriteria.value.municipality = null;
    neighborhoodController.clear();
    searchCriteria.value.neighborhood = null;
  }

  doResetFilter() {
    placeTypeSelected.value = PlaceType();
    searchCriteria.value.type = null;
    resetControllers();
    canDoApplyAction();
    hideKeyboard();
  }

  onPlaceTypeSelected(PlaceType pt) {
    if (placeTypeSelected.value == pt) {
      placeTypeSelected.value = PlaceType();
    } else {
      placeTypeSelected.value = pt;
      searchCriteria.value.type = pt.code;
    }
    canDoApplyAction();
  }

  int getCriteriaCount() {
    var sum = 0;
    if (searchCriteria.value.type != null && searchCriteria.value.type?.isNotEmpty == true) {
      sum += 1;
    }
    if (searchCriteria.value.diocese != null && searchCriteria.value.diocese?.isNotEmpty == true) {
      sum += 1;
    }
    if (searchCriteria.value.city != null && searchCriteria.value.city?.isNotEmpty == true) {
      sum += 1;
    }
    if (searchCriteria.value.municipality != null && searchCriteria.value.municipality?.isNotEmpty == true) {
      sum += 1;
    }
    if (searchCriteria.value.neighborhood != null && searchCriteria.value.neighborhood?.isNotEmpty == true) {
      sum += 1;
    }
    return sum;
  }

  canDoApplyAction() {
    enabledApplyButton.value = searchCriteria.value.isCriteriaEmpty == false;
  }

  goBackToParoisse() {
    searchCriteria.value.countCriteria = getCriteriaCount();
    Get.back(result: searchCriteria.value);
  }
}
