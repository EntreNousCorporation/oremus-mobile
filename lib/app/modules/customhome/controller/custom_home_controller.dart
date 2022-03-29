import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class CustomHomeController extends GetxController {
  var userConnection = SigninResponse().obs;

  RxList<MenuItem> menus = RxList<MenuItem>([]);
  late SimpleHiddenDrawerController drawerController;
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    getUserInfo();
    initMenus();
    super.onInit();
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      userConnection.value = SigninResponse.fromJson(json.decode(userInfo));
    }
  }

  initMenus() {
    menus.value = [
      MenuItem(
        code: '',
        libelle: 'Accueil',
        icon: 'assets/images/icon_nav_home.svg',
      ),
      MenuItem(
        code: '',
        libelle: 'Mon profil',
        icon: 'assets/images/icon_user.svg',
      ),
      MenuItem(
        code: '',
        libelle: "Partager l'application",
        icon: 'assets/images/icon_settings.svg',
      ),
      MenuItem(
        code: '',
        libelle: 'Codes promo',
        icon: 'assets/images/icon_settings.svg',
      ),
      MenuItem(
        code: '',
        libelle: 'F.A.Q',
        icon: 'assets/images/icon_settings.svg',
      ),
      MenuItem(
        code: '',
        libelle: 'Contacts',
        icon: 'assets/images/icon_phone.svg',
      ),
      MenuItem(
        code: '',
        libelle: 'A propos',
        icon: 'assets/images/icon_settings.svg',
      ),
    ];
  }

  doRedirection(int index, SimpleHiddenDrawerController controller) {
    log('index selected => $index');
    selectedIndex.value = index;
    controller.setSelectedMenuPosition(index);
    update();
  }

  doLogout() {
    encryptedBox.put(AppConstants.USER_LOG_INFOS, null);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
