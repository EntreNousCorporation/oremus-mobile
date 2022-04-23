import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';

class PlaceTypeItem extends StatelessWidget {
  PlaceTypeItem({Key? key, required this.placeType}) : super(key: key);

  PlaceType? placeType;

  @override
  Widget build(BuildContext context) {
    return GetX<FilterParoisseController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          log('${placeType?.code}');
          logic.onPlaceTypeSelected(placeType ?? PlaceType());
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0,),
          child: Row(
            children: [
              Separators.minimunHorizontal(),
              Container(
                width: Get.width / 3.5,
                decoration: BoxDecoration(
                  color: logic.placeTypeSelected.value == placeType ? colorGreenSemiLight : colorWhite,
                  border: Border.all(color: colorGreenSemiLight),
                  borderRadius: BorderRadius.circular(Get.width/10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '${placeType?.translate?.fr}',
                    textAlign: TextAlign.center,
                    style: TextStyles
                        .montserratSemiBold(
                        textSize:
                        TextSizes
                            .fourteen,
                        textColor: logic.placeTypeSelected.value == placeType ? colorWhite : colorBlack,),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
