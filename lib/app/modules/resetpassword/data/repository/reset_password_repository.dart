import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/interface_reset_password_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ResetPasswordRepository implements IResetPasswordRepository {

  final ApiClient _apiClient;

  ResetPasswordRepository(this._apiClient);

  @override
  Future<Profile> initResetPassword(String username) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/fo-agents/$username/init-reset-password",
      method: HttpMethod.get,
      useBearer: false,
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
  Future<Signin> checkOtp(String username, String otp) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/fo-agents/check-otp?email=$username&otp=$otp",
      method: HttpMethod.get,
      useBearer: false,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      return Signin.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<Signin> resetPassword(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/fo-agents/reset-password",
      method: HttpMethod.patch,
      body: jsonEncode(request.toJson()),
      useBearer: false,
    );
    log('resp => ${response.statusCode}');

    if (response.statusCode! >= 200 && response.statusCode! <= 204) {
      return Signin(); //Signin.fromJson(json.decode(response.bodyString.toString()));
    } else {
      final String resp = json.encode(response.bodyString.toString());
      throw Exception(resp);
    }
  }
}
