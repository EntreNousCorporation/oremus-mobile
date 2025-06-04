import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/time_slots_grid.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';


class UserLifePlanItem extends StatelessWidget {
  final UserLifePlan? userLifePlan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserLifePlanItem({
    Key? key,
    required this.userLifePlan,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_available,
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
                      userLifePlan?.lifePlan?.name?.fr ?? 'Plan personnalisé',
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.sixteen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userLifePlan?.slots?.length ?? 0} créneaux actifs',
                      style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen,
                        textColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Modifier',
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Supprimer',
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen,
                            textColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Utilisation de TimeSlotsGrid au lieu du Wrap
          TimeSlotsGrid(
            slots: userLifePlan?.slots ?? [],
            showActions: false,
          ),
        ],
      ),
    );
  }
}
