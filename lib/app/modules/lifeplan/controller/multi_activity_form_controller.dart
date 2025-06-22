import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
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

  // Vérifier si tous les créneaux suggérés ont été utilisés (pour info seulement)
  bool areAllSuggestedSlotsUsed(ActivityConfiguration config) {
    if (config.activity.slots == null || config.activity.slots!.isEmpty) {
      return true; // Pas de créneaux suggérés, donc tous sont "utilisés"
    }

    for (final suggestedSlot in config.activity.slots!) {
      bool isUsed = config.timeSlots.any((slot) =>
      slot.hour == suggestedSlot.hour && slot.minute == suggestedSlot.minute);
      if (!isUsed) {
        return false;
      }
    }
    return true;
  }

  // Obtenir les créneaux suggérés non utilisés
  List<TimeSlot> getUnusedSuggestedSlots(ActivityConfiguration config) {
    if (config.activity.slots == null || config.activity.slots!.isEmpty) {
      return [];
    }

    return config.activity.slots!.where((suggestedSlot) {
      return !config.timeSlots.any((slot) =>
      slot.hour == suggestedSlot.hour && slot.minute == suggestedSlot.minute);
    }).toList();
  }

  // Gestion des créneaux pour une activité spécifique
  void addTimeSlot(ActivityConfiguration config) async {
    final hasSuggestedSlots = config.activity.slots?.isNotEmpty == true;
    final isExtendable = config.activity.isExtendable ?? false;

    if (hasSuggestedSlots && !isExtendable) {
      // Cas 1: A des créneaux suggérés mais n'est pas extensible
      // -> L'utilisateur ne peut QUE choisir parmi les créneaux suggérés
      final unusedSuggestedSlots = getUnusedSuggestedSlots(config);

      if (unusedSuggestedSlots.isNotEmpty) {
        _showSuggestedSlotsDialog(config, unusedSuggestedSlots);
      } else {
        // Tous les créneaux suggérés sont déjà utilisés
        Get.snackbar(
          'Tous les créneaux utilisés',
          'Tous les créneaux disponibles pour ${config.activity.name?.fr} sont déjà sélectionnés',
          backgroundColor: Colors.blue[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.info, color: Colors.white),
        );
      }
    } else if (hasSuggestedSlots && isExtendable) {
      // Cas 2: A des créneaux suggérés ET est extensible
      // -> L'utilisateur peut choisir parmi les suggérés OU créer un personnalisé
      _showExtendableOptionsDialog(config);
    } else {
      // Cas 3: Pas de créneaux suggérés (peu importe isExtendable)
      // -> L'utilisateur peut créer des créneaux personnalisés
      await _showTimePickerForCustomSlot(config);
    }
  }

  void _showExtendableOptionsDialog(ActivityConfiguration config) {
    final unusedSuggestedSlots = getUnusedSuggestedSlots(config);

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule_outlined, color: colorGreenSemiLight, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ajouter un créneau',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorGreenSemiLight,
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
              'Comment souhaitez-vous ajouter un créneau pour "${config.activity.name?.fr}" ?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Option 1: Créneaux suggérés
            if (unusedSuggestedSlots.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  Get.back();
                  _showSuggestedSlotsDialog(config, unusedSuggestedSlots);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue[50],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Créneaux suggérés',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${unusedSuggestedSlots.length} créneau${unusedSuggestedSlots.length > 1 ? 'x' : ''} disponible${unusedSuggestedSlots.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: unusedSuggestedSlots.take(3).map((slot) =>
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                slot.getFormattedTime(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ).toList(),
                      ),
                      if (unusedSuggestedSlots.length > 3)
                        Text(
                          '   ... et ${unusedSuggestedSlots.length - 3} autre${unusedSuggestedSlots.length - 3 > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Option 2: Créneau personnalisé
            InkWell(
              onTap: () async {
                Get.back();
                await _showTimePickerForCustomSlot(config);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.access_time, color: colorGreenSemiLight, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Créneau personnalisé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorGreenSemiLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Définir un horaire qui vous convient',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Note pour les créneaux suggérés épuisés
            if (unusedSuggestedSlots.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tous les créneaux suggérés sont déjà utilisés',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        ],
      ),
    );
  }

  void _showSuggestedSlotsDialog(ActivityConfiguration config, List<TimeSlot> unusedSlots) {
    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Recalculer les créneaux disponibles à chaque rebuild
          final currentUnusedSlots = getUnusedSuggestedSlots(config);

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.schedule, color: colorGreenSemiLight, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Créneaux disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorGreenSemiLight,
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
                  'Sélectionnez parmi les créneaux disponibles pour "${config.activity.name?.fr}" :',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Vérifier s'il reste des créneaux disponibles
                if (currentUnusedSlots.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 48,
                          color: colorGreenSemiLight,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tous les créneaux ont été ajoutés !',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorGreenSemiLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${config.timeSlots.length} créneau${config.timeSlots.length > 1 ? 'x' : ''} configuré${config.timeSlots.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        // ⚠️ CORRECTION : Utiliser currentUnusedSlots au lieu de unusedSlots
                        children: currentUnusedSlots.map((slot) => GestureDetector(
                          onTap: () {
                            // Ajouter le créneau
                            config.timeSlots.add(slot);
                            _sortTimeSlots(config);

                            // ⚠️ CORRECTION : Mettre à jour l'interface du dialog
                            setState(() {});

                            // Message de confirmation plus court
                            Get.snackbar(
                              'Créneau ajouté ✅',
                              '${slot.getFormattedTime()} ajouté à ${config.activity.name?.fr}',
                              backgroundColor: colorGreenSemiLight,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1), // Plus court
                              icon: const Icon(Icons.access_time, color: Colors.white),
                              animationDuration: const Duration(milliseconds: 300),
                            );

                            // ⚠️ CORRECTION : Si plus de créneaux disponibles, fermer automatiquement
                            Future.delayed(const Duration(milliseconds: 500), () {
                              final remainingSlots = getUnusedSuggestedSlots(config);
                              if (remainingSlots.isEmpty) {
                                Get.back();
                                Get.snackbar(
                                  'Configuration terminée 🎉',
                                  'Tous les créneaux suggérés ont été ajoutés !',
                                  backgroundColor: colorGreenSemiLight,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                  icon: const Icon(Icons.celebration, color: Colors.white),
                                );
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: colorGreenSemiLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colorGreenSemiLight),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  slot.getFormattedTime(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorGreenSemiLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.add_circle,
                                  size: 18,
                                  color: colorGreenSemiLight,
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            config.activity.isExtendable == true
                                ? 'Vous pouvez aussi créer des créneaux personnalisés pour cette activité.'
                                : 'Cette activité utilise uniquement les créneaux prédéfinis.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  currentUnusedSlots.isEmpty ? 'Parfait !' : 'Fermer',
                  style: TextStyle(
                    color: currentUnusedSlots.isEmpty ? colorGreenSemiLight : Colors.grey[600],
                    fontWeight: currentUnusedSlots.isEmpty ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              // Bouton pour créneau personnalisé (si activité extensible)
              if (currentUnusedSlots.isNotEmpty && config.activity.isExtendable == true)
                TextButton(
                  onPressed: () async {
                    Get.back();
                    await _showTimePickerForCustomSlot(config);
                  },
                  child: const Text(
                    'Créneau personnalisé',
                    style: TextStyle(color: colorGreenSemiLight),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showTimePickerForCustomSlot(ActivityConfiguration config) async {
    TimeOfDay? picked = await showCupertinoDialog<TimeOfDay>(
      context: Get.context!,
      builder: (BuildContext context) {
        DateTime selectedTime = DateTime.now();
        return CupertinoAlertDialog(
          title: Text('Ajouter un créneau pour ${config.activity.name?.fr}'),
          content: SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: selectedTime,
              onDateTimeChanged: (DateTime dateTime) {
                selectedTime = dateTime;
              },
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Returns null
              },
            ),
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(
                  TimeOfDay.fromDateTime(selectedTime),
                );
              },
            ),
          ],
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

      // Message de confirmation amélioré
      Get.snackbar(
        'Créneau ajouté ✅',
        '${picked.format(Get.context!)} ajouté à ${config.activity.name?.fr}',
        backgroundColor: colorGreenSemiLight,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.schedule, color: Colors.white),
        animationDuration: const Duration(milliseconds: 300),
      );
    }
  }

  String getActivityTypeDescription(ActivityConfiguration config) {
    final hasSuggestedSlots = config.activity.slots?.isNotEmpty == true;
    final isExtendable = config.activity.isExtendable ?? false;

    if (hasSuggestedSlots && !isExtendable) {
      return 'Créneaux prédéfinis uniquement';
    } else if (hasSuggestedSlots && isExtendable) {
      return 'Créneaux suggérés + personnalisés';
    } else {
      return 'Créneaux personnalisés';
    }
  }

  // Méthode pour vérifier si on peut ajouter des créneaux personnalisés
  bool canAddCustomSlots(ActivityConfiguration config) {
    final hasSuggestedSlots = config.activity.slots?.isNotEmpty == true;
    final isExtendable = config.activity.isExtendable ?? false;

    return !hasSuggestedSlots || isExtendable;
  }

  // Méthode pour vérifier si on peut ajouter des créneaux suggérés
  bool canAddSuggestedSlots(ActivityConfiguration config) {
    final hasSuggestedSlots = config.activity.slots?.isNotEmpty == true;
    final unusedSuggestedSlots = getUnusedSuggestedSlots(config);

    return hasSuggestedSlots && unusedSuggestedSlots.isNotEmpty;
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

      // Message de confirmation
      Get.snackbar(
        'Créneau modifié ✅',
        'Nouveau horaire : ${picked.format(Get.context!)}',
        backgroundColor: colorGreenSemiLight,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.edit, color: Colors.white),
      );
    }
  }

  void removeTimeSlot(ActivityConfiguration config, int index) {
    if (index >= 0 && index < config.timeSlots.length) {
      final removedSlot = config.timeSlots[index];
      config.timeSlots.removeAt(index);

      // Message de confirmation
      Get.snackbar(
        'Créneau supprimé 🗑️',
        '${removedSlot.getFormattedTime()} retiré de ${config.activity.name?.fr}',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.delete, color: Colors.white),
      );
    }
  }

  // Ajouter un créneau suggéré spécifique
  void addSuggestedTimeSlot(ActivityConfiguration config, TimeSlot slot) {
    // Vérifier si le créneau existe déjà
    bool exists = config.timeSlots.any((existingSlot) =>
    existingSlot.hour == slot.hour && existingSlot.minute == slot.minute);

    if (!exists) {
      config.timeSlots.add(slot);
      _sortTimeSlots(config);

      // Message de confirmation avec animation
      Get.snackbar(
        'Créneau ajouté ✅',
        '${slot.getFormattedTime()} ajouté à ${config.activity.name?.fr}',
        backgroundColor: colorGreenSemiLight,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.schedule_outlined, color: Colors.white),
        animationDuration: const Duration(milliseconds: 300),
      );
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

      // Message de confirmation
      Get.snackbar(
        'Activité supprimée',
        '${config.activity.name?.fr} retirée de la configuration',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.remove_circle, color: Colors.white),
      );
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

    // Appeler la méthode de mise à jour
    lifePlanController.updateLifePlan(
      editingUserPlan.value!,
      config.timeSlots,
      updateCalendar: addToCalendar.value && hasCalendarPermission.value,
    );

    // Attendre que le dialog de succès du LifePlanController se ferme
    // puis naviguer vers l'écran Plan de vie
    Future.delayed(const Duration(milliseconds: 2000), () {
      _returnToLifePlanScreen();
    });
  }

  Future<void> _createUserPlans() async {
    // Créer un plan pour chaque activité (plusieurs appels API)
    int successCount = 0;
    int totalCount = activityConfigurations.length;
    List<String> errors = [];

    // Afficher le loading
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: colorGreenSemiLight),
            const SizedBox(height: 16),
            Text(
              'Création de $totalCount activité${totalCount > 1 ? 's' : ''}...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Configuration des créneaux et synchronisation',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (addToCalendar.value && hasCalendarPermission.value) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Ajout au calendrier inclus',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // Créer chaque activité
    for (int i = 0; i < activityConfigurations.length; i++) {
      final config = activityConfigurations[i];
      try {
        // Convertir les TimeSlot en format string
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

        // Appel API
        final response = await lifePlanController.lifePlanRepository.createUserLifePlan(request: request);

        // Ajouter à la liste locale
        lifePlanController.userLifePlans.insert(0, response);

        // Ajouter au calendrier si demandé
        if (addToCalendar.value && hasCalendarPermission.value) {
          try {
            await _calendarService.addLifePlanToCalendar(response);
          } catch (e) {
            print('Erreur ajout calendrier pour ${config.activity.name?.fr}: $e');
          }
        }

        successCount++;
      } catch (e) {
        print('Erreur création ${config.activity.name?.fr}: $e');
        errors.add('${config.activity.name?.fr}: ${e.toString()}');
      }
    }

    // Fermer le loading
    Get.back();

    // Mettre à jour l'état global
    if (successCount > 0) {
      lifePlanController.hasUserPlans.value = true;
    }

    // Afficher le résultat et naviguer
    if (successCount == totalCount) {
      // Succès complet
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: colorGreenSemiLight,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Succès ! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorGreenSemiLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$successCount activité${successCount > 1 ? 's' : ''} configurée${successCount > 1 ? 's' : ''} avec succès',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              if (addToCalendar.value && hasCalendarPermission.value) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: colorGreenSemiLight),
                    const SizedBox(width: 4),
                    Text(
                      'Rappels ajoutés au calendrier',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Fermer le dialogue
                _returnToLifePlanScreen(); // Retourner à l'écran Plan de vie
              },
              child: const Text(
                'Voir mes activités',
                style: TextStyle(
                  color: colorGreenSemiLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else if (successCount > 0) {
      // Succès partiel
      Get.snackbar(
        'Partiellement réussi ⚠️',
        '$successCount/$totalCount activités créées avec succès',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning, color: Colors.white),
      );

      // Retourner après un délai
      Future.delayed(const Duration(seconds: 2), () {
        _returnToLifePlanScreen();
      });
    } else {
      // Échec complet
      Get.snackbar(
        'Échec ❌',
        'Aucune activité n\'a pu être créée',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _returnToLifePlanScreen() {
    print('isEditMode ::: ${isEditMode.value}');
    if (isEditMode.value) {
      Get.back();
    } else {
      Get.back();
      Get.back();
    }

    // S'assurer que l'onglet "Mon plan de vie" est sélectionné
    lifePlanController.selectedTab.value = 0;

    // Rafraîchir les données utilisateur
    lifePlanController.getUserLifePlans();
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
