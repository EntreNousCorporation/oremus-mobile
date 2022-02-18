
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
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
      child: GetX<SplashscreenController>(builder: (logic) {
        return SafeArea(
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                color: colorWhite,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      'Simple & rapide',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'avenir_bold',
                        fontSize: 32,
                        color: colorGreenDark,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                                visible: false,
                                child: Separators.minimunVertical()),
                            const Visibility(
                              visible: false,
                              child: LoadingView()
                            )
                          ],
                        ),
                      ),
                    ),
                    SvgPicture.asset('assets/images/splash_bottom.svg'),
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
