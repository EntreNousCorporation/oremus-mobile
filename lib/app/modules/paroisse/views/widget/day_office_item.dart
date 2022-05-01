import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_menu_detail_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_office_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';

class DayOfficeItem extends StatelessWidget {
  DayOfficeItem({Key? key, required this.openingTime}) : super(key: key);

  OpeningTime? openingTime;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseOfficeController>(builder: (logic) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 20, top: 20, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: Get.width * 0.1),
                Expanded(
                  child: SizedBox(
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: openingTime?.slots?.map((timeSlot) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '${logic.getTime(timeSlot.startTime ?? '')}',
                                style: TextStyles.montserratSemiBold(textSize: TextSizes.fourteen, textColor: getCurrentDay() == getDay(openingTime?.dayOfWeek) ? colorGreenSemiLight.withOpacity(0.5) : colorGrey1),
                              ),
                            );
                          }).toList() ?? [],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned( //timeline bar
            left: 17.5,
            child: Container(
              height: Get.height * 0.7,
              width: 5.0,
              color: colorBlack.withOpacity(0.5),
            ),
          ),
          Positioned( //timeline circle
            bottom: 10,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20, top: 20, right: 0),
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
