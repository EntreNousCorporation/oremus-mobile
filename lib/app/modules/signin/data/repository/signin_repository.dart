import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/modules/signin/data/repository/interfaces/interface_signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class SigninRepository implements ISigninRepository {

  final ApiClient _apiClient;

  SigninRepository(this._apiClient);

  @override
  Future<SigninResponse> loginUser(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/auth/login",
      body: request.toJson(),
      method: HttpMethod.post,
      useBearer: false,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      log('resp => $resp');
      return SigninResponse.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<SigninResponse> devices(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/devices",
      body: request.toJson(),
      method: HttpMethod.post,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');
    if (response.statusCode! >= 200 && response.statusCode! <= 205) {
      log('resp => $resp');
      return SigninResponse.fromJson(json.decode(response.bodyString.toString()));
    } else {
      throw Exception(resp);
    }
  }
}
