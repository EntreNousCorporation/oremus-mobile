import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/button.dart';
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
    filter: ImageFilter.blur(
      sigmaX: 3,
      sigmaY: 3,
    ),
    builder: (cxt) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: colorTransparent,
        child: GetBuilder<FilterMassRequestDateController>(builder: (_) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Separators.maximumVertical(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Separators.normalHorizontal(),
                        Text(
                          'Fermer',
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen,
                            textColor: colorWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(child: Container()),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 26),
                margin:
                    const EdgeInsets.symmetric(horizontal: 32),
                height: Get.height * 0.65,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Récapitulatif',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratBold(
                        textSize: 25,
                        textColor: colorBlack,
                      ),
                    ),
                    Separators.normalVertical(),
                    Text(
                      'Vous avez choisi les horaires suivantes pour votre demande de messe :',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.eighteen,
                        textColor: colorBlack,
                      ),
                    ),
                    Separators.normalVertical(),
                    Text(
                      'Dates',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratBold(
                        textSize: TextSizes.eighteen,
                        textColor: colorBlack,
                      ),
                    ),
                    Separators.minimunVertical(),
                    Expanded(
                      child: ListView.separated(
                        shrinkWrap: true,
                        //physics: const NeverScrollableScrollPhysics(),
                        itemCount: _.datesChoosenForWorshipRecurrentHours.length,
                        itemBuilder: (context, index) {
                          var item = _.datesChoosenForWorshipRecurrentHours[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    getDay(int.parse(item?.dayOfWeek ?? '')),
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorPurpleLight,
                                      textSize: TextSizes.twenty,
                                    ),
                                  ),
                                  Separators.minimunHorizontal(),
                                  Text(
                                    '(x ${item?.repeat ?? '-'})',
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorPurpleLight,
                                      textSize: TextSizes.twenty,
                                    ),
                                  ),
                                ],
                              ),
                              Separators.normalVertical(),
                              Wrap(
                                alignment: WrapAlignment.start,
                                runSpacing: 15,
                                spacing: 0,
                                direction: Axis.horizontal,
                                children: item?.slots
                                    ?.map(
                                      (e) => Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorGreenSemiLight,
                                              border: Border.all(
                                                  color: colorGreenSemiLight),
                                              borderRadius:
                                              BorderRadius.circular(Get.width / 10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Text(
                                                '${e.startTime}',
                                                textAlign: TextAlign.center,
                                                style: TextStyles.montserratSemiBold(
                                                  textSize: TextSizes.fourteen,
                                                  textColor: colorWhite,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -8,
                                            right: 3,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: colorWhite,
                                                border: Border.all(
                                                    color: colorGreenSemiLight),
                                                borderRadius:
                                                BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: colorGreenSemiLight,
                                                size: 15,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                )
                                    .toList() ??
                                    [],
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Separators.normalVertical();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Separators.normalVertical(),
              Separators.minimunVertical(),
              Separators.minimunVertical(),
              SizedBox(
                width: Get.width * 0.6,
                child: CustomButton(
                  text: 'Valider',
                  textSize: TextSizes.twenty_two,
                  textColor: colorWhite,
                  borderRadius: 15,
                  borderColor: colorTransparent,
                  bgcolor: colorGreen,
                  paddingHorizontal: 0,
                  actionColor: colorGreen.withOpacity(0.5),
                  action: () {
                    Get.back(result: true); //pour fermer le popup de dialog recap
                    _.goBackToMassRequest();
                  },
                ),
              ),
              Expanded(child: Container()),
            ],
          );
        }),
      );
    },
  );
}
