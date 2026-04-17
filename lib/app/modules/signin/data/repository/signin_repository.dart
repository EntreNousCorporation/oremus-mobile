import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
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

    if (response.statusCode != 200) {
      throw Exception(json.encode(response.data));
    } else {
      return SigninResponse.fromJson(response.data);
    }
  }

  @override
  Future<SigninResponse> devices(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/devices",
      body: request.toJson(),
      method: HttpMethod.post,
      useBearer: false,
    );
    if (response.statusCode! >= 200 && response.statusCode! <= 205) {
      return SigninResponse.fromJson(response.data);
    } else {
      throw Exception(json.encode(response.data));
    }
  }
}
