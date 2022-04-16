import 'dart:convert';
import 'dart:developer';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/interface_paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ParoisseRepository implements IParoisseRepository {

  final ApiClient _apiClient;

  ParoisseRepository(this._apiClient);

  @override
  Future<PlaceResponse> getParoisses({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/places-of-worship?page=$page&size=${AppConstants.PAGING_SIZE}",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      //log('resp => $resp');
      return PlaceResponse.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(int idParoisse) async {
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
      return (jsonDecode(response.bodyString.toString()) as List).map((i) => LiturgicalCelebrationResponse.fromJson(i)).toList();
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
      return (jsonDecode(response.bodyString.toString()) as List).map((i) => ActivityResponse.fromJson(i)).toList();
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
      return (jsonDecode(response.bodyString.toString()) as List).map((i) => MovementResponse.fromJson(i)).toList();
    }
  }
}
