import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/about/views/about_screen.dart';
import 'package:oremusapp/app/modules/contact/views/contact_screen.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/drawer_menu.dart';
import 'package:oremusapp/app/modules/faq/faq_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_screen.dart';
import 'package:oremusapp/app/modules/profile/views/profile_screen.dart';
import 'package:oremusapp/app/modules/promos/views/promo_screen.dart';
import 'package:oremusapp/app/modules/share/views/share_screen.dart';

class CustomHomeScreen extends StatelessWidget {
  const CustomHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomHomeController>(builder: (logic) {
      return SimpleHiddenDrawer(
        menu: DrawerMenu(),
        withShadow: false,
        slidePercent: 70, // en %
        screenSelectedBuilder: (position, controller) {
          logic.drawerController = controller;
          Widget? screenCurrent;
          switch (position) {
            case AppConstants.HOME:
              screenCurrent = ParoisseScreen();
              //screenCurrent = HomeScreen();
              break;
            case AppConstants.PROFILE:
              screenCurrent = ProfileScreen();
              break;
            case AppConstants.SHARE_APP:
              screenCurrent = ShareScreen();
              break;
            case AppConstants.PROMO:
              screenCurrent = PromoScreen();
              break;
            case AppConstants.FAQ:
              screenCurrent = FaqScreen();
              break;
            case AppConstants.CONTACTS:
              screenCurrent = ContactScreen();
              break;
            case AppConstants.ABOUT:
              screenCurrent = AboutScreen();
              break;
          }
          return Container(
            color: colorGreen,
            child: SafeArea(
              child: WillPopScope(
                onWillPop: () async => true,
                child: KeyboardDismisser(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      elevation: 4,
                      backgroundColor: colorGreen,
                      centerTitle: true,
                      leading: IconButton(
                        icon: const Icon(Icons.menu, color: colorWhite,),
                        onPressed: () {
                          controller.toggle();
                        },
                      ),
                      title: Text(
                        'Oremus',
                        style: TextStyles
                            .montserratBold(
                            textSize:
                            TextSizes.twenty,
                            textColor:
                            colorWhite),
                      ),
                    ),
                    body: screenCurrent,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
