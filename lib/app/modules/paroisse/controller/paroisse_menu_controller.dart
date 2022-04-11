import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class ParoisseMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuController({
    required this.paroisseRepository,
  });

  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);

  @override
  void onInit() {
    getArguments();
    initMenus();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      indexSelected.value = Get.arguments[0];
      paroisseSelected.value =
          ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  initMenus() {
    menus.value = [
      TypeMenu(
        code: 'HM',
        title: 'Horaires des messes',
        icon: 'assets/images/icon_paroisse.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_MENU_DETAIL,
            arguments: [
              'HM',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'HC',
        title: 'Horaires des confessions',
        icon: 'assets/images/icon_diocese.jpg',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_MENU_DETAIL,
            arguments: [
              'HC',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'HB',
        title: 'Horaires des bureaux',
        icon: 'assets/images/icon_services.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_MENU_DETAIL,
            arguments: [
              'HB',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'AM',
        title: 'Activités & mouvements',
        icon: 'assets/images/icon_formation.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_MENU_DETAIL,
            arguments: [
              'AM',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
      TypeMenu(
        code: 'EP',
        title: 'Equipe presbytérale',
        icon: 'assets/images/team.png',
        isPngImage: true,
        activeTint: colorBlack,
        goToPage: () {
          Get.toNamed(
            Routes.PAROISSE_MENU_DETAIL,
            arguments: [
              'EP',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
        },
      ),
    ];
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: jsonEncode(paroisseSelected.value.toJson()),
    );
  }
}
