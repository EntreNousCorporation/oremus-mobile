import 'dart:convert';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/operation_type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/main.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;
  var loading = true.obs;
  var showNotificationCount = 0.obs;
  var userConnection = SigninResponse().obs;

  RxList<OperationTypeMenu> operations = RxList<OperationTypeMenu>([]);

  var unlockBackButton = true.obs;

  //CAROUSEL
  late CarouselController carouselController;
  late CarouselOptions carouselOptions;
  var currentSlide = 0.obs;

  final List<String> imgList = [
    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
    'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
    'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
  ];

  ParoisseController({
    required this.paroisseRepository,
  });

  @override
  void onInit() {
    super.onInit();
    //getUserInfo();
    initMenus();
    initCarousel();
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

  void initMenus() {
    operations.value = [
      OperationTypeMenu(
        isVisble: true,
        title: 'ordinary_transfer'.tr,
        imageSVG: "assets/images/icon_transfert.svg",
        activeTint: colorBlack,
        goToPage: () {},
      ),
      OperationTypeMenu(
        isVisble: true,
        title: 'withdraw'.tr,
        imageSVG: "assets/images/icon_retrait.svg",
        activeTint: colorBlack,
        goToPage: () {},
      ),
      OperationTypeMenu(
        isVisble: true,
        title: 'account_transfer'.tr,
        imageSVG: "assets/images/icon_virement.svg",
        activeTint: colorBlack,
        goToPage: () {},
      ),
    ];

    operations.value = operations.where((element) => element.isVisble).toList();
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    SigninResponse userConnected =
        SigninResponse.fromJson(jsonDecode(userInfo));
    userConnection.value = userConnected;
  }
}
