import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/filter_mass_request_history_controller.dart';

class TypeDataItem extends StatelessWidget {
  TypeDataItem({Key? key, required this.typeData}) : super(key: key);

  TypeData? typeData;

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestHistoryController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          logic.onMassRequestTypeDataSelected(typeData ?? TypeData());
        },
        child: Row(
          children: [
            Separators.minimunHorizontal(),
            Container(
              decoration: BoxDecoration(
                color: logic.massRequestTypeSelected.value == typeData
                    ? colorGreenSemiLight
                    : colorWhite,
                border: Border.all(color: colorGreenSemiLight),
                borderRadius: BorderRadius.circular(Get.width / 10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${typeData?.name?.fr}',
                  textAlign: TextAlign.center,
                  style: TextStyles.montserratSemiBold(
                    textSize: TextSizes.fourteen,
                    textColor: logic.massRequestTypeSelected.value == typeData
                        ? colorWhite
                        : colorBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
