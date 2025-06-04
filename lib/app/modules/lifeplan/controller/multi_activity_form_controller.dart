import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/create_life_plan_request.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/service/calendar_service.dart';

class ActivityConfiguration {
  final LifePlan activity;
  final RxList<TimeSlot> timeSlots;
  final RxBool isExpanded;

  ActivityConfiguration({
    required this.activity,
    List<TimeSlot>? initialSlots,
  }) : timeSlots = RxList<TimeSlot>(initialSlots ?? []),
        isExpanded = RxBool(false);
}

class MultiActivityFormController extends GetxController {
  final LifePlanController lifePlanController = Get.find<LifePlanController>();
  final CalendarService _calendarService = CalendarService();

  // Liste des configurations d'activités
  RxList<ActivityConfiguration> activityConfigurations = RxList<ActivityConfiguration>([]);

  // États globaux
  RxBool isEditMode = false.obs;
  Rx<UserLifePlan?> editingUserPlan = Rx<UserLifePlan?>(null);

  // Options calendrier
  RxBool addToCalendar = true.obs;
  RxBool hasCalendarPermission = false.obs;
  RxBool isCheckingPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _checkCalendarPermission();
    _loadCalendarPreference();
  }

  void _loadArguments() {
    if (Get.arguments != null) {
      if (Get.arguments['userLifePlan'] != null) {
        // Mode édition d'un plan existant
        _loadEditMode();
      } else if (Get.arguments['selectedActivities'] != null) {
        // Mode création avec activités sélectionnées
        _loadCreationMode();
      } else if (Get.arguments['lifePlan'] != null) {
        // Mode création avec une seule activité (ancien workflow)
        _loadSingleActivityMode();
      }
    }
  }

  void _loadEditMode() {
    isEditMode.value = true;
    editingUserPlan.value = UserLifePlan.fromJson(Get.arguments['userLifePlan']);

    if (editingUserPlan.value?.lifePlan != null) {
      final config = ActivityConfiguration(
        activity: editingUserPlan.value!.lifePlan!,
        initialSlots: editingUserPlan.value?.slots ?? [],
      );
      config.isExpanded.value = true; // Ouvert par défaut en mode édition
      activityConfigurations.add(config);
    }
  }

  void _loadCreationMode() {
    isEditMode.value = false;
    final selectedActivitiesJson = Get.arguments['selectedActivities'] as List;

    for (final activityJson in selectedActivitiesJson) {
      final activity = LifePlan.fromJson(activityJson);
      final config = ActivityConfiguration(
        activity: activity,
        initialSlots: activity.slots ?? [], // Utiliser les créneaux suggérés
      );
      activityConfigurations.add(config);
    }

    // Ouvrir la première activité par défaut
    if (activityConfigurations.isNotEmpty) {
      activityConfigurations.first.isExpanded.value = true;
    }
  }

  void _loadSingleActivityMode() {
    isEditMode.value = false;
    final activity = LifePlan.fromJson(Get.arguments['lifePlan']);

    final config = ActivityConfiguration(
      activity: activity,
      initialSlots: activity.slots ?? [],
    );
    config.isExpanded.value = true;
    activityConfigurations.add(config);
  }

  void _loadCalendarPreference() {
    addToCalendar.value = lifePlanController.addToCalendarByDefault.value;
  }

  Future<void> _checkCalendarPermission() async {
    isCheckingPermission.value = true;
    try {
      hasCalendarPermission.value = await _calendarService.requestCalendarPermission();
    } catch (e) {
      hasCalendarPermission.value = false;
    } finally {
      isCheckingPermission.value = false;
    }
  }

  void onCalendarToggleChanged(bool value) {
    if (!hasCalendarPermission.value && value) {
      _requestCalendarPermission();
    } else {
      addToCalendar.value = value;
      lifePlanController.saveCalendarPreference(value);
    }
  }

  Future<void> _requestCalendarPermission() async {
    isCheckingPermission.value = true;

    try {
      final granted = await _calendarService.requestCalendarPermission();
      hasCalendarPermission.value = granted;

      if (granted) {
        addToCalendar.value = true;
        lifePlanController.saveCalendarPreference(true);
        Get.snackbar(
          'Permissions accordées',
          'Vous pouvez maintenant ajouter vos plans au calendrier',
          backgroundColor: colorGreenSemiLight,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        addToCalendar.value = false;
        Get.snackbar(
          'Permissions refusées',
          'Activez les permissions calendrier dans les paramètres',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      hasCalendarPermission.value = false;
      addToCalendar.value = false;
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder au calendrier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isCheckingPermission.value = false;
    }
  }

  // Gestion des créneaux pour une activité spécifique
  void addTimeSlot(ActivityConfiguration config) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: colorGreenSemiLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Vérifier si le créneau existe déjà dans cette activité
      bool exists = config.timeSlots.any((slot) =>
      slot.hour == picked.hour && slot.minute == picked.minute
      );

      if (exists) {
        Get.snackbar(
          'Créneau existant',
          'Ce créneau existe déjà pour ${config.activity.name?.fr}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      config.timeSlots.add(TimeSlot(
        hour: picked.hour,
        minute: picked.minute,
        second: 0,
        nano: 0,
      ));
      _sortTimeSlots(config);
    }
  }

  void editTimeSlot(ActivityConfiguration config, int index) async {
    if (index < 0 || index >= config.timeSlots.length) return;

    final slot = config.timeSlots[index];
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(
        hour: slot.hour ?? 0,
        minute: slot.minute ?? 0,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: colorGreenSemiLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Vérifier si le nouveau créneau existe déjà (sauf lui-même)
      bool exists = config.timeSlots.asMap().entries.any((entry) =>
      entry.key != index &&
          entry.value.hour == picked.hour &&
          entry.value.minute == picked.minute
      );

      if (exists) {
        Get.snackbar(
          'Créneau existant',
          'Ce créneau existe déjà pour ${config.activity.name?.fr}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      config.timeSlots[index] = TimeSlot(
        hour: picked.hour,
        minute: picked.minute,
        second: 0,
        nano: 0,
      );
      _sortTimeSlots(config);
    }
  }

  void removeTimeSlot(ActivityConfiguration config, int index) {
    if (index >= 0 && index < config.timeSlots.length) {
      config.timeSlots.removeAt(index);
    }
  }

  void _sortTimeSlots(ActivityConfiguration config) {
    config.timeSlots.sort((a, b) => a.compareTo(b));
  }

  // Méthode publique pour trier les créneaux
  void sortTimeSlots(ActivityConfiguration config) {
    _sortTimeSlots(config);
  }

  // Toggle expansion d'une activité
  void toggleActivityExpansion(ActivityConfiguration config) {
    config.isExpanded.value = !config.isExpanded.value;
  }

  // Supprimer une activité de la configuration
  void removeActivity(ActivityConfiguration config) {
    if (activityConfigurations.length > 1) {
      activityConfigurations.remove(config);
    } else {
      Get.snackbar(
        'Impossible de supprimer',
        'Vous devez garder au moins une activité',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Validation et sauvegarde
  void saveActivities() async {
    // Validation
    List<ActivityConfiguration> invalidConfigs = activityConfigurations
        .where((config) => config.timeSlots.isEmpty)
        .toList();

    if (invalidConfigs.isNotEmpty) {
      final activities = invalidConfigs.map((c) => c.activity.name?.fr ?? 'Activité').join(', ');
      Get.snackbar(
        'Configuration incomplète',
        'Veuillez ajouter des créneaux pour : $activities',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (isEditMode.value) {
      await _updateUserPlan();
    } else {
      await _createUserPlans();
    }
  }

  Future<void> _updateUserPlan() async {
    if (editingUserPlan.value == null || activityConfigurations.isEmpty) return;

    final config = activityConfigurations.first;
    lifePlanController.updateLifePlan(
      editingUserPlan.value!,
      config.timeSlots,
      updateCalendar: addToCalendar.value && hasCalendarPermission.value,
    );
  }

  Future<void> _createUserPlans() async {
    // Créer un plan pour chaque activité (plusieurs appels API)
    int successCount = 0;
    int totalCount = activityConfigurations.length;
    List<String> errors = [];

    // Afficher le loading global
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: colorGreenSemiLight),
            const SizedBox(height: 16),
            Text(
              'Création de $totalCount activité${totalCount > 1 ? 's' : ''}...',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    for (int i = 0; i < activityConfigurations.length; i++) {
      final config = activityConfigurations[i];
      try {
        // Convertir les TimeSlot en format string attendu par l'API
        List<String> slotsAsStrings = config.timeSlots.map((slot) {
          final h = (slot.hour ?? 0).toString().padLeft(2, '0');
          final m = (slot.minute ?? 0).toString().padLeft(2, '0');
          final s = (slot.second ?? 0).toString().padLeft(2, '0');
          return '$h:$m:$s';
        }).toList();

        var request = CreateLifePlanRequest(
          code: config.activity.code ?? '',
          slots: slotsAsStrings,
        );

        print('Creating plan ${i + 1}/$totalCount: ${config.activity.name?.fr}');

        // Appel API pour créer le plan
        final response = await lifePlanController.lifePlanRepository.createUserLifePlan(request: request);

        // Ajouter à la liste locale immédiatement
        lifePlanController.userLifePlans.insert(0, response);

        // Ajouter au calendrier si demandé
        if (addToCalendar.value && hasCalendarPermission.value) {
          try {
            await _calendarService.addLifePlanToCalendar(response);
          } catch (e) {
            print('Erreur ajout calendrier pour ${config.activity.name?.fr}: $e');
            // Ne pas faire échouer la création pour une erreur de calendrier
          }
        }

        successCount++;
      } catch (e) {
        // Logger l'erreur mais continuer avec les autres
        print('Erreur création ${config.activity.name?.fr}: $e');
        errors.add('${config.activity.name?.fr}: ${e.toString()}');
      }
    }

    // Fermer le dialog de loading
    Get.back();

    // Mettre à jour l'état global
    if (successCount > 0) {
      lifePlanController.hasUserPlans.value = true;
    }

    // Message de résultat
    if (successCount == totalCount) {
      Get.snackbar(
        'Succès ! ✅',
        '$successCount activité${successCount > 1 ? 's' : ''} configurée${successCount > 1 ? 's' : ''} avec succès',
        backgroundColor: colorGreenSemiLight,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } else if (successCount > 0) {
      Get.snackbar(
        'Partiellement réussi ⚠️',
        '$successCount/$totalCount activités créées avec succès',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.warning, color: Colors.white),
      );

      // Afficher les erreurs détaillées
      if (errors.isNotEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          Get.dialog(
            AlertDialog(
              title: const Text('Détails des erreurs'),
              content: SingleChildScrollView(
                child: Text(errors.join('\n\n')),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    } else {
      Get.snackbar(
        'Échec ❌',
        'Aucune activité n\'a pu être créée',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }

    // Retourner à l'écran précédent seulement si au moins une activité créée
    if (successCount > 0) {
      Get.back(); // Retourner à l'écran principal
    }
  }

  // Utilitaires
  String get pageTitle {
    if (isEditMode.value) {
      return 'Modifier ${editingUserPlan.value?.lifePlan?.name?.fr ?? 'l\'activité'}';
    }
    return activityConfigurations.length == 1
        ? 'Configurer ${activityConfigurations.first.activity.name?.fr}'
        : 'Configurer ${activityConfigurations.length} activités';
  }

  bool get canSave {
    return activityConfigurations.isNotEmpty &&
        activityConfigurations.any((config) => config.timeSlots.isNotEmpty);
  }

  String get saveButtonText {
    if (isEditMode.value) {
      return addToCalendar.value && hasCalendarPermission.value
          ? 'Modifier et synchroniser'
          : 'Modifier';
    }

    final count = activityConfigurations.length;
    final base = 'Créer $count activité${count > 1 ? 's' : ''}';

    return addToCalendar.value && hasCalendarPermission.value
        ? '$base et synchroniser'
        : base;
  }

  int get totalSlotsCount {
    return activityConfigurations.fold(0, (sum, config) => sum + config.timeSlots.length);
  }

  int get configuredActivitiesCount {
    return activityConfigurations.where((config) => config.timeSlots.isNotEmpty).length;
  }
}