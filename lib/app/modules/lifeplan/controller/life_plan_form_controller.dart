import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';

class LifePlanFormController extends GetxController {
  final LifePlanController lifePlanController = Get.find<LifePlanController>();

  Rx<LifePlan?> selectedPlan = Rx<LifePlan?>(null);
  Rx<UserLifePlan?> userLifePlan = Rx<UserLifePlan?>(null);
  RxList<TimeSlot> timeSlots = RxList<TimeSlot>([]);
  RxBool isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
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
      lifePlanController.updateLifePlan(userLifePlan.value!, timeSlots);
    } else if (selectedPlan.value != null) {
      lifePlanController.createLifePlan(selectedPlan.value!, timeSlots);
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
}
