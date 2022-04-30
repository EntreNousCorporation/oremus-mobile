import 'dart:convert';
import 'dart:developer';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/interface_paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class ParoisseRepository implements IParoisseRepository {
  final ApiClient _apiClient;

  ParoisseRepository(this._apiClient);

  @override
  Future<PlaceResponse> getParoisses({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    Response response = await _apiClient.doRequest(
      endpoint:
          "/places-of-worship?page=$page&size=${AppConstants.PAGING_SIZE}&sort=name%2CASC${(searchCriteria?.name == null || searchCriteria?.name?.isEmpty == true) ? '' : '&name=${searchCriteria?.name}'}${(searchCriteria?.type == null || searchCriteria?.type?.isEmpty == true) ? '' : '&type=${searchCriteria?.type}'}${(searchCriteria?.diocese == null || searchCriteria?.diocese?.isEmpty == true) ? '' : '&diocese=${searchCriteria?.diocese}'}${(searchCriteria?.city == null || searchCriteria?.city?.isEmpty == true) ? '' : '&city=${searchCriteria?.city}'}${(searchCriteria?.municipality == null || searchCriteria?.municipality?.isEmpty == true) ? '' : '&municipality=${searchCriteria?.municipality}'}${(searchCriteria?.neighborhood == null || searchCriteria?.neighborhood?.isEmpty == true) ? '' : '&neighborhood=${searchCriteria?.neighborhood}'}",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      //log('resp => $resp');
      return PlaceResponse.fromJson(
          json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(
      int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/liturgical-celebrations",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      //log('resp => $resp');
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => LiturgicalCelebrationResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<ActivityResponse>> getActivities(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/activities",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => ActivityResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<MovementResponse>> getMouvements(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/movements",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => MovementResponse.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<PlaceUser>> getPlaceOfWorshipUsers(int idParoisse) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship/$idParoisse/users",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e =
          ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => PlaceUser.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<PlaceType>> getPlaceOfWorshipTypes({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint:
          "/types-of-worship?page=$page&size=${AppConstants.PAGING_SIZE}&sort=code%2CASC",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e =
          ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => PlaceType.fromJson(i))
          .toList();
    }
  }

  @override
  void addFavorite(ContentPlace paroisse) {
    log('saveFavorite 2');
    var favorites = getAllFavorites();
    favorites.add(paroisse);
    DB.saveData(AppConstants.KEY_LIST_FAVORITES, jsonEncode(favorites).toString(),);
    log('favorites length => ${favorites.length}');
  }

  @override
  void deleteFavorite(ContentPlace paroisse) {
    log('removeFavorite 2');
    var favorites = getAllFavorites();
    var isRemoved = favorites.remove(paroisse);
    log('isRemoved => $isRemoved');
    if (isRemoved) {
      log('Favoris supprimé');
      DB.saveData(AppConstants.KEY_LIST_FAVORITES, jsonEncode(favorites).toString());
    } else {
      log('Favoris non supprimé');
    }
    log('favorites length => ${favorites.length}');
  }

  @override
  List<ContentPlace> getAllFavorites() {
    return getFavorites(DB.getData(AppConstants.KEY_LIST_FAVORITES));
  }

  List<ContentPlace> getFavorites(String? favoritesToConverted) {
    if (favoritesToConverted != null && favoritesToConverted.isNotEmpty) {
      Iterable l = json.decode(favoritesToConverted);
      return l.map((model) => ContentPlace.fromJson(model)).toList();
    }
    return [];
  }
}
