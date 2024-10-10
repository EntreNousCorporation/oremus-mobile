import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MassRequestHistoryController extends GetxController {
  final MassRequestHistoryRepository massRequestHistoryRepository;
  final MassRequestRepository massRequestRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestHistoryController({
    required this.massRequestHistoryRepository,
    required this.massRequestRepository,
    required this.paroisseRepository,
  });

  RxList<MassRequestResponse?> massRequests = RxList<MassRequestResponse?>([]);
  var refreshController = RefreshController();
  late TextEditingController searchController;
  var searchCriteria = SearchCriteria().obs;
  var page = 0.obs;

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var paroisseSelected = ContentPlace().obs;

  var selectedDate = Rx<DateTimeRange>(
      DateTimeRange(start: DateTime.now(), end: DateTime.now()));
  var datesRange = ''.obs;
  var startDate = ''.obs;
  var endDate = ''.obs;
  var startDateApi = ''.obs;
  var endDateApi = ''.obs;

  @override
  void onInit() {
    getArguments();
    initController();
    super.onInit();
  }

  @override
  void onReady() {
    initCriteria();
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

  canRedoPayment(MassRequestResponse? massRequestSelected) {
    return massRequestSelected?.status?.code != 'REQUEST_PAID' && massRequestSelected?.status?.code != 'REQUEST_ACCEPTED' && massRequestSelected?.status?.code != 'REQUEST_REFUSED';
  }

  initCriteria() {
    startDate.value = Jiffy.now()
        .subtract(days: 6)
        .format(pattern: AppConstants.TIME_SIMPLE_FORMAT);
    endDate.value =
        Jiffy.now().format(pattern: AppConstants.TIME_SIMPLE_FORMAT);
    startDateApi.value = Jiffy.now()
        .subtract(days: 6)
        .format(pattern: '${AppConstants.TIME_SIMPLE_FORMA1}T00:00:00.988[Z]');
    endDateApi.value = Jiffy.now()
        .format(pattern: '${AppConstants.TIME_SIMPLE_FORMA1}T23:59:59.988[Z]');
    datesRange.value = '${startDate.value} - ${endDate.value}';
    searchController.text = datesRange.value;
    selectedDate.value = DateTimeRange(
        start: Jiffy.now().subtract(days: 6).dateTime,
        end: Jiffy.now().dateTime);
    getMassRequests();
  }

  showRangeDatePicker() async {
    final DateTimeRange? selected = await showDateRangePicker(
      context: Get.context!,
      initialDateRange: selectedDate.value,
      saveText: 'Valider',
      locale: const Locale('fr'),
      currentDate: selectedDate.value.start,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      cancelText: 'Annuler',
      confirmText: 'Valider',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              onPrimary: colorWhite, // selected text color
              onSurface: colorBlack, // default text color
              primary: colorGreen, // circle color
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorWhite,
                textStyle: TextStyles.montserratMedium(
                  textSize: TextSizes.fourteen,
                ), // color of button's letters
                backgroundColor: colorGreen, // Background color
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      selectedDate.value = selected;

      //For startDate
      String startDay = selectedDate.value.start.day.toString();
      String startMonth = selectedDate.value.start.month.toString();
      if (selectedDate.value.start.day < 10) {
        startDay = "0$startDay";
      }
      if (selectedDate.value.start.month < 10) {
        startMonth = "0$startMonth";
      }

      //For endDate
      String endDay = selectedDate.value.end.day.toString();
      String endMonth = selectedDate.value.end.month.toString();
      if (selectedDate.value.end.day < 10) {
        endDay = "0$endDay";
      }
      if (selectedDate.value.end.month < 10) {
        endMonth = "0$endMonth";
      }

      //For result
      startDateApi.value =
          "${selectedDate.value.start.year}-$startMonth-$startDay${'T00:00:00.988Z'}";
      endDateApi.value =
          "${selectedDate.value.end.year}-$endMonth-$endDay${'T23:59:59.988Z'}";
      startDate.value =
          "$startDay/$startMonth/${selectedDate.value.start.year}";
      endDate.value = "$endDay/$endMonth/${selectedDate.value.end.year}";
      datesRange.value = '${startDate.value} - ${endDate.value}';
      searchController.text = datesRange.value;
      getMassRequests();
    }
  }

  moveToPayment(MassRequestResponse? massRequestResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: massRequestResponse?.toJson(),
    );
  }

  moveToMassRequest(MassRequestResponse? massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData?.toJson(),
      ],
    );
  }

  moveToMassRequestClaims(MassRequestResponse? massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST_CLAIM,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData?.toJson(),
      ],
    );
  }

  moveToHistoryDetail(MassRequestResponse? massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST_HISTORY_DETAIL,
      arguments: [
        requestMassWithoutWorship.value
            ? massRequestData?.worshipPlace?.toJson()
            : paroisseSelected.toJson(),
        massRequestData?.toJson(),
      ],
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }

  doSendMassRequest(MassRequestResponse? massRequestData) {
    hideKeyboard();
    EasyLoading.show(
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = PaymentStatusData(
      transactionId: massRequestData?.transactionId ?? '-',
      id: massRequestData?.identifier,
    );

    log('request doSendMassRequest => ${jsonEncode(request.toJson())}');

    massRequestRepository.retryPayment(request: request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      moveToPayment(value);
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      debugPrint("error => ${error.toString()}");
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else {
        showNotification(
            message: 'Une erreur est survenue',
            duration: const Duration(seconds: 4));
      }
    });
  }

  getMassRequests() {
    hideKeyboard();
    searchCriteria.value.startDate = startDateApi.value;
    searchCriteria.value.endDate = endDateApi.value;
    searchCriteria.value.worshipPlace = paroisseSelected.value.identifier;
    isDataProcessing(true);

    log('request getMassRequests ::: ${jsonEncode(searchCriteria.toJson())}');

    massRequestHistoryRepository
        .getMassRequests(searchCriteria: searchCriteria.value)
        .then((value) {
      isDataProcessing(false);
      massRequests.value = value.contents ?? [];
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
      massRequests.value = value.contents ?? [];
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
    //searchCriteria.value.name = searchController.text.trim();

    log('request onLoading');

    massRequestHistoryRepository
        .getMassRequests(page: page.value, searchCriteria: searchCriteria.value)
        .then((value) {
      massRequests.addAll(value.contents ?? []);
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
    searchCriteria.value =
        await Get.toNamed(Routes.FILTER_MASS_REQUEST_HISTORY);
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    searchCriteria.refresh();
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    getMassRequests();
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    log('searchCriteria isEmpty => ${searchCriteria.value.isMassRequestCriteriaEmpty}');
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
