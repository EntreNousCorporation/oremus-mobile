import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuController({
    required this.paroisseRepository,
  });

  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      indexSelected.value = Get.arguments[0];
      paroisseSelected.value = ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${indexSelected.value}');
    }
  }
}
