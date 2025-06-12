import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/multi_activity_form_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/time_slots_grid.dart';

class ActivityConfigurationCard extends StatelessWidget {
  final ActivityConfiguration config;
  final MultiActivityFormController controller;
  final bool canRemove;

  const ActivityConfigurationCard({
    Key? key,
    required this.config,
    required this.controller,
    required this.canRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = config.isExpanded.value;
      final hasSlots = config.timeSlots.isNotEmpty;
      final hasSuggestedSlots = config.activity.slots?.isNotEmpty == true;
      final unusedSuggestedSlots = controller.getUnusedSuggestedSlots(config);
      final allSuggestedSlotsUsed = controller.areAllSuggestedSlotsUsed(config);

      return Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
          border: hasSlots
              ? Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // En-tête de l'activité
            InkWell(
              onTap: () => controller.toggleActivityExpansion(config),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icône de l'activité
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasSlots
                            ? colorGreenSemiLight.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getActivityIcon(config.activity.code ?? ''),
                        color: hasSlots ? colorGreenSemiLight : Colors.grey[600],
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Informations de l'activité
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.activity.name?.fr ?? 'Activité',
                            style: TextStyles.montserratSemiBold(
                              textSize: TextSizes.sixteen,
                              textColor: hasSlots ? colorGreenSemiLight : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasSlots
                                ? '${config.timeSlots.length} créneau${config.timeSlots.length > 1 ? 'x' : ''} configuré${config.timeSlots.length > 1 ? 's' : ''}'
                                : 'Aucun créneau configuré',
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.thirteen,
                              textColor: hasSlots ? colorGreenSemiLight : Colors.grey[600]!,
                            ),
                          ),
                          // Indication sur les créneaux disponibles
                          if (hasSuggestedSlots && unusedSuggestedSlots.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${unusedSuggestedSlots.length} créneau${unusedSuggestedSlots.length > 1 ? 'x' : ''} disponible${unusedSuggestedSlots.length > 1 ? 's' : ''}',
                              style: TextStyles.montserratRegular(
                                textSize: TextSizes.eleven,
                                textColor: Colors.blue[600]!,
                              ),
                            ),
                          ] else if (hasSuggestedSlots && unusedSuggestedSlots.isEmpty && !hasSlots) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Aucun créneau disponible',
                              style: TextStyles.montserratRegular(
                                textSize: TextSizes.eleven,
                                textColor: Colors.grey[500]!,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge de statut
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasSlots
                                ? colorGreenSemiLight.withValues(alpha: 0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasSlots
                                  ? colorGreenSemiLight.withValues(alpha: 0.3)
                                  : Colors.grey[400]!,
                            ),
                          ),
                          child: Text(
                            hasSlots ? 'Configurée' : 'À configurer',
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.ten,
                              textColor: hasSlots ? colorGreenSemiLight : Colors.grey[600]!,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Bouton supprimer
                        if (canRemove)
                          IconButton(
                            onPressed: () => controller.removeActivity(config),
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red[400],
                              size: 20,
                            ),
                          ),

                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Contenu expansible
            if (isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête de la section créneaux
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Créneaux horaires',
                          style: TextStyles.montserratSemiBold(
                            textSize: TextSizes.fifteen,
                          ),
                        ),
                        IconButton(
                          onPressed: () => controller.addTimeSlot(config),
                          icon: Icon(
                            hasSuggestedSlots
                                ? (unusedSuggestedSlots.isNotEmpty ? Icons.schedule : Icons.check_circle)
                                : Icons.add_circle_outline,
                            color: hasSuggestedSlots
                                ? (unusedSuggestedSlots.isNotEmpty ? Colors.blue[600] : Colors.grey[400])
                                : colorGreenSemiLight,
                          ),
                          tooltip: hasSuggestedSlots
                              ? (unusedSuggestedSlots.isNotEmpty
                              ? 'Choisir parmi les créneaux disponibles'
                              : 'Tous les créneaux sont déjà sélectionnés')
                              : 'Ajouter un créneau',
                        ),
                      ],
                    ),

                    // Créneaux suggérés disponibles (si applicable)
                    if (hasSuggestedSlots && unusedSuggestedSlots.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 18,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Créneaux disponibles pour cette activité',
                                  style: TextStyles.montserratSemiBold(
                                    textSize: TextSizes.thirteen,
                                    textColor: Colors.blue[700]!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sélectionnez parmi ces créneaux prédéfinis :',
                              style: TextStyles.montserratRegular(
                                textSize: TextSizes.twelve,
                                textColor: Colors.blue[600]!,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: unusedSuggestedSlots.map((slot) =>
                                  GestureDetector(
                                    onTap: () => controller.addSuggestedTimeSlot(config, slot),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.blue[400]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            slot.getFormattedTime(),
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.twelve,
                                              textColor: Colors.blue[700]!,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.add_circle,
                                            size: 16,
                                            color: Colors.blue[700],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Grille des créneaux configurés
                    if (config.timeSlots.isEmpty) ...[
                      SizedBox(
                        height: 120,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 32,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucun créneau configuré',
                                style: TextStyles.montserratRegular(
                                  textColor: Colors.grey[500]!,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasSuggestedSlots
                                    ? 'Sélectionnez les créneaux ci-dessus'
                                    : 'Appuyez sur + pour ajouter',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.twelve,
                                  textColor: Colors.grey[400]!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      TimeSlotsGrid(
                        slots: config.timeSlots,
                        showActions: true,
                        onEdit: (index) => controller.editTimeSlot(config, index),
                        onDelete: (index) => controller.removeTimeSlot(config, index),
                      ),
                    ],

                    // Information sur le type de créneaux (suggérés vs personnalisés)
                    if (hasSlots && hasSuggestedSlots) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3)),
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
                                'Cette activité utilise uniquement les créneaux prédéfinis.',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.eleven,
                                  textColor: colorGreenSemiLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (hasSlots && !hasSuggestedSlots) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: colorGreenSemiLight,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Créneaux personnalisés configurés.',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.eleven,
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
            ],
          ],
        ),
      );
    });
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
