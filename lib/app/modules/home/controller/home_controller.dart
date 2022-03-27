import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/home/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/main.dart';

class HomeController extends GetxController {

  var userConnection = SigninResponse().obs;

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

  RxList<MenuItem> menus = RxList<MenuItem>([]);

  @override
  void onInit() {
    getUserInfo();
    initCarousel();
    initMenus();
    super.onInit();
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    SigninResponse userConnected =
    SigninResponse.fromJson(jsonDecode(userInfo));
    userConnection.value = userConnected;
  }

  void initCarousel() {
    carouselController = CarouselController();
    carouselOptions = CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: false,
        viewportFraction: 1,
        aspectRatio: 16/9,
        disableCenter: true,
        onPageChanged: (index, reason) {
          currentSlide.value = index;
        });
  }

  initMenus() {
    menus.value = [
      MenuItem(
        code: 'par',
        libelle: 'Paroisses',
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: 'dio',
        libelle: 'Diocèses',
        icon: 'assets/images/icon_diocese.jpg',
      ),
      MenuItem(
        code: 'ser',
        libelle: 'Services',
        icon: 'assets/images/icon_services.png',
      ),
      MenuItem(
        code: 'for',
        libelle: 'Formations',
        icon: 'assets/images/icon_formation.png',
      ),
    ];
  }
}