import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/services/refresh_controller_factory.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavoriteController extends GetxController {
  final ParoisseRepository paroisseRepository;

  FavoriteController({
    required this.paroisseRepository,
  });

  var favorites = RxList<ContentPlace>([]);
  var isLoading = false.obs;
  var currentUserId = ''.obs;

  // Vérifier si l'utilisateur est connecté
  bool get isUserLoggedIn => DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;

  // Observer l'ID de l'utilisateur pour détecter les changements
  String? get userId => DB.getUserSigninInfo()?.id;

  final GlobalKey<AnimatedListState> key = GlobalKey();
  RefreshController get refreshController => RefreshControllerFactory.getController('favorite_list');

  @override
  void onInit() {
    // Stocker l'ID de l'utilisateur actuel
    currentUserId.value = userId ?? '';

    // Observer les changements d'utilisateur
    ever(currentUserId, (String id) {
      if (id != (userId ?? '')) {
        log('User changed from $id to ${userId ?? 'none'}');
        // Rafraîchir la liste des favoris quand l'utilisateur change
        getAllFavorites();
      }
    });
    super.onInit();
  }

  @override
  void onReady() {
    getAllFavorites();
    super.onReady();
  }

  @override
  void dispose() {
    RefreshControllerFactory.disposeController('favorite_list');
    super.dispose();
  }

  Future<void> getAllFavorites() async {
    isLoading(true);

    try {
      // Mettre à jour l'ID de l'utilisateur actuel
      currentUserId.value = userId ?? '';

      if (isUserLoggedIn) {
        // Si l'utilisateur est connecté, charger les favoris du cache local synchronisé
        log('Loading synced favorites for user: $currentUserId');
        List<ContentPlace> syncedFavorites = DB.getSyncedFavorites();

        // Si le cache est vide ou si c'est la première fois, essayer de charger depuis le serveur
        if (syncedFavorites.isEmpty) {
          log('Synced favorites cache is empty, fetching from server');

          // Obtenir les favoris depuis le serveur
          var serverFavoritesResponse = await paroisseRepository.getServerFavorites();
          List<ContentPlace?> serverFavorites = serverFavoritesResponse.contents ?? [];

          // Filtrer les valeurs nulles et convertir en liste de ContentPlace
          syncedFavorites = serverFavorites
              .where((item) => item != null)
              .map((item) => item!)
              .toList();

          // Définir tous les favoris comme favoris (isFavorite = true)
          for (var favorite in syncedFavorites) {
            favorite.isFavorite = true;
            favorite.isUserFavorite = true;
          }

          // Sauvegarder dans le cache local
          DB.saveSyncedFavorites(syncedFavorites);
          log('Saved ${syncedFavorites.length} favorites to synced cache for user: $currentUserId');
        }

        favorites.value = syncedFavorites;
      } else {
        // Si l'utilisateur n'est pas connecté, charger les favoris non synchronisés
        log('Loading unsynchronized favorites (user not logged in)');
        favorites.value = DB.getUnsynchronizedFavorites();
      }

      // Trier les favoris par nom
      favorites.sort((a, b) => a.name!.compareTo(b.name!));
      log('Favorites loaded: ${favorites.length} items');
    } catch (e) {
      log('Error loading favorites: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> removeToFavoriteList(ContentPlace? paroisseToRemove, int index) async {
    if (paroisseToRemove == null) return;

    log('Removing favorite: ${paroisseToRemove.name}');

    showCustomDialog(
      Get.context!,
      message: 'Retirer «${paroisseToRemove.name}» des favoris ?',
      negativeLabel: 'Oui, Retirer',
      negativeCallBack: () async {
        try {
          // Marquer comme non favori pour l'UI
          paroisseToRemove.isFavorite = false;
          paroisseToRemove.isUserFavorite = false;

          // Supprimer de la liste visuelle immédiatement
          key.currentState!.removeItem(
            index,
                (_, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 0,
                  color: colorWhite,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    title: Text(
                      "",
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.fourteen,
                        textColor: colorBlack,
                      ),
                    ),
                  ),
                ),
              );
            },
            duration: const Duration(milliseconds: 300),
          );

          // Supprimer du repository (local et/ou serveur)
          await paroisseRepository.deleteFavorite(paroisseToRemove);

          // Rafraîchir la liste après l'animation
          Future.delayed(const Duration(milliseconds: 300), () {
            getAllFavorites();
          });

          // Mettre à jour aussi dans ParoisseController si disponible
          try {
            final paroisseController = Get.find<ParoisseController>();
            int paroisseIndex = paroisseController.paroisses.indexWhere((element) => element?.identifier == paroisseToRemove.identifier);
            if (paroisseIndex != -1) {
              paroisseController.paroisses[paroisseIndex]?.isFavorite = false;
              paroisseController.paroisses[paroisseIndex]?.isUserFavorite = false;
              paroisseController.paroisses.refresh();
            }
          } catch (e) {
            // Le contrôleur n'est pas disponible, rien à faire
            log('ParoisseController not available: $e');
          }
        } catch (e) {
          log('Error removing favorite: $e');
        }
      },
      positiveLabel: 'Annuler',
      positiveCallBack: () {},
    );
  }

  moveToHome() {
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  // Méthode à appeler lors de la déconnexion
  void handleLogout() {
    // Mémoriser l'ID de l'utilisateur actuel avant la déconnexion
    String oldUserId = currentUserId.value;

    // Effacer l'ID de l'utilisateur actuel
    currentUserId.value = '';

    // Rafraîchir la liste des favoris
    getAllFavorites();

    log('User logged out: $oldUserId');
  }
}