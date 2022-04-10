import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class HomeController extends GetxController {
  var userConnection = Signin().obs;

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;

  //CAROUSEL
  late CarouselController carouselController;
  late CarouselOptions carouselOptions;
  var currentSlide = 0.obs;

  final List<String> imgList = [
    'assets/images/bg_login.jpg',
    'assets/images/bg_login.jpg',
    'assets/images/bg_login.jpg',
    'assets/images/bg_login.jpg',
    'assets/images/bg_login.jpg',
    'assets/images/bg_login.jpg'
  ];

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);

  @override
  void onInit() {
    getUserInfo();
    initCarousel();
    initMenus();
    super.onInit();
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      userConnection.value = Signin.fromJson(json.decode(userInfo));
    }
  }

  void initCarousel() {
    carouselController = CarouselController();
    carouselOptions = CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 1,
        aspectRatio: 16 / 9,
        disableCenter: true,
        onPageChanged: (index, reason) {
          currentSlide.value = index;
        });
  }

  initMenus() {
    menus.value = [
      TypeMenu(
        code: 'par',
        title: 'Paroisses',
        icon: 'assets/images/icon_paroisse.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.INITIAL,
            arguments: AppConstants.PAROISSE,
          );
        },
      ),
      TypeMenu(
        code: 'dio',
        title: 'Diocèses',
        icon: 'assets/images/icon_diocese.jpg',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.INITIAL,
            arguments: AppConstants.DIOCESE,
          );
        },
      ),
      TypeMenu(
        code: 'ser',
        title: 'Services',
        icon: 'assets/images/icon_services.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.INITIAL,
            arguments: AppConstants.SERVICE,
          );
        },
      ),
      TypeMenu(
        code: 'for',
        title: 'Formations',
        icon: 'assets/images/icon_formation.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.INITIAL,
            arguments: AppConstants.FORMATION,
          );
        },
      ),
    ];
  }
}
