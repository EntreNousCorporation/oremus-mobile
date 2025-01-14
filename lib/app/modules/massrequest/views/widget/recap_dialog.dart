import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

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

                  // Sous-titre explicatif
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
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _.datesChoosenForWorshipRecurrentHours.length,
                      itemBuilder: (context, index) {
                        var item = _.datesChoosenForWorshipRecurrentHours[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Jour et répétition
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getDay(int.parse(item?.dayOfWeek ?? '')),
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorPurpleLight,
                                      textSize: TextSizes.eighteen,
                                    ),
                                  ),
                                  Text(
                                    'Répétition : ${item?.repeat ?? '-'}',
                                    style: TextStyles.montserratMedium(
                                      textColor: colorGrey1,
                                      textSize: TextSizes.fourteen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Horaires
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: item?.slots?.map((e) =>
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: colorGreenSemiLight.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: colorGreenSemiLight, width: 1),
                                      ),
                                      child: Text(
                                        '${e.startTime}',
                                        style: TextStyles.montserratMedium(
                                          textSize: TextSizes.fourteen,
                                          textColor: colorGreenSemiLight,
                                        ),
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

                  const SizedBox(height: 20),

                  // Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Annuler
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

                      // Bouton Valider
                      ElevatedButton(
                        onPressed: () {
                          Get.back(); // Fermer le popup
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
