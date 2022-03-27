import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/diocese/views/diocese_screen.dart';
import 'package:oremusapp/app/modules/formation/views/formation_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_screen.dart';
import 'package:oremusapp/app/modules/service/views/service_screen.dart';

class LandingScreen extends StatefulWidget {
  LandingScreen({Key? key}) : super(key: key);

  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);

  Future<bool> _onBackPressed() async => showExitDialog(
    Get.context!,
    message: 'close_app_msg'.tr,
  ).then((res) {
    if (res) {
      Future.delayed(const Duration(milliseconds: 500), () {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        // exit(0);
      });
    }
  });

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => true, //widget._onBackPressed,
        child:
      PersistentTabView(
        context,
        controller: widget._controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: colorWhite,
        handleAndroidBackButtonPress: false,
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears.
        stateManagement: true, //mettre à false après et corrigé le bug
        hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument.
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
        navBarStyle: NavBarStyle.style1, // Choose the nav bar style with this property.
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      const ParoisseScreen(),
      const DioceseScreen(),
      const FormationScreen(),
      const ServiceScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_outlined),
        title: 'Paroisses',
        textStyle: const TextStyle(fontFamily: 'montserrat_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite_border),
        title: 'Diocèses',
        textStyle: const TextStyle(fontFamily: 'montserrat_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: 'Formations',
        textStyle: const TextStyle(fontFamily: 'montserrat_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: 'Services',
        textStyle: const TextStyle(fontFamily: 'montserrat_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
    ];
  }
}
