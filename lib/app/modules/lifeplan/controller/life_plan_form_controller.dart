import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/service/calendar_service.dart';

class LifePlanFormController extends GetxController {
  final LifePlanController lifePlanController = Get.find<LifePlanController>();
  final CalendarService _calendarService = CalendarService();

  Rx<LifePlan?> selectedPlan = Rx<LifePlan?>(null);
  Rx<UserLifePlan?> userLifePlan = Rx<UserLifePlan?>(null);
  RxList<TimeSlot> timeSlots = RxList<TimeSlot>([]);
  RxBool isEditMode = false.obs;

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
        // Mode édition
        userLifePlan.value = UserLifePlan.fromJson(Get.arguments['userLifePlan']);
        selectedPlan.value = userLifePlan.value?.lifePlan;
        timeSlots.value = List.from(userLifePlan.value?.slots ?? []);
        isEditMode.value = true;
      } else if (Get.arguments['lifePlan'] != null) {
        // Mode création avec plan présélectionné
        selectedPlan.value = LifePlan.fromJson(Get.arguments['lifePlan']);
        timeSlots.value = List.from(selectedPlan.value?.slots ?? []);
        isEditMode.value = false;
      }
      // Trier les créneaux
      _sortTimeSlots();
    }
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
      // Demander les permissions
      _requestCalendarPermission();
    } else {
      addToCalendar.value = value;
      // Sauvegarder la préférence
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
          'Activez les permissions calendrier dans les paramètres pour utiliser cette fonctionnalité',
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

  void addTimeSlot() async {
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
      // Vérifier si le créneau existe déjà
      bool exists = timeSlots.any((slot) =>
      slot.hour == picked.hour && slot.minute == picked.minute
      );

      if (exists) {
        Get.snackbar(
          'Attention',
          'Ce créneau horaire existe déjà',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      timeSlots.add(TimeSlot(
        hour: picked.hour,
        minute: picked.minute,
        second: 0,
        nano: 0,
      ));
      _sortTimeSlots();
    }
  }

  void editTimeSlot(int index) async {
    if (index < 0 || index >= timeSlots.length) return;

    final slot = timeSlots[index];
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
      bool exists = timeSlots.asMap().entries.any((entry) =>
      entry.key != index &&
          entry.value.hour == picked.hour &&
          entry.value.minute == picked.minute
      );

      if (exists) {
        Get.snackbar(
          'Attention',
          'Ce créneau horaire existe déjà',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      timeSlots[index] = TimeSlot(
        hour: picked.hour,
        minute: picked.minute,
        second: 0,
        nano: 0,
      );
      _sortTimeSlots();
    }
  }

  void removeTimeSlot(int index) {
    if (index >= 0 && index < timeSlots.length) {
      timeSlots.removeAt(index);
    }
  }

  void _sortTimeSlots() {
    timeSlots.sort((a, b) => a.compareTo(b));
  }

  void savePlan() {
    // Validation basique
    if (timeSlots.isEmpty) {
      Get.snackbar(
        'Attention',
        'Veuillez ajouter au moins un créneau horaire',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (isEditMode.value && userLifePlan.value != null) {
      lifePlanController.updateLifePlan(
        userLifePlan.value!,
        timeSlots,
        updateCalendar: addToCalendar.value && hasCalendarPermission.value,
      );
    } else if (selectedPlan.value != null) {
      lifePlanController.createLifePlan(
        selectedPlan.value!,
        timeSlots,
        addToCalendar: addToCalendar.value && hasCalendarPermission.value,
      );
    } else {
      Get.snackbar(
        'Erreur',
        'Aucun plan sélectionné',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Méthode utilitaire pour obtenir le titre de la page
  String get pageTitle {
    if (isEditMode.value) {
      return 'Modifier le plan';
    }
    return 'Nouveau plan de vie';
  }

  // Méthode utilitaire pour obtenir le nom du plan
  String get planName {
    return selectedPlan.value?.name?.fr ?? 'Plan personnalisé';
  }

  // Méthode utilitaire pour vérifier si on peut sauvegarder
  bool get canSave {
    return timeSlots.isNotEmpty && selectedPlan.value != null;
  }

  // Méthode utilitaire pour le texte du bouton sauvegarder
  String get saveButtonText {
    if (isEditMode.value) {
      return addToCalendar.value && hasCalendarPermission.value
          ? 'Modifier et synchroniser'
          : 'Modifier';
    }
    return addToCalendar.value && hasCalendarPermission.value
        ? 'Créer et ajouter au calendrier'
        : 'Créer';
  }
}