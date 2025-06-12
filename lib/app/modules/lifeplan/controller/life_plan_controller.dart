import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/create_life_plan_request.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/repository/life_plan_repository.dart';
import 'package:oremusapp/app/modules/lifeplan/service/calendar_service.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
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
    if (isUserConnected.value) {
      loadInitialData();
    }
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
    if (!isUserConnected.value) {
      return;
    }
    getAvailableLifePlans();
    getUserLifePlans();
  }

  // Vérifier l'authentification avant d'accéder aux fonctionnalités
  void checkAndLoadUserPlans() {
    if (!isUserConnected.value) {
      checkIfUserIsConnected('USER_PLANS');
      return;
    }
    getUserLifePlans();
  }

  void checkAndLoadAvailablePlans() {
    if (!isUserConnected.value) {
      checkIfUserIsConnected('AVAILABLE_PLANS');
      return;
    }
    getAvailableLifePlans();
  }

  void checkAndCreatePlan({UserLifePlan? userPlan, LifePlan? lifePlan}) {
    if (!isUserConnected.value) {
      checkIfUserIsConnected('CREATE_PLAN');
      return;
    }
    goToCreateOrEditPlan(userPlan: userPlan, lifePlan: lifePlan);
  }

  checkIfUserIsConnected(String code) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.32,
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Indicateur de dialogue en haut
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              Text(
                'Authentification requise',
                style: TextStyles.montserratBold(
                  textSize: TextSizes.twenty,
                  textColor: colorBlack,
                ),
              ),
              const SizedBox(height: 8),
              // Icône pour renforcer le message
              Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: colorGreen.withValues(alpha: 0.8),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Veuillez vous connecter pour accéder à vos plans de vie',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.sixteen,
                        textColor: Colors.grey[800]!,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Annuler",
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.sixteen,
                            textColor: colorGreen,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorGreen.withValues(alpha: 0.7), width: 1),
                        ),
                      ),
                      onPressed: Get.back,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Se connecter",
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen,
                            textColor: colorWhite,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorGreen,
                        elevation: 2,
                        shadowColor: colorGreen.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 250), () {
                          moveToLogin(code);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      enableDrag: false,
      isDismissible: false,
    );
  }

  moveToLogin(String code) async {
    var result = await Get.toNamed(
      Routes.SIGNIN,
      arguments: true,
    );
    if (result == true) {
      log('back moveToLogin');
      switch (code) {
        case 'USER_PLANS':
          getUserLifePlans();
          break;
        case 'AVAILABLE_PLANS':
          getAvailableLifePlans();
          break;
        case 'CREATE_PLAN':
          goToCreateOrEditPlan();
          break;
      }
    }
  }

  // Récupérer les plans disponibles
  void getAvailableLifePlans() {
    if (!isUserConnected.value) return;

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
    if (!isUserConnected.value) return;

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
    if (!isUserConnected.value) {
      checkIfUserIsConnected('CREATE_PLAN');
      return;
    }

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
      bool calendarSuccess = false;
      if (addToCalendar) {
        calendarSuccess = await _calendarService.addLifePlanToCalendar(response);
        if (calendarSuccess) {
          log('Plan ajouté au calendrier avec succès');
        } else {
          log('Échec ajout au calendrier');
        }
      }

      EasyLoading.dismiss();
      Get.back();

      // Afficher un dialogue de succès complet au lieu d'un simple snackbar
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: colorGreenSemiLight,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Plan créé avec succès ! 🎉',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorGreenSemiLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${lifePlan.name?.fr ?? 'Votre activité'} a été ajoutée à votre plan de vie',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (customSlots.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${customSlots.length} créneau${customSlots.length > 1 ? 'x' : ''} configuré${customSlots.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              if (addToCalendar) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      calendarSuccess ? Icons.calendar_today : Icons.warning,
                      size: 16,
                      color: calendarSuccess ? colorGreenSemiLight : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      calendarSuccess
                          ? 'Rappels ajoutés au calendrier'
                          : 'Erreur ajout calendrier',
                      style: TextStyle(
                        fontSize: 12,
                        color: calendarSuccess ? colorGreenSemiLight : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Parfait !',
                style: TextStyle(
                  color: colorGreenSemiLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Mettre à jour un plan de vie
  void updateLifePlan(UserLifePlan userLifePlan, List<TimeSlot> newSlots, {bool updateCalendar = true}) async {
    if (!isUserConnected.value) {
      checkIfUserIsConnected('CREATE_PLAN');
      return;
    }

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
      bool calendarSuccess = false;
      if (updateCalendar) {
        calendarSuccess = await _calendarService.updateLifePlanInCalendar(response);
        if (calendarSuccess) {
          log('Plan mis à jour dans le calendrier');
        } else {
          log('Échec mise à jour calendrier');
        }
      }

      EasyLoading.dismiss();
      Get.back();

      // Afficher un dialogue de succès pour la modification
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_calendar,
                  color: colorGreenSemiLight,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Modifications enregistrées ! ✏️',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorGreenSemiLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${userLifePlan.lifePlan?.name?.fr ?? 'Votre activité'} a été mise à jour',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              if (newSlots.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${newSlots.length} créneau${newSlots.length > 1 ? 'x' : ''} configuré${newSlots.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              if (updateCalendar) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      calendarSuccess ? Icons.sync : Icons.warning,
                      size: 16,
                      color: calendarSuccess ? colorGreenSemiLight : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      calendarSuccess
                          ? 'Calendrier synchronisé'
                          : 'Erreur synchronisation',
                      style: TextStyle(
                        fontSize: 12,
                        color: calendarSuccess ? colorGreenSemiLight : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Parfait !',
                style: TextStyle(
                  color: colorGreenSemiLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Supprimer un plan de vie
  void deleteLifePlan(UserLifePlan? userLifePlan) async {
    if (!isUserConnected.value) {
      checkIfUserIsConnected('USER_PLANS');
      return;
    }

    if (userLifePlan?.identifier == null) return;

    showCustomDialog(
      Get.context!,
      message: 'Êtes-vous sûr de vouloir supprimer cette activité de votre plan de vie ?\n\nCela supprimera aussi les rappels du calendrier.',
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
      bool calendarSuccess = false;
      if (userLifePlan?.identifier != null) {
        calendarSuccess = await _calendarService.removeLifePlanFromCalendar(
            userLifePlan!.identifier!
        );
        if (calendarSuccess) {
          log('Événements supprimés du calendrier');
        }
      }

      userLifePlans.removeWhere((p) => p?.identifier == userLifePlan?.identifier);
      hasUserPlans.value = userLifePlans.isNotEmpty;

      EasyLoading.dismiss();

      // Message de confirmation amélioré pour la suppression
      Get.snackbar(
        'Activité supprimée 🗑️',
        '${userLifePlan?.lifePlan?.name?.fr ?? 'L\'activité'} et ses rappels ont été supprimés',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.delete_sweep, color: Colors.white),
        animationDuration: const Duration(milliseconds: 300),
      );
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Méthode pour synchroniser un plan existant avec le calendrier
  void syncPlanWithCalendar(UserLifePlan userLifePlan) async {
    if (!isUserConnected.value) {
      checkIfUserIsConnected('USER_PLANS');
      return;
    }

    EasyLoading.show(
      status: 'Synchronisation avec le calendrier...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    );

    try {
      final success = await _calendarService.addLifePlanToCalendar(userLifePlan);
      EasyLoading.dismiss();

      if (success) {
        // Dialogue de succès pour la synchronisation
        Get.dialog(
          AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorGreenSemiLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync,
                    color: colorGreenSemiLight,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Synchronisation réussie ! 📅',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorGreenSemiLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${userLifePlan.lifePlan?.name?.fr ?? 'L\'activité'} a été synchronisée avec votre calendrier',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: colorGreenSemiLight),
                ),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Échec de synchronisation',
          'Vérifiez les permissions calendrier dans les paramètres',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.warning, color: Colors.white),
        );
      }
    } catch (error) {
      EasyLoading.dismiss();
      _handleError(error);
    }
  }

  // Rafraîchir les données
  void onRefresh() {
    if (!isUserConnected.value) {
      refreshController.refreshCompleted();
      return;
    }

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
    if (!isUserConnected.value) {
      checkIfUserIsConnected('CREATE_PLAN');
      return;
    }

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

  // Gestion des erreurs avec option de réauthentification pour 401
  void _handleError(dynamic error) {
    debugPrint("Error type: ${error.runtimeType}");
    debugPrint("Error details: ${error.toString()}");

    if (error is CustomException) {
      if (error.code == 401) {
        // Au lieu de faire un logout direct, proposer de se reconnecter
        checkIfUserIsConnected('USER_PLANS');
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
