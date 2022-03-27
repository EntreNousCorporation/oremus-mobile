import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/home/controller/home_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';

class SliderIndicator extends StatelessWidget {
  SliderIndicator({Key? key, required this.controller}) : super(key: key);

  HomeController controller;

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      initState: (_) {},
      builder: (logic) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: controller.imgList
              .asMap()
              .entries
              .map((entry) {
            return GestureDetector(
              onTap: () =>
                  controller.carouselController.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.currentSlide.value == entry.key
                        ? colorGreen
                        : colorWhite,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
