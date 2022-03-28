import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/drawer_menu.dart';
import 'package:oremusapp/app/modules/home/controller/home_controller.dart';
import 'package:oremusapp/app/modules/home/views/home_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_screen.dart';

class CustomHomeScreen extends StatelessWidget {
  const CustomHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleHiddenDrawer(
      menu: DrawerMenu(),
      withShadow: false,
      slidePercent: 70, // en %
      screenSelectedBuilder: (position, controller) {
        Widget? screenCurrent;
        switch (position) {
          case 0:
            screenCurrent = const HomeScreen();
            break;
          case 1:
            screenCurrent = const ParoisseScreen();
            break;
        }
        return Container(
          color: colorGreen,
          child: SafeArea(
            child: GetBuilder<CustomHomeController>(
                initState: (state) {},
                builder: (_) {
                  return WillPopScope(
                    onWillPop: () async => true,
                    child: KeyboardDismisser(
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        appBar: AppBar(
                          elevation: 0,
                          backgroundColor: colorGreen,
                          centerTitle: true,
                          leading: IconButton(
                            icon: const Icon(Icons.menu, color: colorWhite,),
                            onPressed: () {
                              controller.toggle();
                            },
                          ),
                          title: Text(
                            'Accueil',
                            style: TextStyles
                                .montserratBold(
                                textSize:
                                TextSizes
                                    .twenty,
                                textColor:
                                colorWhite),
                          ),
                        ),
                        body: screenCurrent,
                      ),
                    ),
                  );
                }),
          ),
        );
      },
    );
  }
}
