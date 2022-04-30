import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/map/paroisse_map_controller.dart';

class MapTypeChoice extends StatelessWidget {
  const MapTypeChoice({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMapController>(builder: (logic) {
      return Container(
        height: (Get.width / 9),
        width: (Get.width / 4),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButton<String>(
          value: logic.typeMapValue.value,
          underline: Container(),
          isExpanded: true,
          items: logic.typeMaps.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.twelve,
                  textColor: colorBlack,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            logic.typeMapValue.value = value ?? '';
          },
        ),
      );
    });
  }
}
