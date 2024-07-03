import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class FilterMassRequestHistoryController extends GetxController {
  final MassRequestRepository massRequestRepository;

  FilterMassRequestHistoryController({
    required this.massRequestRepository,
  });

  RxList<TypeData> massRequestTypes = RxList<TypeData>([]);
  RxList<TypeData> massRequestTypesTemp = RxList<TypeData>([]);
  var massRequestTypeSelected = TypeData().obs;
  var unlockBackButton = true.obs;

  var isMassRequestDataProcessing = false.obs;
  var hasMassRequestData = false.obs;

  late TextEditingController typeMassRequestSearchController;

  var isMassRequestSearchFieldEmpty = true.obs;

  var searchCriteria = SearchCriteria().obs;
  var enabledApplyButton = false.obs;

  @override
  void onInit() {
    initControllers();
    super.onInit();
  }

  @override
  void onReady() {
    getMassRequestType();
    super.onReady();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  initControllers() {
    typeMassRequestSearchController = TextEditingController(text: '');
  }

  disposeControllers() {
    typeMassRequestSearchController.dispose();
  }

  getMassRequestType() {
    hideKeyboard();

    log('request getMassRequestType');
    isMassRequestDataProcessing(true);
    massRequestRepository.getMassRequestType(page: 0).then((value) {
      isMassRequestDataProcessing(false);
      if (value.isNotEmpty == true) {
        hasMassRequestData(true);
        massRequestTypes.value = value;
        massRequestTypesTemp.value = value;
      } else {
        hasMassRequestData(false);
      }
    }, onError: (error) {
      isMassRequestDataProcessing(false);
      hasMassRequestData(false);
      var err = error as CustomException;
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

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  resetControllers() {
    searchCriteria.value.typeOfMassRequest = null;
  }

  doResetFilter() {
    massRequestTypeSelected.value = TypeData();
    searchCriteria.value.typeOfMassRequest = null;
    resetControllers();
    canDoApplyAction();
    hideKeyboard();
    Get.delete<FilterMassRequestHistoryController>(force: true);
  }

  onMassRequestTypeDataSelected(TypeData pt) {
    if (massRequestTypeSelected.value == pt) {
      massRequestTypeSelected.value = TypeData();
      searchCriteria.value.typeOfMassRequest = null;
    } else {
      massRequestTypeSelected.value = pt;
      searchCriteria.value.typeOfMassRequest = pt.code;
    }
    canDoApplyAction();
  }

  int getCriteriaCount() {
    var sum = 0;
    if (searchCriteria.value.typeOfMassRequest != null && searchCriteria.value.typeOfMassRequest?.isNotEmpty == true) {
      sum += 1;
    }
    return sum;
  }

  canDoApplyAction() {
    enabledApplyButton.value = searchCriteria.value.isMassRequestCriteriaEmpty == false;
  }

  goBackToMassRequestHistory() {
    searchCriteria.value.countCriteria = getCriteriaCount();
    Get.back(result: searchCriteria.value);
  }

  updateMassRequestTypeFilter(String value) {
    massRequestTypesTemp.value = massRequestTypes.where((p) => p.name?.fr?.toLowerCase().contains(value.toLowerCase()) == true).toList();
  }

  //SEARCH SECTION
  resetMassRequestTypeSearch() {
    typeMassRequestSearchController.clear();
    massRequestTypesTemp.value = massRequestTypes.value;
    hideKeyboard();
  }
}
