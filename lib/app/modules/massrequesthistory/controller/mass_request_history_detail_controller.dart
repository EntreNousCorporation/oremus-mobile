import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/history_mass_request_selectable.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/history_mass_date_dialog.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class MassRequestHistoryDetailController extends GetxController implements HistoryMassRequestSelectable {
  final MassRequestHistoryRepository massRequestHistoryRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestHistoryDetailController({
    required this.massRequestHistoryRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var hasError = false.obs;
  var isLiked = false.obs;

  @override
  var massRequestSelected = MassRequestResponse().obs;

  var paroisseSelected = ContentPlace().obs;
  RxList<MassRequestStatusData> massRequestStatuses = RxList<MassRequestStatusData>([]);
  RxList<MassRequestAvailablesStatusesData> availableStatuses = RxList<MassRequestAvailablesStatusesData>([]);

  @override
  void onInit() {
    getArguments();
    doGetMassRequestStatuses();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments == null) return;
    Map arguments = Get.arguments;
    if (arguments.containsKey('paroisse_selected') && arguments['paroisse_selected'] != null) {
      paroisseSelected.value = ContentPlace.fromJson(arguments['paroisse_selected']);
      if (paroisseSelected.value.identifier.toString().isNotEmpty) {
        doGetWorshipDetails(paroisseSelected.value.identifier.toString());
      }
    }
    if (arguments.containsKey('mass_request_selected') && arguments['mass_request_selected'] != null) {
      massRequestSelected.value = MassRequestResponse.fromJson(arguments['mass_request_selected']);
    }
  }

  doGetWorshipDetails(String identifier) {
    paroisseRepository
        .getParoisseDetails(worshipId: paroisseSelected.value.identifier)
        .then(
          (value) {
        paroisseSelected.value = value;
        update();
      },
      onError: (error) {
        var err = error as CustomException;
        if (err.code.toString().contains('401')) {
          showCustomDialog(
            Get.context!,
            message:
            'Votre session a expiré\nVeuillez-vous reconnecter svp',
          ).then((value) {
            doLogout();
          });
        } else {
          showNotification(
            message:
            'Erreur lors du chargement des données: ${err.code.toString()}',
          );
        }
        debugPrint("error => ${error.toString()}");
      },
    );
  }

  moveToMassRequest(MassRequestResponse massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData.toJson(),
      ],
    );
  }

  moveToMassRequestClaims(MassRequestResponse massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST_CLAIM,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'mass_request_data': massRequestData.toJson(),
      },
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  double getDialogHoursHeight() {
    return massRequestSelected.value.bookings != null && massRequestSelected.value.bookings!.length > 3 ? Get.height * 0.65 : Get.height * 0.55;
  }

  showMassHours() {
    historyMassDateDialog(this);
  }

  canClaimMassRequest() {
    return massRequestSelected.value.status?.code == 'REQUEST_ACCEPTED' || massRequestSelected.value.status?.code == 'ACCEPTED_PAYMENT' || massRequestSelected.value.status?.code == 'REQUEST_REFUSED' || massRequestSelected.value.status?.code == 'REFUSED_PAYMENT';
  }

  doGetAllAvailablesStatuses() {
    hideKeyboard();
    var request = SearchCriteria(
      traceId: massRequestSelected.value.traceId.toString(),
    );
    isDataProcessing(true);
    hasData(false);
    hasError(false);

    massRequestHistoryRepository.getMassRequestsAvailablesStatuses(page: 0).then((value) {
      isDataProcessing(false);
      availableStatuses.value = value;
      if (availableStatuses.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
      hasError(false);
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      hasError(false);
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
      debugPrint("doGetAllAvailablesStatuses error => ${error.toString()}");
    });
  }

  doGetMassRequestStatuses() {
    hideKeyboard();
    var request = SearchCriteria(
      traceId: massRequestSelected.value.traceId.toString(),
    );
    isDataProcessing(true);
    hasData(false);
    hasError(false);

    log('request doGetMassRequestStatuses ::: ${jsonEncode(request.toJson())}');

    massRequestHistoryRepository
        .getMassRequestsStatus(searchCriteria: request)
        .then((value) {
      isDataProcessing(false);
      massRequestStatuses.value = value;
      if (massRequestStatuses.isNotEmpty == true) {
        hasData(true);
        doGetAllAvailablesStatuses();
      } else {
        hasData(false);
      }
      hasError(false);
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      hasError(false);
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
      debugPrint("doGetMassRequestStatuses error => ${error.toString()}");
    });
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
    paroisseRepository.addFavorite(paroisse);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    paroisseRepository.deleteFavorite(paroisse);
  }
}
