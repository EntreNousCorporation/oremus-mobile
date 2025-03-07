import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_detail_controller.dart';

Future historyMassDateDialog() {
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
        child: GetX<DonationHistoryDetailController>(
          builder: (_) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titre
                  Text(
                    'Horaires de messe',
                    textAlign: TextAlign.center,
                    style: TextStyles.montserratBold(
                      textSize: 24,
                      textColor: colorBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sous-titre explicatif
                  Text(
                    'Vous avez choisi les horaires suivants pour votre demande de messe :',
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
                      itemCount: _.donationSelected.value.bookings?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = _.donationSelected.value.bookings?[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date
                              Text(
                                Jiffy.parse(item?.day ?? '-', pattern: 'yyyy-MM-dd').format(pattern: 'dd-MM-yyyy'),
                                style: TextStyles.montserratSemiBold(
                                  textColor: colorPurpleLight,
                                  textSize: TextSizes.eighteen,
                                ),
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
                                ).toList() ??
                                    [],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton Fermer
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      ),
                      child: Text(
                        'Fermer',
                        style: TextStyles.montserratBold(
                          textColor: colorWhite,
                          textSize: TextSizes.sixteen,
                        ),
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
