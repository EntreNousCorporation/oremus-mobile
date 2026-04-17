import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/favorite_check_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/favorite_data.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/interface_paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/data_response.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/app/remote/schedule_response.dart';
import 'package:oremusapp/main.dart';

class ParoisseRepository implements IParoisseRepository {
  final ApiClient _apiClient;

  ParoisseRepository(this._apiClient);

  @override
  Future<DataResponse<ContentPlace>> getParoisses({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;
    String? currentUserId = DB.getUserSigninInfo()?.id;

    searchCriteria?.likerUserId = currentUserId ?? '';

    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship?page=$page&size=${AppConstants.PAGING_SIZE_1000}&sort=name%2CASC${(searchCriteria?.name == null || searchCriteria?.name?.isEmpty == true) ? '' : '&name=${searchCriteria?.name}'}${(searchCriteria?.likerUserId == null || searchCriteria?.likerUserId?.isEmpty == true) ? '' : '&likerUserId=${searchCriteria?.likerUserId}'}${(searchCriteria?.type == null || searchCriteria?.type?.isEmpty == true) ? '' : '&type=${searchCriteria?.type}'}${(searchCriteria?.diocese == null || searchCriteria?.diocese?.isEmpty == true) ? '' : '&diocese=${searchCriteria?.diocese}'}${(searchCriteria?.city == null || searchCriteria?.city?.isEmpty == true) ? '' : '&city=${searchCriteria?.city}'}${(searchCriteria?.municipality == null || searchCriteria?.municipality?.isEmpty == true) ? '' : '&municipality=${searchCriteria?.municipality}'}${(searchCriteria?.neighborhood == null || searchCriteria?.neighborhood?.isEmpty == true) ? '' : '&neighborhood=${searchCriteria?.neighborhood}'}",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      var result = DataResponse<ContentPlace>.fromJson(response.data);

      // Traiter les favoris en fonction de l'état de connexion
      if (isUserLoggedIn) {
        // Pour utilisateur connecté, isFavorite est basé sur isUserFavorite (source de vérité)
        for (var paroisse in result.contents ?? []) {
          paroisse.isFavorite = paroisse.isUserFavorite ?? false;
        }
      } else {
        // Pour utilisateur non connecté, vérifier dans les favoris locaux non synchronisés
        var localFavorites = DB.getUnsynchronizedFavorites();
        for (var paroisse in result.contents ?? []) {
          paroisse.isFavorite = localFavorites.any((element) => element.identifier == paroisse.identifier);
        }
      }

      return result;
    }
  }

  @override
  Future<DataResponse<ContentPlace>> getParoissesBySchedule({int? page = 0, required String query}) async {
    final isUserLoggedIn = DB.getUserSigninInfo()?.id?.isNotEmpty == true;

    final uri = Uri(
      path: '/worship-places',
      queryParameters: {
        'query': query,
        'page': page.toString(),
        'size': AppConstants.PAGING_SIZE_1000.toString(),
      },
    );

    final response = await _apiClient.doRequest(
      customBaseUrl: customBaseUrl,
      endpoint: uri.toString(),
      method: HttpMethod.get,
      useBearer: false,
    );


    if (response.statusCode != 200) {
      final e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    }

    final scheduleResponse =
    ScheduleApiResponse.fromJson(response.data);

    final result = DataResponse<ContentPlace>()
      ..contents = scheduleResponse.content
      ..last = scheduleResponse.page?.isLast ?? true;

    if (result.contents == null || result.contents!.isEmpty) {
      return result;
    }

    if (isUserLoggedIn) {
      try {
        final ids = result.contents!
            .where((e) => e?.identifier != null)
            .map((e) => e?.identifier!)
            .toList();

        final favoritesStatus = await getUserFavoritesForPlaces(ids);

        final map = {
          for (var f in favoritesStatus) f.identifier: f.isUserFavorite ?? false
        };

        for (var p in result.contents!) {
          final isFav = map[p?.identifier] ?? false;
          p?.isUserFavorite = isFav;
          p?.isFavorite = isFav;
        }
      } catch (e) {
        _applyLocalFavorites(result.contents ?? []);
      }
    } else {
      _applyLocalFavorites(result.contents!);
    }

    return result;
  }

  void _applyLocalFavorites(List<ContentPlace?>? places) {
    final localFavorites = DB.getUnsynchronizedFavorites();

    final ids = localFavorites.map((e) => e.identifier).toSet();

    for (var p in places ?? []) {
      p?.isFavorite = ids.contains(p.identifier);
    }
  }

