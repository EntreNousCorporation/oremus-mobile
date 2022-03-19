import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/home/views/home_screen.dart';

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
        onWillPop: widget._onBackPressed,
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
        navBarStyle: NavBarStyle.style13, // Choose the nav bar style with this property.
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const HomeScreen(),
      const HomeScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_outlined),
        title: '',
        textStyle: const TextStyle(fontFamily: 'avenir_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite_border),
        title: "",
        textStyle: const TextStyle(fontFamily: 'avenir_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: '',
        textStyle: const TextStyle(fontFamily: 'avenir_bold', fontSize: 12),
        activeColorPrimary: colorGreen,
        inactiveColorPrimary: colorGrey1,
      ),
    ];
  }
}
