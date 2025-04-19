import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';

Future recapDialog() {
  return showModal(
    context: Get.context!,
    configuration: const FadeScaleTransitionConfiguration(
      transitionDuration: Duration(milliseconds: 350),
      reverseTransitionDuration: Duration(milliseconds: 100),
      barrierDismissible: false,
    ),
    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
    builder: (cxt) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: GetBuilder<FilterMassRequestDateController>(
          builder: (_) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titre
                  Text(
                    'Récapitulatif',
                    textAlign: TextAlign.center,
                    style: TextStyles.montserratBold(
                      textSize: 24,
                      textColor: colorBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sous-titre
                  Text(
                    'Horaires sélectionnés pour votre demande de messe :',
                    textAlign: TextAlign.center,
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.sixteen,
                      textColor: colorGrey1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Liste des horaires
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Messes récurrentes
                          if (_.datesChoosenForWorshipRecurrentHours.isNotEmpty)
                            _buildMassSection(
                              'Messes récurrentes',
                              _.datesChoosenForWorshipRecurrentHours,
                              isRecurrent: true,
                            ),

                          // Messes spéciales
                          if (_.datesChoosenWorshipSpecialHours.isNotEmpty) ...[
                            if (_.datesChoosenForWorshipRecurrentHours.isNotEmpty)
                              const Divider(height: 32),
                            _buildMassSection(
                              'Messes spéciales',
                              _.datesChoosenWorshipSpecialHours,
                              isRecurrent: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Annuler',
                          style: TextStyles.montserratMedium(
                            textColor: colorGrey1,
                            textSize: TextSizes.sixteen,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _.goBackToMassRequest();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: Text(
                          'Valider',
                          style: TextStyles.montserratBold(
                            textColor: colorWhite,
                            textSize: TextSizes.sixteen,
                          ),
                        ),
                      ),
                    ],
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

Widget _buildMassSection(String title, List<PriceData?> masses, {bool isRecurrent = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // En-tête de section
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isRecurrent ? colorPurpleLight.withValues(alpha: 0.1) : colorGreenSemiLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isRecurrent ? Icons.repeat : Icons.event_note,
              size: 18,
              color: isRecurrent ? colorPurpleLight : colorGreenSemiLight,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyles.montserratSemiBold(
                textColor: isRecurrent ? colorPurpleLight : colorGreenSemiLight,
                textSize: TextSizes.sixteen,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Liste des messes
      ...masses.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jour et répétition
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isRecurrent
                      ? getDay(int.parse(item?.dayOfWeek ?? '0'))
                      : getCustomDate(item?.day ?? '', pattern: AppConstants.TIME_SIMPLE_FORMAT2),
                  style: TextStyles.montserratMedium(
                    textColor: colorBlack,
                    textSize: TextSizes.fourteen,
                  ),
                ),
                if (isRecurrent)
                  Text(
                    'Répétition : ${item?.repeat ?? '-'}',
                    style: TextStyles.montserratRegular(
                      textColor: colorGrey1,
                      textSize: TextSizes.twelve,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Horaires
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item?.slots?.map((slot) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isRecurrent
                          ? colorPurpleLight.withValues(alpha: 0.1)
                          : colorGreenSemiLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isRecurrent ? colorPurpleLight : colorGreenSemiLight,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      slot.startTime ?? '',
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.fourteen,
                        textColor: isRecurrent ? colorPurpleLight : colorGreenSemiLight,
                      ),
                    ),
                  ),
              ).toList() ?? [],
            ),
          ],
        ),
      )).toList(),
    ],
  );
}
