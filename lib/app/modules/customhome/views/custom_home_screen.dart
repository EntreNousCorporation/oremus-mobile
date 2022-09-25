import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/about/views/about_screen.dart';
import 'package:oremusapp/app/modules/contact/views/contact_screen.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/drawer_menu.dart';
import 'package:oremusapp/app/modules/faq/views/faq_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_screen.dart';
import 'package:oremusapp/app/modules/pray/views/pray_screen.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
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
          switch (logic.menus[position].code) {
            case AppConstants.HOME:
              logic.title.value = 'Oremus';
              screenCurrent = const ParoisseScreen();
              //screenCurrent = HomeScreen();
              break;
            case AppConstants.PROFILE:
              logic.title.value = logic.menus[position].libelle ?? 'Mon Profil';
              screenCurrent = const ProfileScreen();
              break;
            case AppConstants.PRAY:
              logic.title.value = logic.menus[position].libelle ?? 'Prières';
              //screenCurrent = const ShareScreen();
              screenCurrent = const PrayScreen();
              break;
            case AppConstants.SHARE_APP:
              logic.title.value = logic.menus[position].libelle ?? 'Partager l\'application';
              screenCurrent = const ShareScreen();
              break;
            case AppConstants.PROMO:
              logic.title.value = logic.menus[position].libelle ?? 'Codes promo';
              screenCurrent = const PromoScreen();
              break;
            case AppConstants.FAQ:
              logic.title.value = logic.menus[position].libelle ?? 'F.A.Q';
              screenCurrent = const FaqScreen();
              break;
            case AppConstants.CONTACTS:
              logic.title.value = logic.menus[position].libelle ?? 'Contacts';
              screenCurrent = const ContactScreen();
              break;
            case AppConstants.ABOUT:
              logic.title.value = logic.menus[position].libelle ?? 'A propos';
              screenCurrent = const AboutScreen();
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
                      elevation: applyElevation(),
                      shadowColor: colorGrey2.withOpacity(0.8),
                      backgroundColor: colorGreen,
                      centerTitle: true,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: colorWhite,
                        ),
                        onPressed: () {
                          controller.toggle();
                        },
                      ),
                      actions: [
                        Visibility(
                          visible:
                              (logic.menus[logic.selectedIndex.value].code ==
                                      AppConstants.PROFILE) &&
                                  (logic.userCanUpdateProfile()),
                          child:
                              GetBuilder<ProfileController>(builder: (logic) {
                            return IconButton(
                              onPressed: () {
                                logic.goToEditProfile();
                              },
                              icon: const Icon(Icons.edit_rounded),
                            );
                          }),
                        ),
                        Visibility(
                          visible:
                              (logic.menus[logic.selectedIndex.value].code ==
                                  AppConstants.HOME),
                          child:
                              GetBuilder<ProfileController>(builder: (logic) {
                            return Bounce(
                              key: logic.basicIconAnimation,
                              preferences: AnimationPreferences(
                                offset: const Duration(seconds: 3),
                                autoPlay: logic.applyAnimation(),
                                magnitude: 0.3,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  logic.goToFavorites();
                                },
                                icon: const Icon(
                                  Icons.favorite_border_outlined,
                                  color: colorWhite,
                                  size: 25,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                      title: Text(
                        logic.title.value,
                        style: TextStyles.montserratBold(
                            textSize: TextSizes.twenty, textColor: colorWhite),
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
