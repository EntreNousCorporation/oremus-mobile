import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';

class BackgroundOperationsIndicator extends StatelessWidget {
  final LifePlanController controller;

  const BackgroundOperationsIndicator({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final operationsCount = controller.backgroundOperations.length;

      if (operationsCount == 0) {
        return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Synchronisation calendrier en cours ($operationsCount)',
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.twelve,
                  textColor: Colors.blue,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showBackgroundOperationsDialog(controller),
              child: const Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      );
    });
  }

  // Dialogue de détails des opérations
  void _showBackgroundOperationsDialog(LifePlanController controller) {
    final operations = controller.backgroundOperations;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorGreenSemiLight),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Synchronisation en cours',
              style: TextStyles.montserratBold(
                textSize: TextSizes.sixteen,
                textColor: colorBlack,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${operations.length} opération(s) calendrier en cours :',
              style: TextStyles.montserratMedium(
                textSize: TextSizes.fourteen,
                textColor: Colors.grey[700]!,
              ),
            ),
            const SizedBox(height: 12),
            ...operations.entries.map((entry) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorGreenSemiLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Plan ${entry.key} - ${entry.value}',
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen,
                            textColor: colorBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ).toList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ces opérations se déroulent en arrière-plan et n\'affectent pas l\'utilisation de l\'app.',
                      style: TextStyles.montserratRegular(
                        textSize: TextSizes.twelve,
                        textColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: TextStyles.montserratBold(
                textSize: TextSizes.fourteen,
                textColor: colorGreenSemiLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
