import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/multi_activity_form_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/views/activity_configuration_card.dart';

class MultiActivityFormScreen extends StatelessWidget {
  const MultiActivityFormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<MultiActivityFormController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: colorGreen,
            elevation: 0,
            title: Text(
              controller.pageTitle,
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
              // Résumé global
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isEditMode.value
                                    ? 'Modification d\'activité'
                                    : 'Configuration des activités',
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.twelve,
                                  textColor: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.activityConfigurations.length} activité${controller.activityConfigurations.length > 1 ? 's' : ''} • ${controller.totalSlotsCount} créneaux',
                                style: TextStyles.montserratSemiBold(
                                  textSize: TextSizes.sixteen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorGreenSemiLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${controller.configuredActivitiesCount}/${controller.activityConfigurations.length} configurées',
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.eleven,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Option calendrier
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                color: colorWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: colorGreenSemiLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Calendrier',
                          style: TextStyles.montserratSemiBold(
                            textSize: TextSizes.fourteen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajouter les rappels au calendrier',
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.fourteen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.hasCalendarPermission.value
                                    ? 'Créer des rappels quotidiens pour tous les créneaux'
                                    : 'Permissions calendrier requises',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.twelve,
                                  textColor: controller.hasCalendarPermission.value
                                      ? Colors.grey[600]!
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (controller.isCheckingPermission.value)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colorGreenSemiLight),
                            ),
                          )
                        else
                          Switch(
                            value: controller.addToCalendar.value,
                            onChanged: controller.onCalendarToggleChanged,
                            activeColor: colorGreenSemiLight,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Liste des activités à configurer
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.activityConfigurations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final config = controller.activityConfigurations[index];
                    return ActivityConfigurationCard(
                      config: config,
                      controller: controller,
                      canRemove: controller.activityConfigurations.length > 1,
                    );
                  },
                ),
              ),

              // Bouton de validation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorWhite,
                child: ElevatedButton(
                  onPressed: controller.canSave
                      ? () => controller.saveActivities()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGreenSemiLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.addToCalendar.value && controller.hasCalendarPermission.value) ...[
                        const Icon(
                          Icons.calendar_today,
                          color: colorWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        controller.saveButtonText,
                        style: TextStyles.montserratBold(
                          textSize: TextSizes.sixteen,
                          textColor: colorWhite,
                        ),
                      ),
                    ],
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
