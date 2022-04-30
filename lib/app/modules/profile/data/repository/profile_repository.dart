import 'dart:convert';
import 'dart:developer';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/profile/data/repository/interface_profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ProfileRepository implements IProfileRepository {

  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  @override
  Future<Profile> getProfile(String userId) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/$userId",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      //log('resp => $resp');
      return Profile.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<Profile> updatePassword(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/change-password",
      method: HttpMethod.post,
      body: jsonEncode(request.toJson()),
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      return Profile.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<Profile> updateProfile(String userId, Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/fo-agents/$userId",
      method: HttpMethod.put,
      body: jsonEncode(request.toJson()),
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      return Profile.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Profile? getUserProfile() {
    var userProfile = DB.getData(AppConstants.KEY_USER_INFOS);
    if (userProfile != null) {
      return Profile.fromJson(jsonDecode(userProfile));
    }
    return null;
  }

  @override
  void saveUserProfile(Profile? profile) {
    DB.saveData(AppConstants.KEY_USER_INFOS, jsonEncode(profile?.toJson()));
  }
}
