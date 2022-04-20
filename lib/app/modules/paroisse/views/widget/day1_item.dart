import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu_detail_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';

class Day1Item extends StatelessWidget {
  Day1Item({Key? key, required this.openingTime}) : super(key: key);

  OpeningTime? openingTime;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseMenuDetailController>(builder: (logic) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 40, top: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: Get.width * 0.1),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getDay(openingTime?.dayOfWeek),
                        textAlign:
                        TextAlign.start,
                        style: TextStyles
                            .montserratSemiBold(
                            textSize:
                            TextSizes
                                .sixteen,
                            textColor: getCurrentDay() == getDay(openingTime?.dayOfWeek) ? colorGreenSemiLight : colorBlack),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: openingTime?.slots?.map((timeSlot) {
                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${logic.getTime(timeSlot.startTime ?? '')}',
                                  style: TextStyles.montserratSemiBold(textSize: TextSizes.fourteen, textColor: getCurrentDay() == getDay(openingTime?.dayOfWeek) ? colorGreenSemiLight.withOpacity(0.5) : colorGrey1),
                                ),
                              ),
                            ],
                          );
                        }).toList() ?? [],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 17.5,
            child: Container(
              height: Get.height * 0.7,
              width: 5.0,
              color: colorBlack.withOpacity(0.5),
            ),
          ),
          Positioned(
            bottom: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 50, top: 10, right: 0),
              child: Container(
                height: 20.0,
                width: 20.0,
                decoration: BoxDecoration(
                  color: getCurrentDay() == getDay(openingTime?.dayOfWeek) ? colorGreenSemiLight : colorBlack,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: getCurrentDay() == getDay(openingTime?.dayOfWeek) ? const Icon(Icons.check, size: 15, color: colorWhite,) : Container(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
