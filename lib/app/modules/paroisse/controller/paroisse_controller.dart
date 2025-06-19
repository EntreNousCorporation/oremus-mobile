import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/services/refresh_controller_factory.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/data_response.dart';
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

  RefreshController get refreshController => RefreshControllerFactory.getController('paroisse_list');

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

  var currentSearchType = SearchType.advanced.obs;
  var scheduleQuery = ''.obs; // Stocke l'heure de recherche au format HH:mm:ss
  // Pour savoir si c'est un format d'heure
  var isTimeFormatSearch = false.obs;

// Variables pour le dialog de sélection d'horaire
  var selectedDay = ''.obs;
  var selectedStartTime = ''.obs;
  var selectedEndTime = ''.obs;
  var startTimeController = TextEditingController();
  var endTimeController = TextEditingController();


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

          // Nettoyer les anciens favoris au cas où
          DB.clearSyncedFavorites();

          // Un nouvel utilisateur s'est connecté, synchroniser les favoris si nécessaire
          synchronizeFavorites().then((_) {
            // Rafraîchir la liste pour afficher les favoris de ce nouvel utilisateur
            onRefresh();
          });
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
    RefreshControllerFactory.disposeController('paroisse_list');
    searchController.dispose();
    scrollController.dispose();

    startTimeController.dispose();
    endTimeController.dispose();

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

  // Méthode pour détecter si la saisie est une heure
  bool _isTimeFormat(String query) {
    if (query.trim().isEmpty) return false;

    // Regex pour détecter les formats HH:mm ou HH:mm:ss
    RegExp timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$');
    return timeRegex.hasMatch(query.trim());
  }

