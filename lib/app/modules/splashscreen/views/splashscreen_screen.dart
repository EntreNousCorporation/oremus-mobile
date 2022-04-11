import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/splashscreen/controller/splashscreen_controller.dart';

class SplashscreenScreen extends StatelessWidget {
  const SplashscreenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: GetBuilder<SplashscreenController>(builder: (logic) {
        return SafeArea(
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                color: colorWhite,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/logo.svg', height: 60,),
                    Separators.minimunVertical(),
                    Text('Oremus',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratBold(
                        textSize: TextSizes.twenty_four,
                        textColor: colorGreen,
                      ),
                    ),
                  ],
                ),
              )),
        );
      }),
    );
  }
}
