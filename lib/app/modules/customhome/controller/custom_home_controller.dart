import 'dart:developer';

import 'package:get/get.dart';
import 'package:hidden_drawer_menu/controllers/simple_hidden_drawer_controller.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class CustomHomeController extends GetxController {
  SigninRepository signinRepository;

  CustomHomeController({
    required this.signinRepository,
  });

  RxList<MenusItem> menus = RxList<MenusItem>([]);
  late SimpleHiddenDrawerController drawerController;
  var selectedIndex = AppConstants.HOME.obs; //home
  var title = ''.obs;

  @override
  void onInit() {
    initMenus();
    super.onInit();
  }

  initMenus() {
    menus.value = [
      MenusItem(
        code: AppConstants.HOME,
        libelle: 'Accueil',
        icon: 'assets/images/icon_nav_home.svg',
      ),
      MenusItem(
        code: AppConstants.PROFILE,
        libelle: 'Mon profil',
        icon: 'assets/images/icon_user.svg',
      ),
      MenusItem(
        code: AppConstants.SHARE_APP,
        libelle: "Partager l'application",
        icon: 'assets/images/share_icon.svg',
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.PROMO,
        libelle: 'Codes promo',
        icon: 'assets/images/icon_settings.svg',
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.FAQ,
        libelle: 'F.A.Q',
        icon: 'assets/images/faq_icon.svg',
      ),
      MenusItem(
        code: AppConstants.CONTACTS,
        libelle: 'Contacts',
        icon: 'assets/images/icon_phone.svg',
        isVisible: false,
      ),
      MenusItem(
        code: AppConstants.ABOUT,
        libelle: 'A propos',
        icon: 'assets/images/icon_settings.svg',
      ),
    ];
    menus.value = menus.where((element) => element.isVisible).toList();
    log("${menus.length}");
  }

  bool userCanUpdateProfile() {
    return signinRepository.getUserSigninInfo()?.isBoUser == false;
  }

  doRedirection(int index, SimpleHiddenDrawerController controller) {
    log('index selected => $index');
    selectedIndex.value = index;
    controller.setSelectedMenuPosition(index);
    update();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
