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
import 'package:oremusapp/generated/assets.dart';

class ParoisseMenuController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuController({
    required this.paroisseRepository,
  });

  var paroisseSelected = ContentPlace().obs;
  var indexSelected = 0.obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);
  var kExpandedHeight = Get.width / 1.7;

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
      log('paroisseSelected paroisse menu :::${jsonEncode(paroisseSelected.value)}');
    }
  }

  initMenus() {
    menus.value = [
      TypeMenu(
        code: 'HM',
        title: 'Horaires des messes',
        icon: Assets.imagesMesse,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
        icon: Assets.imagesConfessionIcon,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
        icon: Assets.imagesCalendar,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
        icon: Assets.imagesGroup,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
          paroisseSelected.value.isFavorite = isWorshipPlaceFavorite(paroisseSelected.value);
          paroisseSelected.refresh();
        },
      ),
      TypeMenu(
        code: 'EP',
        title: 'Equipe presbytérale',
        icon: Assets.imagesPriestIcon,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
        icon: Assets.imagesContacts,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
        icon: Assets.imagesIconInfosParoissiales,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
        icon: Assets.imagesIconDemandeDeMesse,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
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
      TypeMenu(
        code: 'FD',
        title: 'Don',
        icon: Assets.imagesVolunteer,
        isPngImage: false,
        activeTint: colorGreenSemiLight,
        goToPage: () async {
          await Get.toNamed(
            Routes.PAROISSE_DONATION_MENU,
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

  goToReportProblem() {
    Get.toNamed(
      Routes.REPORT_PROBLEM,
      arguments: paroisseSelected.value.toJson(),
    );
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: paroisseSelected.toJson(),
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
