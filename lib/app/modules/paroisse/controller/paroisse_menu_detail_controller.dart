import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseMenuDetailController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuDetailController({
    required this.paroisseRepository,
  });

  var code = ''.obs;
  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      code.value = Get.arguments[0];
      paroisseSelected.value = ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  getTypeTitle(String code) {
    switch (code) {
      case 'HM':
        return 'Horaires des messes';
      case 'HC':
        return 'Horaires des confessions';
      case 'HB':
        return 'Horaires des bureaux';
      case 'AM':
        return 'Activités & mouvements';
      case 'EP':
        return 'Equipe presbytérale';
    }
  }

  getTypeMessage(String code) {
    switch (code) {
      case 'HM':
      case 'HC':
      case 'HB':
        return 'Horaires non disponible\nRéessayez plus tard svp';
      case 'AM':
      case 'EP':
        return 'Aucune information trouvée';
    }
  }
}