// Méthode pour normaliser l'heure au format HH:mm:ss
  String _normalizeTimeFormat(String time) {
    String trimmedTime = time.trim();
    // Si le format est HH:mm, ajouter :00
    if (trimmedTime.length == 5 && trimmedTime.contains(':')) {
      return '$trimmedTime:00';
    }
    return trimmedTime;
  }

  doLaunchSimpleSearch() {
    if (currentSimpleSearchValue.value != previousSimpleSearchValue.value) {
      previousSimpleSearchValue.value = currentSimpleSearchValue.value;

      String searchText = searchController.text.trim();

      // Toute saisie dans le champ utilise la recherche simple (endpoint /worship-places)
      currentSearchType.value = SearchType.simple;
      scheduleQuery.value = searchText;

      // Détecter si c'est un format d'heure pour l'affichage du bandeau
      if (_isTimeFormat(searchText)) {
        isTimeFormatSearch.value = true;
        scheduleQuery.value = _normalizeTimeFormat(searchText);
        log('Detected time format: ${scheduleQuery.value}');
      } else {
        isTimeFormatSearch.value = false;
        log('Detected text format: $searchText');
      }

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

  void doSearchBySchedule() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Recherche par horaire',
          style: TextStyles.montserratSemiBold(
            textSize: TextSizes.sixteen,
            textColor: colorBlack,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sélectionnez une heure pour rechercher les paroisses qui ont des messes à cette heure ou après.',
              style: TextStyles.montserratRegular(
                textSize: TextSizes.fourteen,
                textColor: colorGrey1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: startTimeController,
              decoration: const InputDecoration(
                labelText: 'Heure de recherche',
                border: OutlineInputBorder(),
                hintText: '10:00',
                suffixIcon: Icon(Icons.access_time),
              ),
              readOnly: true,
              onTap: () async {
                /*TimeOfDay? time = await showTimePicker(
                  context: Get.context!,
                  helpText: 'Sélectionner l\'heure',
                  initialTime: TimeOfDay.now(),
                  cancelText: 'Annuler',
                  confirmText: 'OK',
                  hourLabelText: 'Heure',
                  minuteLabelText: 'Minute',
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: true,
                      ),
                      child: Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: colorGreenSemiLight,
                            onPrimary: Colors.white,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                  },
                );*/
                TimeOfDay? time = await showCupertinoDialog<TimeOfDay>(
                  context: Get.context!,
                  builder: (BuildContext context) {
                    DateTime selectedTime = DateTime.now();
                    return CupertinoAlertDialog(
                      title: const Text('Sélectionner l\'heure'),
                      content: SizedBox(
                        height: 200,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: true,
                          initialDateTime: selectedTime,
                          onDateTimeChanged: (DateTime dateTime) {
                            selectedTime = dateTime;
                          },
                        ),
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Returns null
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(
                              TimeOfDay.fromDateTime(selectedTime),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
                if (time != null) {
                  String displayTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                  startTimeController.text = displayTime;
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'L\'heure sera automatiquement ajoutée dans le champ de recherche.',
              style: TextStyles.montserratItalic(
                textSize: TextSizes.twelve,
                textColor: colorGrey1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: TextStyles.montserratRegular(
                textColor: colorGrey1,
                textSize: TextSizes.fourteen,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (startTimeController.text.isNotEmpty) {
                // Mettre l'heure dans le champ de recherche principal
                searchController.text = startTimeController.text;
                currentSimpleSearchValue.value = startTimeController.text;
                isSearchFieldEmpty.value = false;

                // Marquer comme recherche d'heure ET recherche simple
                currentSearchType.value = SearchType.simple;
                isTimeFormatSearch.value = true;
                scheduleQuery.value = _normalizeTimeFormat(startTimeController.text);

                // Déclencher la recherche
                doLaunchSimpleSearch();
                Get.back();
              } else {
                showNotification(message: 'Veuillez sélectionner une heure');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorGreen,
            ),
            child: Text(
              'Rechercher',
              style: TextStyles.montserratSemiBold(
                textColor: colorWhite,
                textSize: TextSizes.fourteen,
              ),
            ),
          ),
        ],
      ),
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
    isDataProcessing(true);

    log('request getParoisses - SearchType: ${currentSearchType.value}');
    log('request getParoisses - Query: ${scheduleQuery.value}');
    log('request getParoisses - IsTimeFormat: ${isTimeFormatSearch.value}');
    log('request getParoisses - IsUserLoggedIn: ${isUserLoggedIn.value}');

    Future<DataResponse<ContentPlace>> searchFuture;

    if (currentSearchType.value == SearchType.simple) {
      // Recherche simple (texte ou heure) - utilise toujours l'endpoint /worship-places
      String query = scheduleQuery.value.isNotEmpty ? scheduleQuery.value : searchController.text.trim();

      searchFuture = paroisseRepository.getParoissesBySchedule(
        page: 0,
        query: query,
      );
    } else {
      // Recherche avancée avec filtres - utilise l'endpoint /places-of-worship
      searchCriteria.value.name = searchController.text.trim();
      searchFuture = paroisseRepository.getParoisses(
        searchCriteria: searchCriteria.value,
      );
    }

    searchFuture.then((value) {
      isDataProcessing(false);
      paroisses.value = value.contents ?? [];

      // Log pour vérifier les favoris
      int favoritesCount = paroisses.where((p) => p?.isFavorite == true).length;
      log('Loaded ${paroisses.length} parishes, $favoritesCount are favorites');

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
    }).catchError((error) {
      isDataProcessing(false);
      hasData(false);

      log('Error in getParoisses: $error');

      var err = error as CustomException;
      if (err.code.toString().contains('401')) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else {
        showNotification(message: 'Erreur lors du chargement des données: ${err.code.toString()}');
      }
      debugPrint("error => ${error.toString()}");
    });
  }

  ///Réinitialisation de la liste des paroisses
  onRefresh() {
    log('request onRefresh - SearchType: ${currentSearchType.value}');
    log('request onRefresh - scheduleQuery: ${scheduleQuery.value}');
    log('request onRefresh - searchController: ${searchController.text}');

    refreshController.loadComplete();
    page.value = 0;

    Future<DataResponse<ContentPlace>> searchFuture;

    if (currentSearchType.value == SearchType.simple) {
      String query = scheduleQuery.value.isNotEmpty ? scheduleQuery.value : searchController.text.trim();

      log('request onRefresh - using query: $query');

      searchFuture = paroisseRepository.getParoissesBySchedule(
        page: 0,
        query: query,
      );
    } else {
      searchCriteria.value.name = searchController.text.trim();
      searchFuture = paroisseRepository.getParoisses(
        searchCriteria: searchCriteria.value,
      );
    }

    searchFuture.then((value) {
      refreshController.refreshCompleted();
      paroisses.value = value.contents ?? [];

      // Log pour vérifier les favoris après refresh
      int favoritesCount = paroisses.where((p) => p?.isFavorite == true).length;
      log('Refreshed: ${paroisses.length} parishes, $favoritesCount are favorites');

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

    log('request onLoading - SearchType: ${currentSearchType.value}');
    log('request onLoading - Page: ${page.value}');

    Future<DataResponse<ContentPlace>> searchFuture;

    if (currentSearchType.value == SearchType.simple) {
      // Recherche simple avec pagination (endpoint /worship-places)
      String query = scheduleQuery.value.isNotEmpty ? scheduleQuery.value : searchController.text.trim();

      searchFuture = paroisseRepository.getParoissesBySchedule(
        page: page.value,
        query: query,
      );
    } else {
      // Recherche avancée avec pagination (endpoint /places-of-worship)
      searchCriteria.value.name = searchController.text.trim();
      searchFuture = paroisseRepository.getParoisses(
        page: page.value,
        searchCriteria: searchCriteria.value,
      );
    }

    searchFuture.then((value) {
      paroisses.addAll(value.contents ?? []);
      paroisses.refresh();
      refreshController.loadComplete();
      log('Total paroisses after loading: ${paroisses.length}');

      // Log pour vérifier les favoris après refresh
      int favoritesCount = paroisses.where((p) => p?.isFavorite == true).length;
      log('Refreshed: ${paroisses.length} parishes, $favoritesCount are favorites');

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
      } else {
        showNotification(message: 'Erreur lors du chargement des données supplémentaires');
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

    // Passer en mode recherche avancée
    currentSearchType.value = SearchType.advanced;
    isTimeFormatSearch.value = false;

    getParoisses();
    log('searchCriteria => ${searchCriteria.value.toJson().toString()}');
    log('searchCriteria isEmpty => ${searchCriteria.value.isCriteriaEmpty}');
  }


  //SEARCH SECTION

  void clearSearch() {
    refreshController.loadComplete();
    searchCriteria.value = SearchCriteria();
    page.value = 0;
    searchController.clear();
    isSearchFieldEmpty.value = true;
    previousSimpleSearchValue.value = '';
    currentSimpleSearchValue.value = '';

    // Reset des variables de recherche
    currentSearchType.value = SearchType.advanced;
    isTimeFormatSearch.value = false;
    scheduleQuery.value = '';
    selectedDay.value = '';
    selectedStartTime.value = '';
    selectedEndTime.value = '';
    startTimeController.clear();
    endTimeController.clear();

    hideKeyboard();

    // Recharger avec les paramètres vides
    getParoisses();
  }

  resetSearch() {
    refreshController.loadComplete();
    page.value = 0;
  }

  void switchToNormalSearch() {
    currentSearchType.value = SearchType.advanced;
    isTimeFormatSearch.value = false;

    // Si on avait une recherche par heure, on la convertit en recherche texte normale
    String currentText = searchController.text.trim();
    if (currentText.isNotEmpty && !_isTimeFormat(currentText)) {
      scheduleQuery.value = currentText;
    } else {
      // Si c'était une heure et qu'on veut passer en mode normal, on vide
      scheduleQuery.value = '';
    }

    getParoisses();
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
