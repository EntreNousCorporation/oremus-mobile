import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_detail_controller.dart';

Future historyMassDateDialog() {
  return showModal(
    context: Get.context!,
    configuration: const FadeScaleTransitionConfiguration(
      transitionDuration: Duration(milliseconds: 350),
      reverseTransitionDuration: Duration(milliseconds: 100),
      barrierDismissible: false,
    ),
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    builder: (cxt) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 10,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: GetX<MassRequestHistoryDetailController>(
          builder: (controller) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
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
                              'Horaires de messe',
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.twenty,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Détails de votre demande',
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

                  const SizedBox(height: 24),

                  // Divider with gradient
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[300]!,
                          colorGreenSemiLight.withValues(alpha: 0.5),
                          Colors.grey[300]!,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Explanation text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorGreenSemiLight.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorGreenSemiLight.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: colorGreenSemiLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vous avez choisi les horaires suivants pour votre demande de messe :',
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.fourteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // List of mass times
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.massRequestSelected.value.bookings?.length ?? 0,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var item = controller.massRequestSelected.value.bookings?[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date with calendar icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorGreenSemiLight.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: colorGreenSemiLight,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    Jiffy.parse(item?.day ?? '-', pattern: 'yyyy-MM-dd').format(pattern: 'dd-MM-yyyy'),
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorGreenSemiLight,
                                      textSize: TextSizes.sixteen,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Time slots with improved design
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: item?.slots?.map((e) =>
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: colorGreenSemiLight.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: colorGreenSemiLight.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            color: colorGreenSemiLight,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${e.startTime}',
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.fourteen,
                                              textColor: colorGreenSemiLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ).toList() ?? [],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Close button with improved design
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorGreenSemiLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Fermer',
                            style: TextStyles.montserratBold(
                              textColor: colorWhite,
                              textSize: TextSizes.sixteen,
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
        ),
      );
    },
  );
}