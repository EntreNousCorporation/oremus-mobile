import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_confession_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';

class DayConfessionItem extends StatelessWidget {
  DayConfessionItem({Key? key, required this.openingTime}) : super(key: key);

  OpeningTime? openingTime;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseConfessionController>(builder: (logic) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Separators.minimunHorizontal(),
          Expanded(
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getDay(openingTime?.dayOfWeek),
                    textAlign: TextAlign.start,
                    style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.sixteen,
                        textColor: getCurrentDay() ==
                            getDay(openingTime?.dayOfWeek)
                            ? colorGreenSemiLight
                            : colorBlack),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: openingTime?.slots?.map((timeSlot) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '${logic.getTime(timeSlot.startTime ?? '')}',
                          style: TextStyles.montserratSemiBold(
                              textSize: TextSizes.fourteen,
                              textColor: getCurrentDay() ==
                                  getDay(openingTime?.dayOfWeek)
                                  ? colorGreenSemiLight
                                  .withOpacity(0.5)
                                  : colorGrey1),
                        ),
                      );
                    }).toList() ??
                        [],
                  ),
                ],
              ),
            ),
          )
        ],
      );
    });
  }
}
