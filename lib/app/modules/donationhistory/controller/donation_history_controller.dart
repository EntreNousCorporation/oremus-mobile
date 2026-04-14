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
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/donationhistory/data/repository/donation_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class DonationHistoryController extends GetxController {
  final DonationHistoryRepository donationHistoryRepository;
  final DonationRepository donationRepository;
  final ParoisseRepository paroisseRepository;

  DonationHistoryController({
    required this.donationHistoryRepository,
    required this.donationRepository,
    required this.paroisseRepository,
  });

  RxList<DonationResponse?> donations = RxList<DonationResponse?>([]);
  var refreshController = RefreshController();
  late TextEditingController searchController;
  var searchCriteria = SearchCriteria().obs;
  var page = 0.obs;

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var paroisseSelected = ContentPlace().obs;

  var selectedDate = Rx<DateTimeRange>(DateTimeRange(start: DateTime.now(), end: DateTime.now()));
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

  canRedoPayment(DonationResponse? donationSelected) {
    return donationSelected?.status?.code == 'REQUEST_INITIATED';
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
    getDonations();
  }

  showRangeDatePickerBack() async {
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
          data: ThemeData.light(useMaterial3: false).copyWith(
            colorScheme: const ColorScheme.light(
              onPrimary: colorWhite, // selected text color
              onSurface: colorBlack, // default text color
              primary: colorGreen, // circle color
            ),
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
            ), dialogTheme: const DialogThemeData(backgroundColor: colorWhite),
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
      getDonations();
    }
  }

  showRangeDatePicker() async {
    const primaryColor = colorGreen;

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
          data: ThemeData(
            // Désactiver explicitement Material 3
            useMaterial3: false,
            // Couleurs principales
            primaryColor: primaryColor,
            primarySwatch: MaterialColor(primaryColor.value, {
              50: primaryColor.withValues(alpha: 0.1),
              100: primaryColor.withValues(alpha: 0.2),
              200: primaryColor.withValues(alpha: 0.3),
              300: primaryColor.withValues(alpha: 0.4),
              400: primaryColor.withValues(alpha: 0.5),
              500: primaryColor.withValues(alpha: 0.6),
              600: primaryColor.withValues(alpha: 0.7),
              700: primaryColor.withValues(alpha: 0.8),
              800: primaryColor.withValues(alpha: 0.9),
              900: primaryColor,
            }),
            scaffoldBackgroundColor: Colors.white,

            // Style des boutons
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                animationDuration: const Duration(milliseconds: 300),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return primaryColor.withValues(alpha: 0.8);
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return primaryColor.withValues(alpha: 0.9);
                  }
                  return primaryColor;
                }),
                textStyle: WidgetStateProperty.all(TextStyles.montserratMedium(
                  textColor: colorGrey1,
                  textSize: TextSizes.fifteen,
                ),),
                iconColor: WidgetStateProperty.all(colorWhite),
                overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                elevation: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return 0;
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return 2;
                  }
                  return 0;
                }),
              ),
            ),

            // Animations fluides par défaut
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: primaryColor,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: TextStyles.montserratMedium(
                textColor: colorGrey1,
                textSize: TextSizes.twenty,
              ),
              headerHelpStyle: TextStyles.montserratMedium(
                textSize: TextSizes.fourteen,
              ),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return primaryColor;
                if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.1);
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                if (states.contains(WidgetState.disabled)) return Colors.grey[400];
                return Colors.black87;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return primaryColor;
                return primaryColor.withValues(alpha: 0.1);
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return primaryColor;
              }),
              rangePickerHeaderHeadlineStyle: TextStyles.montserratMedium(
                textSize: TextSizes.seventeen,
              ),
              rangePickerHeaderHelpStyle: TextStyles.montserratMedium(
                textSize: TextSizes.fourteen,
              ),
              rangePickerHeaderForegroundColor: colorWhite,
              rangeSelectionBackgroundColor: primaryColor.withValues(alpha: 0.1),
              rangeSelectionOverlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return primaryColor.withValues(alpha: 0.2);
                if (states.contains(WidgetState.hovered)) return primaryColor.withValues(alpha: 0.15);
                return primaryColor.withValues(alpha: 0.1);
              }),
            ),

            dialogTheme: DialogThemeData(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: child!,
          ),
        );
      },
    );

    if (selected != null) {
      selectedDate.value = selected;

      String startDay = selected.start.day.toString().padLeft(2, '0');
      String startMonth = selected.start.month.toString().padLeft(2, '0');
      String endDay = selected.end.day.toString().padLeft(2, '0');
      String endMonth = selected.end.month.toString().padLeft(2, '0');

      startDateApi.value = "${selected.start.year}-$startMonth-$startDay${'T00:00:00.988Z'}";
      endDateApi.value = "${selected.end.year}-$endMonth-$endDay${'T23:59:59.988Z'}";
      startDate.value = "$startDay/$startMonth/${selected.start.year}";
      endDate.value = "$endDay/$endMonth/${selected.end.year}";
      datesRange.value = '${startDate.value} - ${endDate.value}';
      searchController.text = datesRange.value;
      getDonations();
    }
  }

  moveToPayment(DonationResponse? massRequestResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: {
        'payment_response': massRequestResponse?.toJson(),
        'payment_type': PaymentType.donation,
      },
    );
  }

  moveToDonation(DonationResponse? massRequestData) {
    Get.toNamed(
      Routes.DONATION,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData?.toJson(),
      ],
    );
  }

  moveToHistoryDetail(DonationResponse? donationResponse) {
    Get.toNamed(
      Routes.DONATION_HISTORY_DETAIL,
      arguments: donationResponse?.isForOremus == false ? {
        'paroisseSelected': donationWithoutWorship.value
            ? donationResponse?.worshipPlace?.toJson()
            : paroisseSelected.toJson(),
        'donationResponse': donationResponse?.toJson(),
      } : {
        'donationResponse': donationResponse?.toJson(),
      },
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  doSendDonation(DonationResponse? massRequestData) {
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

    donationRepository.donationRetryPayment(request: request).then((value) {
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

  getDonations() {
    hideKeyboard();
    searchCriteria.value.startDate = startDateApi.value;
    searchCriteria.value.endDate = endDateApi.value;
    searchCriteria.value.worshipPlace = paroisseSelected.value.identifier;
    isDataProcessing(true);

    log('request getMassRequests ::: ${jsonEncode(searchCriteria.toJson())}');

    donationHistoryRepository
        .getDonations(searchCriteria: searchCriteria.value)
        .then((value) {
      isDataProcessing(false);
      donations.value = value.contents ?? [];
      if (donations.isNotEmpty == true) {
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
    donationHistoryRepository
        .getDonations(searchCriteria: searchCriteria.value)
        .then((value) {
      refreshController.refreshCompleted();
      donations.value = value.contents ?? [];
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

    donationHistoryRepository
        .getDonations(page: page.value, searchCriteria: searchCriteria.value)
        .then((value) {
      donations.addAll(value.contents ?? []);
      donations.refresh();
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
    searchCriteria.value = await Get.toNamed(Routes.FILTER_DONATION_HISTORY);
    searchCriteria.refresh();
    getDonations();
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
