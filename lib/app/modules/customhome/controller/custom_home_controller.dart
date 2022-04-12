import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';

class CustomHomeController extends GetxController {
  var userConnection = Signin().obs;

  RxList<MenuItem> menus = RxList<MenuItem>([]);
  late SimpleHiddenDrawerController drawerController;
  var selectedIndex = AppConstants.HOME.obs; //home
  var title = ''.obs;

  @override
  void onInit() {
    getUserInfo();
    initMenus();
    super.onInit();
  }

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    if (userInfo != null) {
      userConnection.value = Signin.fromJson(json.decode(userInfo));
    }
  }

  initMenus() {
    menus.value = [
      MenuItem(
        code: AppConstants.HOME,
        libelle: 'Accueil',
        icon: 'assets/images/icon_nav_home.svg',
      ),
      MenuItem(
        code: AppConstants.PROFILE,
        libelle: 'Mon profil',
        icon: 'assets/images/icon_user.svg',
      ),
      MenuItem(
        code: AppConstants.SHARE_APP,
        libelle: "Partager l'application",
        icon: 'assets/images/icon_settings.svg',
      ),
      MenuItem(
        code: AppConstants.PROMO,
        libelle: 'Codes promo',
        icon: 'assets/images/icon_settings.svg',
        isVisible: false,
      ),
      MenuItem(
        code: AppConstants.FAQ,
        libelle: 'F.A.Q',
        icon: 'assets/images/icon_settings.svg',
      ),
      MenuItem(
        code: AppConstants.CONTACTS,
        libelle: 'Contacts',
        icon: 'assets/images/icon_phone.svg',
        isVisible: false,
      ),
      MenuItem(
        code: AppConstants.ABOUT,
        libelle: 'A propos',
        icon: 'assets/images/icon_settings.svg',
      ),
    ];
    menus.value = menus.where((element) => element.isVisible).toList();
    log("${menus.length}");
  }

  doRedirection(int index, SimpleHiddenDrawerController controller) {
    log('index selected => $index');
    selectedIndex.value = index;
    controller.setSelectedMenuPosition(index);
    update();
  }

  doLogout() {
    encryptedBox.put(AppConstants.USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
