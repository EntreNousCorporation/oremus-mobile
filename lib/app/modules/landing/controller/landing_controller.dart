import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/diocese/views/diocese_screen.dart';
import 'package:oremusapp/app/modules/formation/views/formation_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_screen.dart';
import 'package:oremusapp/app/modules/service/views/service_screen.dart';

class LandingController extends GetxController {

  RxList<Widget> screens = RxList([]);
  RxList<PersistentBottomNavBarItem> navBarsItems = RxList([]);
  var tabController = PersistentTabController(initialIndex: 0).obs;

  @override
  void onInit() {
    getArguments();
    buildNavBarsItems();
    buildScreens();
    super.onInit();
  }

  buildScreens() {
    screens.value = [
      const ParoisseScreen(),
      const DioceseScreen(),
      const ServiceScreen(),
      const FormationScreen(),
    ];
  }

  buildNavBarsItems() {
    navBarsItems.value = [
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
        title: 'Services',
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
    ];
  }

  getArguments() {
    if (Get.arguments != null) {
      tabController.value.index = Get.arguments;
    }
  }
}