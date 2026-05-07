import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

class LottieLoadingView extends StatelessWidget {
  LottieLoadingView({
    Key? key,
    this.color = colorGreen3,
    this.size,
    this.file,
  }) : super(key: key);

  final Color? color;
  final double? size;
  final String? file;

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      file ?? 'assets/images/lottie_church.json',
      repeat: true,
      width: size ?? Get.width / 4,
    );
  }
}