  @override
  Future<DataResponse<ContentPlace>> _getParoissesBySchedule({
    int? page = 0,
    required String query,
  }) async {
    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;
    String? currentUserId = DB.getUserSigninInfo()?.id;

    Response response = await _apiClient.doRequest(
      customBaseUrl: customBaseUrl,
      endpoint: '/worship-places?query=$query&page=$page&size=${AppConstants.PAGING_SIZE_1000}',
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      // Parser d'abord avec ScheduleApiResponse
      var scheduleResponse = ScheduleApiResponse.fromJson(response.data);

      // Convertir vers DataResponse
      var result = DataResponse<ContentPlace>();
      result.contents = scheduleResponse.content;
      result.last = scheduleResponse.page?.isLast ?? true;

      // Traiter les favoris en fonction de l'état de connexion
      if (isUserLoggedIn && result.contents != null && result.contents!.isNotEmpty) {
        try {
          // Extraire les IDs des paroisses
          List<dynamic> worshipPlaceIds = result.contents!
              .where((place) => place?.identifier != null)
              .map((place) => place!.identifier!)
              .toList();

          // Récupérer l'état des favoris pour ces paroisses
          List<FavoriteCheckResponse> favoritesStatus = await getUserFavoritesForPlaces(worshipPlaceIds);

          // Merger les informations de favoris avec les paroisses
          for (var paroisse in result.contents ?? []) {
            if (paroisse?.identifier != null) {
              // Chercher l'état du favori pour cette paroisse
              var favoriteInfo = favoritesStatus.firstWhere(
                    (fav) => fav.identifier == paroisse!.identifier,
                orElse: () => FavoriteCheckResponse(identifier: paroisse!.identifier, isUserFavorite: false),
              );

              // Mettre à jour les propriétés de favori
              paroisse?.isUserFavorite = favoriteInfo.isUserFavorite ?? false;
              paroisse?.isFavorite = favoriteInfo.isUserFavorite ?? false;
            }
          }
        } catch (e) {
          // En cas d'erreur, utiliser les favoris locaux comme fallback
          var localFavorites = DB.getUnsynchronizedFavorites();
          for (var paroisse in result.contents ?? []) {
            paroisse?.isFavorite = localFavorites.any((element) => element.identifier == paroisse?.identifier);
          }
        }
      } else if (!isUserLoggedIn) {
        // Pour utilisateur non connecté, vérifier dans les favoris locaux non synchronisés
        var localFavorites = DB.getUnsynchronizedFavorites();
        for (var paroisse in result.contents ?? []) {
          paroisse?.isFavorite = localFavorites.any((element) => element.identifier == paroisse?.identifier);
        }
      }

      return result;
    }
  }

