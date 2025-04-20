import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/splashscreen/controller/splashscreen_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class SplashscreenScreen extends StatelessWidget {
  const SplashscreenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: GetBuilder<SplashscreenController>(builder: (logic) {
        return SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: colorWhite,
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeIn(
                        key: logic.basicIconAnimation,
                        preferences: AnimationPreferences(
                          offset: const Duration(seconds: 0),
                          autoPlay: logic.applyAnimation(),
                          magnitude: 0.5,
                          duration: const Duration(seconds: 3),
                        ),
                        child: SvgPicture.asset(
                          Assets.assetsImagesLogo,
                          height: 60,
                        ),
                      ),
                      Separators.minimunVertical(),
                      FadeIn(
                        key: logic.basicTextAnimation,
                        preferences: AnimationPreferences(
                          offset: const Duration(seconds: 0),
                          autoPlay: logic.applyAnimation(),
                          magnitude: 0.5,
                          duration: const Duration(seconds: 3),
                        ),
                        child: Text(
                          'Oremus',
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.twenty_four,
                            textColor: colorGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 32,
                  child: Text(
                    'Powered by YPY it',
                    textAlign: TextAlign.center,
                    style: TextStyles.montserratRegular(
                      textSize: TextSizes.twelve,
                      textColor: colorGrey1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
