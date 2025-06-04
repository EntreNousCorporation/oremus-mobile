import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/time_slots_grid.dart';

class LifePlanItem extends StatelessWidget {
  final LifePlan? lifePlan;
  final VoidCallback onSelect;

  const LifePlanItem({
    Key? key,
    required this.lifePlan,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(12),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorGreenSemiLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: colorGreenSemiLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lifePlan?.name?.fr ?? 'Plan de vie',
                        style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.sixteen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lifePlan?.slots?.length ?? 0} créneaux',
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),

            // Affichage des créneaux si disponibles
            if (lifePlan?.slots?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Créneaux suggérés',
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.twelve,
                  textColor: Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 8),
              TimeSlotsGrid(
                slots: lifePlan?.slots ?? [],
                showActions: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
