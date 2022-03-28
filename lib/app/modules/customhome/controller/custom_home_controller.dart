import 'dart:convert';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/main.dart';

class CustomHomeController extends GetxController {
  var userConnection = SigninResponse().obs;

  RxList<MenuItem> menus = RxList<MenuItem>([]);

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
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: '',
        libelle: 'Mon profil',
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: '',
        libelle: "Partager l'application",
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: '',
        libelle: 'Codes promo',
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: '',
        libelle: 'F.A.Q',
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: '',
        libelle: 'Contacts',
        icon: 'assets/images/icon_paroisse.png',
      ),
      MenuItem(
        code: '',
        libelle: 'A propos',
        icon: 'assets/images/icon_paroisse.png',
      ),
    ];
  }
}
