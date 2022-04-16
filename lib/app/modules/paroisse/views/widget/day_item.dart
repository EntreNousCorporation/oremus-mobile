import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu_detail_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';

class DayItem extends StatelessWidget {
  DayItem({Key? key, required this.openingTime}) : super(key: key);

  OpeningTime? openingTime;

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMenuDetailController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          log(getDay(openingTime?.dayOfWeek));
          logic.daySelected(openingTime ?? OpeningTime());
        },
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
              horizontal: 8.0),
          child: Container(
            width: Get.width / 3.5,
            decoration: BoxDecoration(
              color: logic.openingTime.value == openingTime ? colorBrown : colorWhite,
              border: Border.all(color: colorBrown),
              borderRadius: BorderRadius.circular(Get.width/10),
            ),
            child: Padding(
              padding:
              const EdgeInsets.all(
                  8.0),
              child: Text(
                getDay(openingTime?.dayOfWeek),
                textAlign:
                TextAlign.center,
                style: TextStyles
                    .montserratSemiBold(
                    textSize:
                    TextSizes
                        .fourteen,
                    textColor: logic.openingTime.value == openingTime ? colorWhite : colorBlack),
              ),
            ),
          ),
        ),
      );
    });
  }
}
