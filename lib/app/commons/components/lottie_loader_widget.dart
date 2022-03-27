import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

class LottieLoadingView extends StatelessWidget {
  const LottieLoadingView({
    Key? key,
    this.color = colorGreen3,
    this.size = 20.0,
  }) : super(key: key);

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      'assets/images/lottie_church.json',
      repeat: true,
      width: Get.width / 4,
    );
  }
}
