import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class DioceseItem extends StatelessWidget {
  DioceseItem({Key? key, required this.diocese}) : super(key: key);

  final ContentPlace? diocese;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilterParoisseController>();

    return Obx(() {
      bool isSelected = controller.dioceseSelected.value == diocese;

      return Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: GestureDetector(
          onTap: () {
            controller.onDioceseSelected(diocese ?? ContentPlace());
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? colorGreenSemiLight : colorWhite,
              border: Border.all(
                color: isSelected ? colorGreenSemiLight : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: colorGreenSemiLight.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: Icon(
                        Icons.check_circle,
                        color: colorWhite,
                        size: 18,
                      ),
                    ),
                  Text(
                    '${diocese?.name}',
                    style: TextStyles.montserratSemiBold(
                      textSize: TextSizes.fourteen,
                      textColor: isSelected ? colorWhite : Colors.grey[800]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
