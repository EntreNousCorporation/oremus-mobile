import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/modules/signup/data/repository/interfaces/interface_signup_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class SignupRepository implements ISignupRepository {

  final ApiClient _apiClient;

  SignupRepository(this._apiClient);

  @override
  Future<SigninResponse> signupUser(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/fo-agents",
      body: request.toJson(),
      method: HttpMethod.post,
      useBearer: false,
    );
    log('resp => ${response.statusCode}');

    if (response.statusCode! >= 200 && response.statusCode! <= 205) {
      return SigninResponse.fromJson(json.decode(response.bodyString.toString()));
    } else {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(response.statusCode, e.status);
      //throw Exception(resp);
    }
  }
}
