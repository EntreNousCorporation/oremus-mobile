import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/landing/controller/landing_controller.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true, //widget._onBackPressed,
      child:
      GetX<LandingController>(
        initState: (_) {},
        builder: (logic) {
          return PersistentTabView(
            context,
            controller: logic.tabController.value,
            screens: logic.screens.value,
            items: logic.navBarsItems.value,
            confineInSafeArea: true,
            backgroundColor: colorWhite,
            handleAndroidBackButtonPress: false,
            resizeToAvoidBottomInset: true,
            // This needs to be true if you want to move up the screen when keyboard appears.
            stateManagement: true,
            //mettre à false après et corrigé le bug
            hideNavigationBarWhenKeyboardShows: true,
            // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(0.0),
              colorBehindNavBar: colorWhite,
            ),
            popAllScreensOnTapOfSelectedTab: true,
            itemAnimationProperties: const ItemAnimationProperties(
              // Navigation Bar's items animation properties.
              duration: Duration(milliseconds: 200),
              curve: Curves.linear,
            ),
            screenTransitionAnimation: const ScreenTransitionAnimation(
              // Screen transition animation on change of selected tab.
              animateTabTransition: true,
              curve: Curves.bounceInOut,
              duration: Duration(milliseconds: 200),
            ),
            navBarStyle: NavBarStyle
                .style1, // Choose the nav bar style with this property.
          );
        },
      ),
    );
  }
}
