import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/activity_selection_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/time_slots_grid.dart';

class ActivitySelectionScreen extends StatelessWidget {
  const ActivitySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ActivitySelectionController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
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
                          color: colorGreenSemiLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorGreenSemiLight.withOpacity(0.3),
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
                          icon: Icon(
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
                            side: BorderSide(color: colorGreenSemiLight),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
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

class ActivitySelectionCard extends StatelessWidget {
  final LifePlan activity;
  final ActivityStatus status;
  final VoidCallback onTap;

  const ActivitySelectionCard({
    Key? key,
    required this.activity,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = status == ActivityStatus.selected ||
        status == ActivityStatus.selectedAndUsed;
    final isUsed = status == ActivityStatus.used ||
        status == ActivityStatus.selectedAndUsed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorGreenSemiLight, width: 2)
              : (isUsed
              ? Border.all(color: Colors.blue.withOpacity(0.5), width: 1)
              : null),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox/indicateur de statut
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorGreenSemiLight
                        : (isUsed ? Colors.blue[100] : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? colorGreenSemiLight
                          : (isUsed ? Colors.blue[300]! : Colors.grey[400]!),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : (isUsed
                      ? Icon(Icons.settings, color: Colors.blue[700], size: 14)
                      : null),
                ),

                const SizedBox(width: 16),

                // Icône de l'activité
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorGreenSemiLight.withOpacity(0.1)
                        : (isUsed
                        ? Colors.blue[50]
                        : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getActivityIcon(activity.code ?? ''),
                    color: isSelected
                        ? colorGreenSemiLight
                        : (isUsed ? Colors.blue[700] : Colors.grey[600]),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Informations de l'activité
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.name?.fr ?? 'Activité',
                              style: TextStyles.montserratSemiBold(
                                textSize: TextSizes.sixteen,
                                textColor: isSelected
                                    ? colorGreenSemiLight
                                    : (isUsed ? Colors.blue[700]! : Colors.black),
                              ),
                            ),
                          ),

                          // Badge de statut
                          if (isUsed && !isSelected) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Configurée',
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.ten,
                                  textColor: Colors.blue[700]!,
                                ),
                              ),
                            ),
                          ] else if (isSelected) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorGreenSemiLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorGreenSemiLight.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Sélectionnée',
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.ten,
                                  textColor: colorGreenSemiLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isUsed
                            ? 'Déjà configurée avec créneaux personnalisés'
                            : '${activity.slots?.length ?? 0} créneaux suggérés',
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen,
                          textColor: Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Affichage des créneaux suggérés (si pas utilisée)
            if (!isUsed && activity.slots?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Créneaux suggérés (modifiables)',
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.twelve,
                  textColor: Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 8),
              TimeSlotsGrid(
                slots: activity.slots ?? [],
                showActions: false,
              ),
            ],

            // Indication pour les activités déjà utilisées
            if (isUsed) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSelected
                            ? 'Vous allez créer une nouvelle configuration pour cette activité'
                            : 'Touchez pour modifier la configuration existante ou créer une nouvelle',
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.twelve,
                          textColor: Colors.blue[700]!,
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
    );
  }

  IconData _getActivityIcon(String code) {
    switch (code.toUpperCase()) {
      case 'ANGELUS':
        return Icons.church;
      case 'MEDITATION':
        return Icons.self_improvement;
      case 'ROSARY':
        return Icons.circle;
      case 'SPIRITUAL_READING':
        return Icons.menu_book;
      case 'MASS':
        return Icons.celebration;
      default:
        return Icons.star;
    }
  }
}