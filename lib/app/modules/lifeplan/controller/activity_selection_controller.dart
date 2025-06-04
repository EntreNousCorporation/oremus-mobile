import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class ActivitySelectionController extends GetxController {
  final LifePlanController lifePlanController = Get.find<LifePlanController>();

  // Liste des activités disponibles
  RxList<LifePlan> availableActivities = RxList<LifePlan>([]);

  // Activités sélectionnées par l'utilisateur
  RxList<LifePlan> selectedActivities = RxList<LifePlan>([]);

  // États
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAvailableActivities();
  }

  // Charger les activités disponibles
  void loadAvailableActivities() {
    if (lifePlanController.availableLifePlans.isEmpty &&
        !lifePlanController.isLoadingAvailable.value) {
      // Charger les données si elles ne sont pas disponibles
      lifePlanController.getAvailableLifePlans();

      // Écouter les changements et recharger quand les données arrivent
      ever(lifePlanController.availableLifePlans, (_) {
        _updateAvailableActivities();
      });
    } else {
      _updateAvailableActivities();
    }
  }

  void _updateAvailableActivities() {
    availableActivities.value = lifePlanController.availableLifePlans
        .where((plan) => plan != null)
        .cast<LifePlan>()
        .toList();
  }

  // Vérifier si une activité est déjà utilisée par l'utilisateur
  bool isActivityAlreadyUsed(String activityCode) {
    return lifePlanController.userLifePlans.any((userPlan) =>
    userPlan?.lifePlan?.code?.toLowerCase() == activityCode.toLowerCase()
    );
  }

  // Obtenir le plan utilisateur existant pour une activité
  UserLifePlan? getExistingUserPlan(String activityCode) {
    try {
      return lifePlanController.userLifePlans.firstWhere((userPlan) =>
      userPlan?.lifePlan?.code?.toLowerCase() == activityCode.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  // Toggle de sélection d'une activité
  void toggleActivitySelection(LifePlan activity) {
    final activityCode = activity.code ?? '';

    if (selectedActivities.contains(activity)) {
      // Désélectionner
      selectedActivities.remove(activity);
    } else {
      // Vérifier si l'activité est déjà utilisée
      if (isActivityAlreadyUsed(activityCode)) {
        _showActivityAlreadyUsedDialog(activity);
      } else {
        // Sélectionner
        selectedActivities.add(activity);
      }
    }
  }

  // Dialog pour les activités déjà utilisées
  void _showActivityAlreadyUsedDialog(LifePlan activity) {
    final existingPlan = getExistingUserPlan(activity.code ?? '');

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Activité déjà utilisée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous avez déjà l\'activité "${activity.name?.fr}" avec ${existingPlan?.slots?.length ?? 0} créneaux configurés.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (existingPlan != null) {
                // Modifier l'activité existante
                lifePlanController.goToCreateOrEditPlan(userPlan: existingPlan);
              }
            },
            child: Text(
              'Modifier existante',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Ajouter quand même (permettre les doublons)
              selectedActivities.add(activity);
              Get.snackbar(
                'Activité ajoutée',
                'Vous pouvez créer plusieurs configurations pour la même activité',
                backgroundColor: colorGreenSemiLight,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorGreenSemiLight,
            ),
            child: const Text(
              'Ajouter quand même',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Continuer vers la configuration des créneaux
  void proceedToConfiguration() {
    if (selectedActivities.isEmpty) {
      Get.snackbar(
        'Sélection requise',
        'Veuillez sélectionner au moins une activité',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // ✅ CORRECTION : Utiliser la route définie dans Routes
    Get.toNamed(
      Routes.LIFE_PLAN_FORM,
      arguments: {
        'selectedActivities': selectedActivities.map((a) => a.toJson()).toList(),
      },
    );
  }

  // Sélectionner toutes les activités (sauf celles déjà utilisées)
  void selectAllAvailable() {
    selectedActivities.clear();
    for (final activity in availableActivities) {
      if (!isActivityAlreadyUsed(activity.code ?? '')) {
        selectedActivities.add(activity);
      }
    }
  }

  // Désélectionner toutes les activités
  void deselectAll() {
    selectedActivities.clear();
  }

  // Obtenir le statut d'une activité
  ActivityStatus getActivityStatus(LifePlan activity) {
    final isSelected = selectedActivities.contains(activity);
    final isUsed = isActivityAlreadyUsed(activity.code ?? '');

    if (isSelected && isUsed) return ActivityStatus.selectedAndUsed;
    if (isSelected) return ActivityStatus.selected;
    if (isUsed) return ActivityStatus.used;
    return ActivityStatus.available;
  }

  // Compter les activités par statut
  int get availableCount => availableActivities.where((a) =>
  !isActivityAlreadyUsed(a.code ?? '')).length;

  int get selectedCount => selectedActivities.length;

  int get usedCount => availableActivities.where((a) =>
      isActivityAlreadyUsed(a.code ?? '')).length;
}

enum ActivityStatus {
  available,    // Disponible pour sélection
  selected,     // Sélectionnée par l'utilisateur
  used,         // Déjà utilisée (plan existant)
  selectedAndUsed, // Sélectionnée ET déjà utilisée
}