import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseController({
    required this.paroisseRepository,
  });

  RxList<ContentPlace> paroisses = RxList<ContentPlace>([]);

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var page = 0.obs;

  var refreshController = RefreshController();

  late TextEditingController searchController;
  var isSearchFieldEmpty = true.obs;
  var searchCriteria = SearchCriteria().obs;

  var previousSimpleSearchValue = ''.obs;
  var currentSimpleSearchValue = ''.obs;

  @override
  void onInit() {
    initController();
    super.onInit();
  }

  @override
  void onReady() {
    getParoisses();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  initController() {
    searchController = TextEditingController(text: '');
  }

  doLaunchSimpleSearch() {
    if (currentSimpleSearchValue.value != previousSimpleSearchValue.value) {
      previousSimpleSearchValue.value = currentSimpleSearchValue.value;
      getParoisses();
    }
  }

  ///Chargement initial des paroisses
  getParoisses() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();
    isDataProcessing(true);

    log('request getParoisses');

    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then((value) {
      isDataProcessing(false);
      paroisses.value = value.content ?? [];
      for (var paroisse in paroisses) {
        paroisse.isFavorite = isWorshipPlaceFavorite(paroisse);
      }
      if (paroisses.isNotEmpty == true) {
        hasData(true);
      } else {
        hasData(false);
      }
      if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      isDataProcessing(false);
      hasData(false);
      if (error.toString().contains('401')) {
        showCustomDialog(
            Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des paroisses
  onRefresh() {

    log('request onRefresh');

    resetSearch();
    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then((value) {
      refreshController.refreshCompleted();
      paroisses.value = value.content ?? [];
      for (var paroisse in paroisses) {
        paroisse.isFavorite = isWorshipPlaceFavorite(paroisse);
      }
      if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      refreshController.refreshCompleted();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Pagination des paroisses
  onLoading() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();

    log('request onLoading');

    paroisseRepository.getParoisses(page: page.value, searchCriteria: searchCriteria.value).then((value) {
      paroisses.value.addAll(value.content ?? []);
      for (var paroisse in paroisses) {
        paroisse.isFavorite = isWorshipPlaceFavorite(paroisse);
      }
      paroisses.refresh();
      refreshController.loadComplete();
      log('${paroisses.length}');
      if (value.last == false) {
        page.value += 1;
      } else {
        refreshController.loadNoData();
      }
    }, onError: (error) {
      refreshController.loadFailed();
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!, message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///on vérifie si la paroisse est dans la liste des favoris
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

  showMessageFavorite(bool state) {
    if (state) {
      showNotification(
          message: 'Ce lieu de culte a été rajouté dans vos favoris',
          bgColor: colorGreenSemiLight
      );
    } else {
      showNotification(
          message: 'Ce lieu de culte a été retiré des favoris',
      );
    }
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  goToParoisseDetail(ContentPlace paroisse, int index) async {
    await Get.toNamed(
      Routes.PAROISSE_MENU,
      arguments: [
        index,
        jsonEncode(paroisse.toJson())
      ],
    );
    //on met à jour la liste au cas où favoris mis à jour
    paroisses[index].isFavorite = isWorshipPlaceFavorite(paroisse);
    paroisses.refresh();
  }

  goToAdvancedSearch() async {
    searchCriteria.value = await Get.toNamed(Routes.FILTER_PAROISSE);
    searchCriteria.refresh();
    resetSearch();
    getParoisses();
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    log('searchCriteria isEmpty => ${searchCriteria.value.isCriteriaEmpty}');
  }

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    page.value = 0;
    searchController.clear();
    isSearchFieldEmpty.value = true;
    previousSimpleSearchValue.value = '';
    currentSimpleSearchValue.value = '';
    hideKeyboard();
  }
}
