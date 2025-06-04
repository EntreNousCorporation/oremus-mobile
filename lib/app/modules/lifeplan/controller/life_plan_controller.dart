import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/create_life_plan_request.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/repository/life_plan_repository.dart';
import 'package:oremusapp/app/modules/lifeplan/service/calendar_service.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LifePlanController extends GetxController {
  final LifePlanRepository lifePlanRepository;
  final CalendarService _calendarService = CalendarService();

  LifePlanController({required this.lifePlanRepository});

  // Listes observables
  RxList<LifePlan?> availableLifePlans = RxList<LifePlan?>([]);
  RxList<UserLifePlan?> userLifePlans = RxList<UserLifePlan?>([]);

  // Controllers
  var refreshController = RefreshController();

  // États
  var isLoadingAvailable = false.obs;
  var isLoadingUser = false.obs;
  var hasAvailablePlans = false.obs;
  var hasUserPlans = false.obs;
  var selectedTab = 0.obs;

  // Pagination
  var availablePage = 0.obs;
  var userPage = 0.obs;

  // Plan sélectionné pour modification
  Rx<UserLifePlan?> selectedUserPlan = Rx<UserLifePlan?>(null);

  // Paramètres calendrier
  var addToCalendarByDefault = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCalendarPreference();
    loadInitialData();
  }

  void _loadCalendarPreference() {
    final saved = DB.getData(AppConstants.KEY_ADD_TO_CALENDAR);
    addToCalendarByDefault.value = saved ?? true;
  }

  void saveCalendarPreference(bool value) {
    addToCalendarByDefault.value = value;
    DB.saveBoolData(AppConstants.KEY_ADD_TO_CALENDAR, value);
  }

  void loadInitialData() {
    getAvailableLifePlans();
    getUserLifePlans();
  }

  // Récupérer les plans disponibles
  void getAvailableLifePlans() {
    isLoadingAvailable(true);

    lifePlanRepository.getAvailableLifePlans(page: availablePage.value).then((response) {
      isLoadingAvailable(false);

      if (availablePage.value == 0) {
        availableLifePlans.value = response.contents ?? [];
      } else {
        availableLifePlans.addAll(response.contents ?? []);
      }

      hasAvailablePlans.value = availableLifePlans.isNotEmpty;

      if (response.last == false) {
        availablePage.value += 1;
      }
    }, onError: (error) {
      isLoadingAvailable(false);
      _handleError(error);
    });
  }

  // Récupérer les plans de l'utilisateur
  void getUserLifePlans() {
    isLoadingUser(true);

    lifePlanRepository.getUserLifePlans(page: userPage.value).then((response) {
      isLoadingUser(false);

      if (userPage.value == 0) {
        userLifePlans.value = response.contents ?? [];
      } else {
        userLifePlans.addAll(response.contents ?? []);
      }

      hasUserPlans.value = userLifePlans.isNotEmpty;

      if (response.last == false) {
        userPage.value += 1;
      }
    }, onError: (error) {
      isLoadingUser(false);
      _handleError(error);
    });
  }

  // Créer un nouveau plan de vie
  void createLifePlan(LifePlan lifePlan, List<TimeSlot> customSlots, {bool addToCalendar = true}) async {
    EasyLoading.show(
      status: 'Création en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    );

    try {
      // Convertir les TimeSlot en format string attendu par l'API
      List<String> slotsAsStrings = customSlots.map((slot) {
        final h = (slot.hour ?? 0).toString().padLeft(2, '0');
        final m = (slot.minute ?? 0).toString().padLeft(2, '0');
        final s = (slot.second ?? 0).toString().padLeft(2, '0');
        return '$h:$m:$s';
      }).toList();

      var request = CreateLifePlanRequest(
        code: lifePlan.code ?? '',
        slots: slotsAsStrings,
      );

      log('createLifePlan request => ${request.toJson()}');

      final response = await lifePlanRepository.createUserLifePlan(request: request);

      userLifePlans.insert(0, response);
      hasUserPlans.value = true;

      // Ajouter au calendrier si demandé
      if (addToCalendar) {
        final calendarSuccess = await _calendarService.addLifePlanToCalendar(response);
        if (calendarSuccess) {
          log('Plan ajouté au calendrier avec succès');
        } else {
          log('Échec ajout au calendrier');
        }
      }

      EasyLoading.dismiss();
      Get.back();

      showNotification(
        message: addToCalendar
            ? 'Plan de vie créé et ajouté au calendrier'
            : 'Plan de vie créé avec succès',
        bgColor: colorGreenSemiLight,
      );
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Mettre à jour un plan de vie
  void updateLifePlan(UserLifePlan userLifePlan, List<TimeSlot> newSlots, {bool updateCalendar = true}) async {
    if (userLifePlan.identifier == null) return;

    EasyLoading.show(
      status: 'Modification en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    );

    try {
      // Convertir les TimeSlot en format string attendu par l'API
      List<String> slotsAsStrings = newSlots.map((slot) {
        final h = (slot.hour ?? 0).toString().padLeft(2, '0');
        final m = (slot.minute ?? 0).toString().padLeft(2, '0');
        final s = (slot.second ?? 0).toString().padLeft(2, '0');
        return '$h:$m:$s';
      }).toList();

      var request = UpdateLifePlanRequest(
        slots: slotsAsStrings,
      );

      log('updateLifePlan request => ${request.toJson()}');

      final response = await lifePlanRepository.updateUserLifePlan(
        id: userLifePlan.identifier!,
        request: request,
      );

      // Mettre à jour la liste
      int index = userLifePlans.indexWhere((p) => p?.identifier == userLifePlan.identifier);
      if (index != -1) {
        userLifePlans[index] = response;
      }

      // Mettre à jour le calendrier si demandé
      if (updateCalendar) {
        final calendarSuccess = await _calendarService.updateLifePlanInCalendar(response);
        if (calendarSuccess) {
          log('Plan mis à jour dans le calendrier');
        } else {
          log('Échec mise à jour calendrier');
        }
      }

      EasyLoading.dismiss();
      Get.back();

      showNotification(
        message: updateCalendar
            ? 'Plan de vie modifié et calendrier mis à jour'
            : 'Plan de vie modifié avec succès',
        bgColor: colorGreenSemiLight,
      );
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Supprimer un plan de vie
  void deleteLifePlan(UserLifePlan? userLifePlan) async {
    if (userLifePlan?.identifier == null) return;

    showCustomDialog(
      Get.context!,
      message: 'Êtes-vous sûr de vouloir supprimer ce plan de vie ?\n\nCela supprimera aussi les rappels du calendrier.',
      positiveLabel: 'Supprimer',
      negativeLabel: 'Annuler',
      positiveCallBack: () {
        _performDelete(userLifePlan);
      },
    );
  }

  void _performDelete(UserLifePlan? userLifePlan) async {
    EasyLoading.show(
      status: 'Suppression en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    );

    try {
      await lifePlanRepository.deleteUserLifePlan(id: userLifePlan?.identifier ?? -1);

      // Supprimer du calendrier
      if (userLifePlan?.identifier != null) {
        final calendarSuccess = await _calendarService.removeLifePlanFromCalendar(
            userLifePlan!.identifier!
        );
        if (calendarSuccess) {
          log('Événements supprimés du calendrier');
        }
      }

      userLifePlans.removeWhere((p) => p?.identifier == userLifePlan?.identifier);
      hasUserPlans.value = userLifePlans.isNotEmpty;

      EasyLoading.dismiss();
      showNotification(
        message: 'Plan de vie et rappels supprimés avec succès',
        bgColor: colorGreenSemiLight,
      );
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Méthode pour synchroniser un plan existant avec le calendrier
  void syncPlanWithCalendar(UserLifePlan userLifePlan) async {
    EasyLoading.show(
      status: 'Synchronisation avec le calendrier...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    );

    try {
      final success = await _calendarService.addLifePlanToCalendar(userLifePlan);
      EasyLoading.dismiss();

      if (success) {
        showNotification(
          message: 'Plan synchronisé avec le calendrier',
          bgColor: colorGreenSemiLight,
        );
      } else {
        showNotification(
          message: 'Échec de la synchronisation. Vérifiez les permissions.',
          bgColor: Colors.orange,
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Rafraîchir les données
  void onRefresh() {
    availablePage.value = 0;
    userPage.value = 0;

    Future.wait([
      lifePlanRepository.getAvailableLifePlans(),
      lifePlanRepository.getUserLifePlans(),
    ]).then((responses) {
      refreshController.refreshCompleted();

      availableLifePlans.value = (responses.first.contents) as List<LifePlan?>;
      userLifePlans.value = (responses[1].contents) as List<UserLifePlan?>;

      hasAvailablePlans.value = availableLifePlans.isNotEmpty;
      hasUserPlans.value = userLifePlans.isNotEmpty;
    }).catchError((error) {
      refreshController.refreshFailed();
      _handleError(error);
    });
  }

  // Navigation vers la sélection d'activités ou création/modification
  void goToCreateOrEditPlan({UserLifePlan? userPlan, LifePlan? lifePlan}) {
    if (userPlan != null) {
      // Mode édition d'un plan existant
      Get.toNamed(
        Routes.LIFE_PLAN_FORM,
        arguments: {
          'userLifePlan': userPlan.toJson(),
        },
      );
    } else if (lifePlan != null) {
      // Mode création avec une activité spécifique (ancien workflow)
      Get.toNamed(
        Routes.LIFE_PLAN_FORM,
        arguments: {
          'lifePlan': lifePlan.toJson(),
        },
      );
    } else {
      // Mode sélection multiple d'activités (nouveau workflow)
      Get.toNamed(Routes.ACTIVITY_SELECTION);
    }
  }

  // Gestion des erreurs
  void _handleError(dynamic error) {
    debugPrint("Error type: ${error.runtimeType}");
    debugPrint("Error details: ${error.toString()}");

    if (error is CustomException) {
      if (error.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else {
        showNotification(
          message: error.message ?? 'Une erreur est survenue',
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      // Gérer les autres types d'erreurs
      String errorMessage = 'Une erreur est survenue';
      if (error is TypeError) {
        errorMessage = 'Erreur de format de données';
      }
      showNotification(
        message: errorMessage,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
