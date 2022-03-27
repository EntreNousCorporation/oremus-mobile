import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';

class NotFoundScreen extends StatelessWidget {
  NotFoundScreen(
      {this.lottieIcon = 'assets/images/lottie_empty_search.json',
      this.repeated = false,
      this.circled = true,
      required this.message,
      Key? key})
      : super(key: key);
  var lottieIcon;
  var repeated;
  var circled;
  var message = '';

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: circled
                ? BorderRadius.circular(
                    Get.width / 2,
                  )
                : const BorderRadius.all(Radius.elliptical(0, 0)),
            child: Container(
              color: colorWhite,
              child: Lottie.asset(lottieIcon,
                  repeat: repeated, width: Get.width / 2),
            ),
          ),
          Separators.normalVertical(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontFamily: 'montserrat_regular'),
          ),
        ],
      ),
    );
  }
}
