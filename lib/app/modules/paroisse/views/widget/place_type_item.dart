import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';

class PlaceTypeItem extends StatelessWidget {
  PlaceTypeItem({Key? key, required this.placeType}) : super(key: key);

  final PlaceType? placeType;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilterParoisseController>();

    return Obx(() {
      bool isSelected = controller.placeTypeSelected.value == placeType;

      return Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: GestureDetector(
          onTap: () {
            controller.onPlaceTypeSelected(placeType ?? PlaceType());
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
                  color: colorGreenSemiLight.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                    '${placeType?.translate?.fr}',
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
