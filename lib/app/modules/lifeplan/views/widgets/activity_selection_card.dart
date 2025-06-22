import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/activity_selection_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/time_slots_grid.dart';

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

    final hasSuggestedSlots = activity.slots?.isNotEmpty == true;
    final isExtendable = activity.isExtendable ?? false;

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
              ? Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 1)
              : null),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                        ? colorGreenSemiLight.withValues(alpha: 0.1)
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
                                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                                color: colorGreenSemiLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3)),
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
                            : _getActivityDescription(hasSuggestedSlots, isExtendable),
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen,
                          textColor: Colors.grey[600]!,
                        ),
                      ),
                      // Nouvelle ligne pour indiquer le type d'activité
                      if (!isUsed) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getActivityTypeIcon(hasSuggestedSlots, isExtendable),
                              size: 12,
                              color: _getActivityTypeColor(hasSuggestedSlots, isExtendable),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getActivityTypeLabel(hasSuggestedSlots, isExtendable),
                              style: TextStyles.montserratMedium(
                                textSize: TextSizes.eleven,
                                textColor: _getActivityTypeColor(hasSuggestedSlots, isExtendable),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Affichage des créneaux suggérés (si pas utilisée)
            if (!isUsed && hasSuggestedSlots) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Créneaux suggérés',
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.twelve,
                      textColor: Colors.grey[600]!,
                    ),
                  ),
                  if (isExtendable) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorGreenSemiLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorGreenSemiLight.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'modifiables',
                        style: TextStyles.montserratMedium(
                          textSize: TextSizes.ten,
                          textColor: colorGreenSemiLight,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'fixes',
                        style: TextStyles.montserratMedium(
                          textSize: TextSizes.ten,
                          textColor: Colors.orange[600]!,
                        ),
                      ),
                    ),
                  ],
                ],
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
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
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

            // Information sur la flexibilité des créneaux (pour activités non utilisées)
            if (!isUsed && hasSuggestedSlots) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getActivityTypeColor(hasSuggestedSlots, isExtendable).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: _getActivityTypeColor(hasSuggestedSlots, isExtendable).withValues(alpha: 0.3)
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getActivityTypeIcon(hasSuggestedSlots, isExtendable),
                      size: 14,
                      color: _getActivityTypeColor(hasSuggestedSlots, isExtendable),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getFlexibilityDescription(isExtendable),
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.eleven,
                          textColor: _getActivityTypeColor(hasSuggestedSlots, isExtendable),
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

  String _getActivityDescription(bool hasSuggestedSlots, bool isExtendable) {
    if (hasSuggestedSlots) {
      return '${activity.slots?.length ?? 0} créneaux suggérés';
    } else {
      return 'Créneaux personnalisés';
    }
  }

  IconData _getActivityTypeIcon(bool hasSuggestedSlots, bool isExtendable) {
    if (hasSuggestedSlots && !isExtendable) {
      return Icons.lock_outline; // Créneaux prédéfinis uniquement
    } else if (hasSuggestedSlots && isExtendable) {
      return Icons.tune; // Créneaux suggérés + personnalisés
    } else {
      return Icons.edit_outlined; // Créneaux personnalisés
    }
  }

  Color _getActivityTypeColor(bool hasSuggestedSlots, bool isExtendable) {
    if (hasSuggestedSlots && !isExtendable) {
      return Colors.orange[600]!; // Créneaux prédéfinis uniquement
    } else if (hasSuggestedSlots && isExtendable) {
      return colorGreenSemiLight; // Créneaux suggérés + personnalisés
    } else {
      return Colors.blue[600]!; // Créneaux personnalisés
    }
  }

  String _getActivityTypeLabel(bool hasSuggestedSlots, bool isExtendable) {
    if (hasSuggestedSlots && !isExtendable) {
      return 'Créneaux fixes';
    } else if (hasSuggestedSlots && isExtendable) {
      return 'Flexible';
    } else {
      return 'Personnalisable';
    }
  }

  String _getFlexibilityDescription(bool isExtendable) {
    if (isExtendable) {
      return 'Vous pourrez utiliser les créneaux suggérés ou créer les vôtres';
    } else {
      return 'Vous devrez choisir parmi les créneaux proposés uniquement';
    }
  }
}