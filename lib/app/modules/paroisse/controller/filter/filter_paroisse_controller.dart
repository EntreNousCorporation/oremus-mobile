import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/diocese_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class FilterParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;
  final DioceseRepository dioceseRepository;

  FilterParoisseController({
    required this.paroisseRepository,
    required this.dioceseRepository,
  });

  RxList<PlaceType> paroisseTypes = RxList<PlaceType>([]);
  RxList<PlaceType> paroisseTypesTemp = RxList<PlaceType>([]);
  RxList<ContentPlace?> dioceses = RxList<ContentPlace?>([]);
  RxList<ContentPlace?> diocesesTemp = RxList<ContentPlace?>([]);
  var placeTypeSelected = PlaceType().obs;
  var dioceseSelected = ContentPlace().obs;
  var unlockBackButton = true.obs;

  var isWorshipPlaceDataProcessing = false.obs;
  var hasWorshipPlaceData = false.obs;

  var isDioceseDataProcessing = false.obs;
  var hasDioceseData = false.obs;

  late TextEditingController dioceseController;
  late TextEditingController cityController;
  late TextEditingController municipalityController;
  late TextEditingController neighborhoodController;
  late TextEditingController typeLiturgicalSearchController;
  late TextEditingController dioceseSearchController;

  var isTypeLiturgicalSearchFieldEmpty = true.obs;
  var isDioceseSearchFieldEmpty = true.obs;

  var searchCriteria = SearchCriteria().obs;
  var enabledApplyButton = false.obs;

  @override
  void onInit() {
    configStatusBar(
      statusBarIconBrightness: Brightness.dark,
      iOSStatusBarBrightness: Brightness.light,
    );
    initControllers();
    super.onInit();
  }

  @override
  void onReady() {
    getParoisseType();
    getDioceses();
    super.onReady();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  initControllers() {
    dioceseController = TextEditingController(text: '');
    cityController = TextEditingController(text: '');
    municipalityController = TextEditingController(text: '');
    neighborhoodController = TextEditingController(text: '');
    typeLiturgicalSearchController = TextEditingController(text: '');
    dioceseSearchController = TextEditingController(text: '');
  }

  disposeControllers() {
    dioceseController.dispose();
    cityController.dispose();
    municipalityController.dispose();
    neighborhoodController.dispose();
    typeLiturgicalSearchController.dispose();
    dioceseSearchController.dispose();
  }

  getParoisseType() {
    hideKeyboard();

    log('request getParoisseType');
    isWorshipPlaceDataProcessing(true);
    paroisseRepository.getPlaceOfWorshipTypes().then((value) {
      isWorshipPlaceDataProcessing(false);
      if (value.isNotEmpty == true) {
        hasWorshipPlaceData(true);
        paroisseTypes.value = value;
        paroisseTypesTemp.value = value;
      } else {
        hasWorshipPlaceData(false);
      }
    }, onError: (error) {
      isWorshipPlaceDataProcessing(false);
      hasWorshipPlaceData(false);
      if (error is! CustomException) return;
      final err = error;
      if (err.code == 401) {
        showCustomDialog(
            Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  getDioceses() {
    hideKeyboard();

    log('request getDioceses');
    isDioceseDataProcessing(true);
    dioceseRepository.getDioceses().then((value) {
      isDioceseDataProcessing(false);

      if (value.empty == false) {
        hasDioceseData(true);
        dioceses.value = value.contents ?? [];
        diocesesTemp.value = value.contents ?? [];
      } else {
        hasDioceseData(false);
      }

    }, onError: (error) {
      isDioceseDataProcessing(false);
      hasDioceseData(false);
      if (error is! CustomException) return;
      final err = error;
      if (err.code == 401) {
        showCustomDialog(
            Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
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
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
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
    dioceseSelected.value = ContentPlace();
    searchCriteria.value.type = null;
    resetControllers();
    canDoApplyAction();
    hideKeyboard();
    Get.delete<FilterParoisseController>(force: true);
  }

  onPlaceTypeSelected(PlaceType pt) {
    if (placeTypeSelected.value == pt) {
      placeTypeSelected.value = PlaceType();
      searchCriteria.value.type = null;
    } else {
      placeTypeSelected.value = pt;
      searchCriteria.value.type = pt.code;
    }
    canDoApplyAction();
  }

  onDioceseSelected(ContentPlace cp) {
    if (dioceseSelected.value == cp) {
      dioceseSelected.value = ContentPlace();
      searchCriteria.value.diocese = null;
    } else {
      dioceseSelected.value = cp;
      searchCriteria.value.diocese = cp.name;
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

  updateTypeLiturgicalFilter(String value) {
    log(value);
    paroisseTypesTemp.value = paroisseTypes.where((p) => p.translate?.fr?.toLowerCase().contains(value.toLowerCase()) == true).toList();
  }

  updateDioceseFilter(String value) {
    log(value);
    diocesesTemp.value = dioceses.where((p) => p?.name?.toLowerCase().contains(value.toLowerCase()) == true).toList();
  }

  //SEARCH SECTION
  resetTypeLiturgicalSearch() {
    typeLiturgicalSearchController.clear();
    paroisseTypesTemp.value = paroisseTypes.value;
    hideKeyboard();
  }
  resetDioceseSearch() {
    dioceseSearchController.clear();
    diocesesTemp.value = dioceses.value;
    hideKeyboard();
  }
}