  @override
  Future<List<FavoriteCheckResponse>> getUserFavoritesForPlaces(List<dynamic> worshipPlaceIds) async {
    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;

    if (!isUserLoggedIn || worshipPlaceIds.isEmpty) {
      return [];
    }

    try {
      // Construire les paramètres de query
      String queryParams = worshipPlaceIds
          .map((id) => 'worshipPlaceIds=$id')
          .join('&');

      Response response = await _apiClient.doRequest(
        endpoint: "/users/full-text-search-likes?$queryParams",
        method: HttpMethod.get,
        useBearer: true,
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((i) => FavoriteCheckResponse.fromJson(i))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      OremusLogger.error('Exception getting user favorites: $e');
      return [];
    }
  }

  // Méthode pour ajouter un favori au serveur (si connecté)
  @override
  Future<bool> addServerFavorite(ContentPlace? paroisse) async {
    if (paroisse?.identifier == null) return false;
    String? currentUserId = DB.getUserSigninInfo()?.id;

    FavoriteData request = FavoriteData(
      userId: currentUserId,
      worshipPlaceId: paroisse?.identifier,
    );

    try {
      Response response = await _apiClient.doRequest(
        endpoint: "/favorites",
        method: HttpMethod.post,
        body: request.toJson(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      OremusLogger.error('Error adding server favorite: $e');
      return false;
    }
  }

  // Méthode pour supprimer un favori du serveur (si connecté)
  @override
  Future<bool> removeServerFavorite(ContentPlace? paroisse) async {
    if (paroisse?.identifier == null) return false;

    String? currentUserId = DB.getUserSigninInfo()?.id;

    try {
      Response response = await _apiClient.doRequest(
        endpoint: "/favorites?userId=$currentUserId&worshipPlaceId=${paroisse?.identifier}",
        method: HttpMethod.delete,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      OremusLogger.error('Error removing server favorite: $e');
      return false;
    }
  }

  // Méthode pour récupérer les favoris du serveur
  @override
  Future<DataResponse<ContentPlace>> getServerFavorites({int? page = 0}) async {
    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;

    if (!isUserLoggedIn) return DataResponse();

    try {
      Response response = await _apiClient.doRequest(
        endpoint: "/places-of-worship/user-favorites?page=$page&size=${AppConstants.MASS_REQUEST_PAGING_SIZE}&sort=%2CASC",
        method: HttpMethod.get,
        useBearer: true,
      );

      if (response.statusCode != 200) return DataResponse();

      return DataResponse<ContentPlace>.fromJson(response.data);
    } catch (e) {
      OremusLogger.error('Error getting server favorites: $e');
      return DataResponse();
    }
  }

  // Méthode pour synchroniser les favoris locaux avec le serveur uniquement si c'est la première connexion
  // ou une connexion avec le même utilisateur que précédemment
  @override
  Future<void> syncFavorites() async {
    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;
    String? currentUserId = DB.getUserSigninInfo()?.id;

    if (!isUserLoggedIn) return;

    try {
      // 1. Vérifier si nous avons déjà synchronisé avec un utilisateur
      String? lastSyncUserId = DB.getLastSyncUserId();

      // Si c'est le même utilisateur ou s'il n'y a pas eu de synchronisation précédente
      if (lastSyncUserId == null || lastSyncUserId == currentUserId) {
        // 2. Obtenir les favoris non synchronisés
        List<ContentPlace> unsyncedFavorites = DB.getUnsynchronizedFavorites();
        if (unsyncedFavorites.isNotEmpty) {

          // 3. Obtenir les favoris du serveur (source de vérité)
          DataResponse<ContentPlace> serverFavoritesResponse = await getServerFavorites();
          List<ContentPlace?> serverFavorites = serverFavoritesResponse.contents ?? [];

          // 4. Identifier les favoris à ajouter au serveur
          List<ContentPlace> toAddToServer = unsyncedFavorites.where((local) =>
          !serverFavorites.any((server) => server?.identifier == local.identifier)).toList();

          // 5. Ajouter les favoris locaux au serveur
          for (var paroisse in toAddToServer) {
            bool success = await addServerFavorite(paroisse);
            OremusLogger.info('Added favorite to server: $success - ${paroisse.name}');
          }

          // 6. Une fois la synchronisation terminée, effacer les favoris non synchronisés
          DB.clearUnsynchronizedFavorites();
        }

        // 7. Récupérer à nouveau tous les favoris du serveur (pour avoir la liste complète et à jour)
        DataResponse<ContentPlace> updatedServerFavoritesResponse = await getServerFavorites();
        List<ContentPlace?> updatedServerFavorites = updatedServerFavoritesResponse.contents ?? [];

        // 8. Convertir la liste en liste non nullable
        List<ContentPlace> syncedFavorites = updatedServerFavorites
            .where((item) => item != null)
            .map((item) => item!)
            .toList();

        // 9. Marquer tous les favoris comme étant favoris
        for (var favorite in syncedFavorites) {
          favorite.isFavorite = true;
          favorite.isUserFavorite = true;
        }

        // 10. Sauvegarder dans le cache local spécifique à l'utilisateur
        DB.saveSyncedFavorites(syncedFavorites);

        // 11. Enregistrer l'ID de l'utilisateur actuel comme dernier synchronisateur
        DB.setLastSyncUserId(currentUserId!);

      } else {
        // C'est un utilisateur différent, nettoyer les favoris non synchronisés précédents
        DB.clearUnsynchronizedFavorites();

        // Récupérer les favoris du nouvel utilisateur depuis le serveur
        DataResponse<ContentPlace> serverFavoritesResponse = await getServerFavorites();
        List<ContentPlace?> serverFavorites = serverFavoritesResponse.contents ?? [];

        // Convertir la liste en liste non nullable
        List<ContentPlace> syncedFavorites = serverFavorites
            .where((item) => item != null)
            .map((item) => item!)
            .toList();

        // Marquer tous les favoris comme étant favoris
        for (var favorite in syncedFavorites) {
          favorite.isFavorite = true;
          favorite.isUserFavorite = true;
        }

        // Sauvegarder dans le cache local spécifique à l'utilisateur
        DB.saveSyncedFavorites(syncedFavorites);

        // Mettre à jour l'ID du dernier utilisateur synchronisé
        DB.setLastSyncUserId(currentUserId!);
      }
    } catch (e) {
      OremusLogger.error('Error synchronizing favorites: $e');
    }
  }

  // Gestion de la déconnexion
  void handleLogout() {
    // Effacer les données de synchronisation lors de la déconnexion
    DB.clearLastSyncUserId();
    // Nous ne supprimons pas les favoris non synchronisés car ils pourraient appartenir
    // à un autre utilisateur qui va se connecter
  }

  @override
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/liturgical-celebrations",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => LiturgicalCelebrationResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<ActivityResponse>> getActivities(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/activities",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => ActivityResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<MovementResponse>> getMouvements(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/movements",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      throw CustomException(response.statusCode, response.statusMessage);
    } else {
      return (response.data as List)
          .map((i) => MovementResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<PlaceUser>> getPlaceOfWorshipUsers(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/users",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => PlaceUser.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<Contact>> getPlaceOfWorshipContacts(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/contacts",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      debugPrint("===== getPlaceOfWorshipContacts =====");
      return (response.data as List)
          .map((i) => Contact.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<PlaceType>> getPlaceOfWorshipTypes({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint:
          "/types-of-worship?page=$page&size=${AppConstants.PAGING_SIZE_1000}&sort=code%2CASC",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      var e =
          ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => PlaceType.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<LiturgicalCelebrationResponse>> getOfficeTimes(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/services",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      throw CustomException(response.statusCode, response.statusMessage);
    } else {
      return (response.data as List)
          .map((i) => LiturgicalCelebrationResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<void> addFavorite(ContentPlace? paroisse) async {
    if (paroisse == null) return;

    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;

    log('Adding favorite - User logged in: $isUserLoggedIn');

    // Toujours mettre à jour l'état local de l'objet
    paroisse.isFavorite = true;

    if (isUserLoggedIn) {
      // Utilisateur connecté, ajouter au serveur
      bool success = await addServerFavorite(paroisse);
      if (success) {
        paroisse.isUserFavorite = true;
        log('Server favorite added successfully');

        // Mettre à jour le cache local des favoris synchronisés
        List<ContentPlace> syncedFavorites = DB.getSyncedFavorites();

        // Vérifier si le favori existe déjà
        int index = syncedFavorites.indexWhere((element) => element.identifier == paroisse.identifier);
        if (index == -1) {
          syncedFavorites.add(paroisse);
          DB.saveSyncedFavorites(syncedFavorites);
          log('Updated local cache - added favorite');
        }
      } else {
        log('Failed to add server favorite');
      }
    } else {
      // Utilisateur non connecté, ajouter aux favoris non synchronisés
      var unsyncedFavorites = DB.getUnsynchronizedFavorites();
      var hasParoisse = unsyncedFavorites.indexWhere((element) => element.identifier == paroisse.identifier);

      if (hasParoisse == -1) { // pas trouvé donc on peut ajouter
        unsyncedFavorites.add(paroisse);
        DB.saveUnsynchronizedFavorites(unsyncedFavorites);
        log('Local unsynchronized favorite added - total: ${unsyncedFavorites.length}');
      }
    }
  }

  @override
  Future<void> deleteFavorite(ContentPlace? paroisse) async {
    if (paroisse == null) return;

    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;

    log('Removing favorite - User logged in: $isUserLoggedIn');

    // Toujours mettre à jour l'état local de l'objet
    paroisse.isFavorite = false;
    paroisse.isUserFavorite = false;

    if (isUserLoggedIn) {
      // Utilisateur connecté, supprimer du serveur
      bool success = await removeServerFavorite(paroisse);
      if (success) {
        log('Server favorite removed successfully');

        // Mettre à jour le cache local des favoris synchronisés
        List<ContentPlace> syncedFavorites = DB.getSyncedFavorites();

        // Supprimer le favori du cache
        syncedFavorites.removeWhere((element) => element.identifier == paroisse.identifier);

        DB.saveSyncedFavorites(syncedFavorites);
        log('Updated local cache - removed favorite');
      } else {
        log('Failed to remove server favorite');
      }
    } else {
      // Utilisateur non connecté, supprimer des favoris non synchronisés
      var unsyncedFavorites = DB.getUnsynchronizedFavorites();
      unsyncedFavorites.removeWhere((element) => element.identifier == paroisse.identifier);
      DB.saveUnsynchronizedFavorites(unsyncedFavorites);
      log('Local unsynchronized favorite removed - total: ${unsyncedFavorites.length}');
    }
  }

  @override
  List<ContentPlace> getAllFavorites() {
    bool isUserLoggedIn = DB.getUserSigninInfo()?.id != null && DB.getUserSigninInfo()?.id?.isNotEmpty == true;

    if (isUserLoggedIn) {
      // Pour un utilisateur connecté, utiliser le cache local des favoris synchronisés
      return DB.getSyncedFavorites();
    } else {
      // Pour un utilisateur non connecté, retourner les favoris non synchronisés
      return DB.getUnsynchronizedFavorites();
    }
  }

  List<ContentPlace> getFavorites(String? favoritesToConverted) {
    if (favoritesToConverted != null && favoritesToConverted.isNotEmpty) {
      Iterable l = json.decode(favoritesToConverted);
      return l.map((model) => ContentPlace.fromJson(model)).toList();
    }
    return [];
  }
}
