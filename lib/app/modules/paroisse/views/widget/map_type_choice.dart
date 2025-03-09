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
    return GetBuilder<ParoisseMapController>(builder: (logic) {
      return Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Option Plan
            GestureDetector(
              onTap: () {
                logic.updateTypeMap('Plan');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: logic.typeMapValue.value == 'Plan'
                      ? colorGreenSemiLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 16,
                      color: logic.typeMapValue.value == 'Plan'
                          ? colorWhite
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Plan',
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.twelve,
                        textColor: logic.typeMapValue.value == 'Plan'
                            ? colorWhite
                            : Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Option Satellite
            GestureDetector(
              onTap: () {
                logic.updateTypeMap('Satellite');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: logic.typeMapValue.value == 'Satellite'
                      ? colorGreenSemiLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.satellite_alt_outlined,
                      size: 16,
                      color: logic.typeMapValue.value == 'Satellite'
                          ? colorWhite
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Satellite',
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.twelve,
                        textColor: logic.typeMapValue.value == 'Satellite'
                            ? colorWhite
                            : Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
