import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class DioceseItem extends StatelessWidget {
  DioceseItem({Key? key, required this.diocese}) : super(key: key);

  ContentPlace? diocese;

  @override
  Widget build(BuildContext context) {
    return GetX<FilterParoisseController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          logic.onDioceseSelected(diocese ?? ContentPlace());
        },
        child: Row(
          children: [
            Separators.minimunHorizontal(),
            Container(
              decoration: BoxDecoration(
                color: logic.dioceseSelected.value == diocese ? colorGreenSemiLight : colorWhite,
                border: Border.all(color: colorGreenSemiLight),
                borderRadius: BorderRadius.circular(Get.width/10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${diocese?.name}',
                  textAlign: TextAlign.center,
                  style: TextStyles
                      .montserratSemiBold(
                      textSize:
                      TextSizes
                          .fourteen,
                      textColor: logic.dioceseSelected.value == diocese ? colorWhite : colorBlack,),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
