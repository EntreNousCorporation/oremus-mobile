import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseController({
    required this.paroisseRepository,
  });

  RxList<ContentPlace?> paroisses = RxList<ContentPlace?>([]);

  var unlockBackButton = true.obs;

  var isExtended = true.obs;
  ScrollController scrollController = ScrollController();

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

  var offset = const Offset(16, 16).obs;

  // Observable pour suivre si l'utilisateur est connecté
  RxBool get isUserLoggedIn => RxBool(DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true);
  // Obtenir l'ID de l'utilisateur actuel
  static String? get currentUserId => DB.getUserSigninInfo()?.id;
  static var userIdBeforeLogout = ''.obs;


  @override
  void onInit() {
    initController();
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

  @override
  void onReady() {
    // Vérifier si la connectivité a changé
    ever(isUserLoggedIn, (bool loggedIn) {
      if (loggedIn) {
        // Vérifier si c'est une nouvelle connexion
        if (userIdBeforeLogout.isEmpty || userIdBeforeLogout.value != currentUserId) {
          log('New user logged in: $currentUserId');
          // Un nouvel utilisateur s'est connecté, synchroniser les favoris si nécessaire
          synchronizeFavorites();
          // Rafraîchir la liste pour afficher les favoris de ce nouvel utilisateur
          onRefresh();
        } else {
          log('Same user logged in again: $currentUserId');
        }
      } else {
        // L'utilisateur s'est déconnecté
        if (userIdBeforeLogout.isNotEmpty) {
          paroisseRepository.handleLogout();
          // Rafraîchir la liste pour refléter l'état déconnecté
          onRefresh();
        }
      }
    });
    getParoisses();
    super.onReady();
  }

  @override
  void dispose() {
    refreshController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (isExtended.isTrue) {
        isExtended.value = false;
      }
    }
    if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (isExtended.isFalse) {
        isExtended.value = true;
      }
    }
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

  moveToLogin(String code) async {
    var result = await Get.toNamed(
      Routes.SIGNIN,
      arguments: true,
    );
    if (result == true) {
      log('back moveToLogin');
      switch (code) {
        case 'FDM':
          moveToRequestMass();
          break;
        case 'FD':
          doMakeDonation();
          break;
      }
    }
  }

  checkIfUserIsconnected(String code) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.3,
        decoration: const BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Authentification requise',
                style: TextStyles.montserratBold(
                  textSize: TextSizes.twenty,
                  textColor: colorBlack,
                ),
              ),
              Separators.maximumVertical(),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Veuillez-vous connecter afin de mener cette action',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.sixteen,
                        textColor: colorBlack,
                      ),
                    ),
                    Separators.maximumVertical(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Annuler",
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.fourteen,
                            textColor: colorBlack,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: colorGreen, width: 0.5),
                        ),
                      ),
                      onPressed: Get.back,
                    ),
                  ),
                  Separators.normalHorizontal(),
                  Expanded(
                    child: TextButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Se connecter",
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.fourteen,
                            textColor: colorWhite,
                          ),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: colorGreen,
                        enableFeedback: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: colorGreen, width: 0.5),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 250), () {
                          moveToLogin(code);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      enableDrag: false,
      isDismissible: false,
    );
  }

  doMoveRequestMass() {
    if (isUserConnected.value == false) {
      checkIfUserIsconnected('FDM');
      return;
    }
    moveToRequestMass();
  }

  doMakeDonation() {
    if (isUserConnected.value == false) {
      checkIfUserIsconnected('FD');
      return;
    }
    moveToDonation();
  }

  moveToRequestMass() {
    Get.toNamed(Routes.MASS_REQUEST_WITHOUT_WORSHIP);
  }

  moveToDonation() {
    Get.toNamed(Routes.DONATION_WITHOUT_WORSHIP);
  }

  ///Chargement initial des paroisses
  getParoisses() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();
    isDataProcessing(true);

    log('request getParoisses');

    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then(
        (value) {
      isDataProcessing(false);
      paroisses.value = value.contents ?? [];
      /*for (var paroisse in paroisses) {
        paroisse?.isFavorite = isWorshipPlaceFavorite(paroisse);
      }*/
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

      var err = error as CustomException;
      if (err.code.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code.toString().contains('900')) {
        showCustomDialog(
          Get.context!,
          message: err.message.toString(),
        );
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des paroisses
  onRefresh() {
    log('request onRefresh');

    resetSearch();
    paroisseRepository.getParoisses(searchCriteria: searchCriteria.value).then(
            (value) {
          refreshController.refreshCompleted();
          paroisses.value = value.contents ?? [];

          // IMPORTANT: Ne pas écraser le statut des favoris ici
          // La ligne suivante est commentée car elle écrase les statuts définis par getParoisses()
          // for (var paroisse in paroisses) {
          //   paroisse?.isFavorite = isWorshipPlaceFavorite(paroisse);
          // }

          if (value.last == false) {
            page.value += 1;
          } else {
            refreshController.loadNoData();
          }
        }, onError: (error) {
      refreshController.refreshCompleted();
      var err = error as CustomException;
      if (error.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code.toString().contains('900')) {
        showCustomDialog(
          Get.context!,
          message: err.message.toString(),
        );
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Pagination des paroisses
  onLoading() {
    hideKeyboard();
    searchCriteria.value.name = searchController.text.trim();

    log('request onLoading');

    paroisseRepository
        .getParoisses(page: page.value, searchCriteria: searchCriteria.value)
        .then((value) {
      paroisses.addAll(value.contents ?? []);

      // IMPORTANT: Ne pas écraser le statut des favoris ici
      // La ligne suivante est commentée car elle écrase les statuts définis par getParoisses()
      // for (var paroisse in paroisses) {
      //   paroisse?.isFavorite = isWorshipPlaceFavorite(paroisse);
      // }

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
      var err = error as CustomException;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        showNotification(message: err.message.toString());
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///on vérifie si la paroisse est dans la liste des favoris
  bool isWorshipPlaceFavorite(ContentPlace? paroisse) {
    var isFavorite = false;
    var favorites = paroisseRepository.getAllFavorites();
    var hasParoisse = favorites
        .indexWhere((element) => element.identifier == paroisse?.identifier);
    if (hasParoisse != -1) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    return isFavorite;
  }

  /*saveFavorite(ContentPlace? paroisse) {
    paroisseRepository.addFavorite(paroisse);
    showMessageFavorite(paroisse);
  }*/

  // Sauvegarder un favori (local et/ou serveur)
  Future<void> saveFavorite(ContentPlace? paroisse) async {
    if (paroisse == null) return;

    try {
      // Mettre à jour l'UI immédiatement
      int index = paroisses.indexWhere((element) => element?.identifier == paroisse.identifier);
      if (index != -1) {
        paroisses[index]?.isFavorite = true;
        // Si l'utilisateur est connecté, on anticipe aussi la mise à jour de isUserFavorite
        if (isUserLoggedIn.value) {
          paroisses[index]?.isUserFavorite = true;
        }
        paroisses.refresh();
      }

      // Sauvegarder le favori
      await paroisseRepository.addFavorite(paroisse);
    } catch (e) {
      log('Error saving favorite: $e');
      // Restaurer l'état en cas d'erreur
      int index = paroisses.indexWhere((element) => element?.identifier == paroisse.identifier);
      if (index != -1) {
        paroisses[index]?.isFavorite = false;
        if (isUserLoggedIn.value) {
          paroisses[index]?.isUserFavorite = false;
        }
        paroisses.refresh();
      }
    }
  }

  /*removeFavorite(ContentPlace? paroisse) {
    paroisseRepository.deleteFavorite(paroisse);
    showMessageFavorite(paroisse);
  }*/

  // Supprimer un favori (local et/ou serveur)
  Future<void> removeFavorite(ContentPlace? paroisse) async {
    if (paroisse == null) return;

    try {
      // Mettre à jour l'UI immédiatement
      int index = paroisses.indexWhere((element) => element?.identifier == paroisse.identifier);
      if (index != -1) {
        paroisses[index]?.isFavorite = false;
        // Si l'utilisateur est connecté, on anticipe aussi la mise à jour de isUserFavorite
        if (isUserLoggedIn.value) {
          paroisses[index]?.isUserFavorite = false;
        }
        paroisses.refresh();
      }

      // Supprimer le favori
      await paroisseRepository.deleteFavorite(paroisse);
    } catch (e) {
      log('Error removing favorite: $e');
      // Restaurer l'état en cas d'erreur
      int index = paroisses.indexWhere((element) => element?.identifier == paroisse.identifier);
      if (index != -1) {
        paroisses[index]?.isFavorite = true;
        if (isUserLoggedIn.value) {
          paroisses[index]?.isUserFavorite = true;
        }
        paroisses.refresh();
      }
    }
  }

  showMessageFavorite(ContentPlace? paroisse) {
    if (paroisse?.isFavorite == true) {
      showNotification(
        trailing: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            child: (paroisse?.coverImage?.link?.isNotEmpty == true)
                ? CachedNetworkImage(
                    imageUrl: paroisse?.coverImage?.link ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                        width: Get.width / 4,
                        height: Get.width / 4,
                        child: LottieLoadingView(size: Get.width / 6)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : null,
          ),
        ),
        message: '«${paroisse?.name}» a été rajouté dans vos favoris',
        bgColor: colorGreenSemiLight,
      );
    } else {
      showNotification(
        trailing: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            child: (paroisse?.coverImage?.link?.isNotEmpty == true)
                ? CachedNetworkImage(
                    imageUrl: paroisse?.coverImage?.link ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => SizedBox(
                        width: Get.width / 4,
                        height: Get.width / 4,
                        child: LottieLoadingView(size: Get.width / 6)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : null,
          ),
        ),
        message: '«${paroisse?.name}» a été retiré des favoris',
      );
    }
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  goToParoisseDetail(ContentPlace? paroisse, int index) async {
    await Get.toNamed(
      Routes.PAROISSE_MENU,
      arguments: [
        index,
        paroisse?.toJson(),
      ],
    );
    //on met à jour la liste au cas où favoris mis à jour
    //paroisses[index]?.isFavorite = isWorshipPlaceFavorite(paroisse);
    //paroisses.refresh();
  }

  goToAdvancedSearch() async {
    searchCriteria.value = await Get.toNamed(Routes.FILTER_PAROISSE);
    searchCriteria.refresh();
    getParoisses();
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    log('searchCriteria isEmpty => ${searchCriteria.value.isCriteriaEmpty}');
  }

  //SEARCH SECTION
  resetSearch() {
    refreshController.loadComplete();
    searchCriteria.value = SearchCriteria();
    page.value = 0;
    searchController.clear();
    isSearchFieldEmpty.value = true;
    previousSimpleSearchValue.value = '';
    currentSimpleSearchValue.value = '';
    hideKeyboard();
  }

  // Méthode appelée avant la déconnexion de l'utilisateur
  static void prepareForLogout() {
    if (currentUserId != null && currentUserId!.isNotEmpty) {
      userIdBeforeLogout.value = currentUserId!;
      log('Storing user ID before logout: ${userIdBeforeLogout.value}');
    }
  }

  // Synchroniser les favoris locaux avec le serveur après la connexion
  Future<void> synchronizeFavorites() async {
    try {
      await paroisseRepository.syncFavorites();
    } catch (e) {
      log('Error synchronizing favorites: $e');
    }
  }

  // Méthode pour gérer la modification du favori dans l'UI
  Future<bool> onLikeButtonTapped(bool isLiked, ContentPlace? paroisse) async {
    try {
      if (isLiked) {
        await removeFavorite(paroisse);
        return false;
      } else {
        await saveFavorite(paroisse);
        return true;
      }
    } catch (e) {
      log('Error toggling favorite: $e');
      return isLiked; // Garder l'état actuel en cas d'erreur
    }
  }
}
