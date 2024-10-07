import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/button.dart';
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
    filter: ImageFilter.blur(
      sigmaX: 3,
      sigmaY: 3,
    ),
    builder: (cxt) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: colorTransparent,
        child: GetX<MassRequestHistoryDetailController>(builder: (_) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Separators.maximumVertical(),
              Expanded(child: Container()),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 26),
                margin:
                    const EdgeInsets.symmetric(horizontal: 32),
                height: _.getDialogHoursHeight(),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Horaires de messe',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratBold(
                        textSize: 25,
                        textColor: colorBlack,
                      ),
                    ),
                    Separators.normalVertical(),
                    Text(
                      'Vous avez choisi les horaires suivants pour votre demande de messe :',
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
                        itemCount: _.massRequestSelected.value.bookings?.length ?? 0,
                        itemBuilder: (context, index) {
                          var item = _.massRequestSelected.value.bookings?[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Jiffy.parse(item?.day ?? '-', pattern: 'yyyy-MM-dd').format(pattern: 'dd-MM-yyyy'),
                                style: TextStyles.montserratSemiBold(
                                  textColor: colorPurpleLight,
                                  textSize: TextSizes.twenty,
                                ),
                              ),
                              Separators.customSizeVertical(8),
                              Wrap(
                                alignment: WrapAlignment.start,
                                direction: Axis.horizontal,
                                children: item?.slots
                                    ?.map(
                                      (e) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 0.0,
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
                  text: 'Fermer',
                  textSize: TextSizes.twenty_two,
                  textColor: colorWhite,
                  borderRadius: 15,
                  borderColor: colorTransparent,
                  bgcolor: colorGreen,
                  paddingHorizontal: 0,
                  actionColor: colorGreen.withOpacity(0.5),
                  action: () {
                    Get.back();
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
