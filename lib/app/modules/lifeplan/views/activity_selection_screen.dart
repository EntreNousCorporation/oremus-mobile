import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/activity_selection_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/views/widgets/activity_selection_card.dart';

class ActivitySelectionScreen extends StatelessWidget {
  const ActivitySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ActivitySelectionController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: colorGrey5,
          appBar: AppBar(
            backgroundColor: colorGreen,
            elevation: 0,
            title: Text(
              'Choisir vos activités',
              style: TextStyles.montserratBold(
                textSize: TextSizes.eighteen,
                textColor: colorWhite,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: colorWhite),
              onPressed: () => Get.back(),
            ),
            actions: [
              if (controller.selectedCount > 0)
                TextButton(
                  onPressed: controller.deselectAll,
                  child: Text(
                    'Tout désélectionner',
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.twelve,
                      textColor: colorWhite,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // En-tête avec statistiques
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: colorWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélectionnez les activités spirituelles pour votre plan de vie',
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.fifteen,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Statistiques
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatChip(
                            '${controller.selectedCount} sélectionnées',
                            colorGreenSemiLight,
                            Icons.check_circle,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            '${controller.usedCount} déjà configurées',
                            Colors.blue[700]!,
                            Icons.settings,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            '${controller.availableCount} disponibles',
                            Colors.grey[600]!,
                            Icons.add_circle_outline,
                          ),
                        ],
                      ),
                    ),

                    if (controller.selectedCount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorGreenSemiLight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: colorGreenSemiLight,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vous pourrez configurer les créneaux horaires pour chaque activité sélectionnée.',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.twelve,
                                  textColor: colorGreenSemiLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Actions rapides
              if (controller.availableCount > 1) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: colorWhite,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controller.selectAllAvailable,
                          icon: const Icon(
                            Icons.select_all,
                            size: 18,
                            color: colorGreenSemiLight,
                          ),
                          label: Text(
                            'Sélectionner tout',
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.thirteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: colorGreenSemiLight),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Liste des activités
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.availableActivities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = controller.availableActivities[index];
                    final status = controller.getActivityStatus(activity);

                    return ActivitySelectionCard(
                      activity: activity,
                      status: status,
                      onTap: () => controller.toggleActivitySelection(activity),
                    );
                  },
                ),
              ),

              // Bouton de validation
              if (controller.selectedCount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: colorWhite,
                  child: ElevatedButton(
                    onPressed: controller.proceedToConfiguration,
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
                        Text(
                          'Configurer ${controller.selectedCount} activité${controller.selectedCount > 1 ? 's' : ''}',
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen,
                            textColor: colorWhite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: colorWhite,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyles.montserratMedium(
              textSize: TextSizes.eleven,
              textColor: color,
            ),
          ),
        ],
      ),
    );
  }
}
