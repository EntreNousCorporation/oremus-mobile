import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
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
                  children: [
                    Image.asset('assets/images/bg_2.png',height: 80,)
                    //SvgPicture.asset('assets/images/splash_bottom.svg'),
                  ],
                ),
              )),
        );
        /*Container(
          child: Image.asset('assets/images/bg.png'),
        );*/
      }),
    );
  }
}
