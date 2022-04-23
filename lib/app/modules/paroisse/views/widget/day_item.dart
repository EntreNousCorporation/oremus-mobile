import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_menu_detail_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';

class DayItem extends StatelessWidget {
  DayItem({Key? key, required this.openingTime}) : super(key: key);

  OpeningTime? openingTime;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseMenuDetailController>(builder: (logic) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0,),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colorGreenSemiLight,
              ),
            ),
            Separators.minimunHorizontal(),
            Text(
              '${getDay(openingTime?.dayOfWeek)}:',
              textAlign:
              TextAlign.start,
              style: TextStyles
                  .montserratSemiBold(
                  textSize:
                  TextSizes
                      .fourteen,
                  textColor: colorBlack),
            ),
        Row(
          children: openingTime?.slots?.map((timeSlot) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${logic.getTime(timeSlot.startTime ?? '')}',
                    style: TextStyles.montserratSemiBold(textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                ),
              ],
            );
          }).toList() ?? [],
        ),
          ],
        ),
      );
    });
  }
}
