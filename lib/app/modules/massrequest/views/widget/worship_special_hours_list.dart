import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

class WorshipSpecialHoursList extends StatelessWidget {
  const WorshipSpecialHoursList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestDateController>(
      builder: (_) {
        if (_.worshipSpecialHours.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 48,
                  color: colorGrey1.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune messe spéciale disponible\npour le moment',
                  textAlign: TextAlign.center,
                  style: TextStyles.montserratRegular(
                    textColor: colorGrey1,
                    textSize: TextSizes.fourteen,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _.worshipSpecialHours.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final specialMass = _.worshipSpecialHours[index];
            return Container(
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: colorGreenSemiLight,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_note,
                          color: colorWhite,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                specialMass.name ?? 'Messe spéciale',
                                style: TextStyles.montserratBold(
                                  textColor: colorWhite,
                                  textSize: TextSizes.fourteen,
                                ),
                              ),
                              Text(
                                getCustomDate(specialMass.day, pattern: AppConstants.TIME_SIMPLE_FORMAT2),
                                style: TextStyles.montserratRegular(
                                  textColor: colorWhite.withOpacity(0.9),
                                  textSize: TextSizes.twelve,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Liste des horaires
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horaires disponibles',
                          style: TextStyles.montserratMedium(
                            textColor: colorGrey1,
                            textSize: TextSizes.twelve,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: specialMass.slots?.map((slot) {
                            return FilterChip(
                              selected: _.isSlotSelected(
                                  specialMass.day ?? '',
                                  slot.startTime ?? '',
                                  isSpecial: true
                              ),
                              onSelected: (selected) {
                                _.toggleSlotSelection(
                                    specialMass.day ?? '',
                                    slot.startTime ?? '',
                                    isSpecial: true
                                );
                              },
                              label: Text(slot.startTime ?? ''),
                              backgroundColor: colorWhite,
                              selectedColor: colorGreenSemiLight.withOpacity(0.2),
                              checkmarkColor: colorGreenSemiLight,
                              labelStyle: TextStyles.montserratSemiBold(
                                textSize: TextSizes.fourteen,
                                textColor: _.isSlotSelected(
                                  specialMass.dayOfWeek ?? '0',
                                  slot.startTime ?? '',
                                )
                                    ? colorGreenSemiLight
                                    : colorBlack,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: _.isSlotSelected(
                                    specialMass.dayOfWeek ?? '0',
                                    slot.startTime ?? '',
                                  )
                                      ? colorGreenSemiLight
                                      : colorGrey1.withOpacity(0.3),
                                ),
                              ),
                            );
                          }).toList() ??
                              [],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
