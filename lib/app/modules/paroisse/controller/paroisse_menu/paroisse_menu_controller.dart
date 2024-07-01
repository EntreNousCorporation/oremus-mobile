import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/type_menu.dart';
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
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[1]);
    }
  }

  initMenus() {
    menus.value = [
      TypeMenu(
        code: 'HM',
        title: 'Horaires des messes',
        icon: 'assets/images/messe.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_MESSE,
            arguments: [
              'HM',
              paroisseSelected.value.toJson(),
            ],
          );
          log("retour");
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'HC',
        title: 'Horaires des confessions',
        icon: 'assets/images/confession_icon.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_CONFESSION,
            arguments: [
              'HC',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
          log("retour");
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'HB',
        title: 'Horaires des bureaux',
        icon: 'assets/images/calendar.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_OFFICE,
            arguments: [
              'HB',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'AM',
        title: 'Activités & mouvements',
        icon: 'assets/images/group.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_ACTIVITY_MOVEMENT,
            arguments: [
              'AM',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
          log("retour");
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'EP',
        title: 'Equipe presbytérale',
        icon: 'assets/images/priest_icon.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_PRESBY_TEAM,
            arguments: [
              'EP',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
          log("retour");
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'CO',
        title: 'Contacts',
        icon: 'assets/images/contacts.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_CONTACT,
            arguments: [
              'CO',
              jsonEncode(paroisseSelected.value.toJson()),
            ],
          );
          log("retour");
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'IP',
        title: 'Infos paroissiales',
        icon: 'assets/images/icon_infos_paroissiales.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          log('massInfoUrl => ${paroisseSelected.value.massInfo}');
          await Get.toNamed(
            Routes.PAROISSE_CONTACT,
            arguments: [
              'IP',
              jsonEncode(paroisseSelected.value.toJson()),
              paroisseSelected.value.massInfo ?? '',
            ],
          );

          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite =
              isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'DM',
        title: 'Demandes de messe',
        icon: 'assets/images/icon_demande_de_messe.svg',
        isPngImage: false,
        activeTint: colorBlack,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_MASS_REQUEST_MENU,
            arguments: paroisseSelected.toJson(),
          );
          //on met à jour la liste au cas où favoris mis à jour
          paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
    ];
  }

  bool isWorshipPlaceFavorite(ContentPlace paroisse) {
    var isFavorite = false;
    var favorites = paroisseRepository.getAllFavorites();
    var hasParoisse = favorites.indexWhere((element) => element.identifier == paroisse.identifier);
    if (hasParoisse != -1) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    return isFavorite;
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: jsonEncode(paroisseSelected.value.toJson()),
    );
  }

  saveFavorite(ContentPlace paroisse, bool state) {
    log('saveFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.addFavorite(paroisse);
    //showMessageFavorite(state);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    log('removeFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.deleteFavorite(paroisse);
    //showMessageFavorite(state);
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
