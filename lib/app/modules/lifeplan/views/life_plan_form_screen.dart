import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_form_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/time_slots_grid.dart';

class LifePlanFormScreen extends StatelessWidget {
  const LifePlanFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<LifePlanFormController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: colorGreen,
            elevation: 0,
            title: Text(
              controller.isEditMode.value ? 'Modifier le plan' : 'Nouveau plan de vie',
              style: TextStyles.montserratBold(
                textSize: TextSizes.eighteen,
                textColor: colorWhite,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: colorWhite),
              onPressed: () => Get.back(),
            ),
          ),
          body: Column(
            children: [
              // Info du plan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan sélectionné',
                      style: TextStyles.montserratRegular(
                        textSize: TextSizes.twelve,
                        textColor: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.selectedPlan.value?.name?.fr ?? 'Plan personnalisé',
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.sixteen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Liste des créneaux avec TimeSlotsGrid
              Expanded(
                child: Container(
                  color: colorWhite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Créneaux horaires',
                              style: TextStyles.montserratSemiBold(
                                textSize: TextSizes.sixteen,
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.addTimeSlot(),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: colorGreenSemiLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Utilisation de TimeSlotsGrid
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: controller.timeSlots.isEmpty
                              ? SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 48,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aucun créneau ajouté',
                                    style: TextStyles.montserratRegular(
                                      textColor: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Appuyez sur + pour ajouter un créneau',
                                    style: TextStyles.montserratRegular(
                                      textSize: TextSizes.twelve,
                                      textColor: Colors.grey[400]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Touchez un créneau pour le modifier',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.twelve,
                                  textColor: Colors.grey[600]!,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TimeSlotsGrid(
                                slots: controller.timeSlots,
                                showActions: true,
                                onEdit: controller.editTimeSlot,
                                onDelete: controller.removeTimeSlot,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton de validation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorWhite,
                child: ElevatedButton(
                  onPressed: controller.timeSlots.isNotEmpty
                      ? () => controller.savePlan()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGreenSemiLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    controller.isEditMode.value ? 'Modifier' : 'Créer',
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.sixteen,
                      textColor: colorWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
