import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
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
    final controller = Get.find<LifePlanController>();

    return Container(
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
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'sync_calendar':
                      if (userLifePlan != null) {
                        controller.syncPlanWithCalendar(userLifePlan!);
                      }
                      break;
                    case 'delete':
                      onDelete();
                      break;
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
                    value: 'sync_calendar',
                    child: Row(
                      children: [
                        const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: colorGreenSemiLight
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Synchroniser calendrier',
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen,
                            textColor: colorGreenSemiLight,
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

          // Indication calendrier si activé
          if (controller.addToCalendarByDefault.value) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorGreenSemiLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorGreenSemiLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.event_note,
                    size: 14,
                    color: colorGreenSemiLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Rappels actifs',
                    style: TextStyles.montserratRegular(
                      textSize: TextSizes.twelve,
                      textColor: colorGreenSemiLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}