
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/map_view.dart';

class ParoisseMapScreen extends StatelessWidget {
  const ParoisseMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        const MapView(),
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 58.0, left: 16),
            child: Material(
              borderRadius:
              BorderRadius.circular(10.0),
              elevation: 10,
              color: colorWhite,
              shadowColor:
              colorGrey2.withOpacity(0.5),
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
        ),
      ],
    );
  }
}
