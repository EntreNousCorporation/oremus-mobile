import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/map/paroisse_map_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/map_type_choice.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/map_view_google.dart';

class ParoisseMapScreen extends StatelessWidget {
  const ParoisseMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          const MapViewGoogle(),
          GetBuilder<ParoisseMapController>(builder: (logic) {
            return CustomInfoWindow(
              controller: logic.mapController,
              width: Get.width/1.2,
              height: Get.width/2,
              offset: 50,
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 58.0, left: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(10.0),
                    elevation: 10,
                    color: colorWhite,
                    shadowColor: colorGrey2.withOpacity(0.5),
                    child: SizedBox(
                      height: (Get.width / 9),
                      width: (Get.width / 9),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: colorBlack,
                      ),
                    ),
                  ),
                ),
                Separators.normalHorizontal(),
                Material(
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 10,
                  color: colorWhite,
                  shadowColor: colorGrey2.withOpacity(0.5),
                  child: const MapTypeChoice(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
