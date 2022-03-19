import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/modules/signup/data/repository/interfaces/interface_signup_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class SignupRepository implements ISignupRepository {

  final ApiClient _apiClient;

  SignupRepository(this._apiClient);

  @override
  Future<SignupResponse> signupUser(Signin request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/fo-agents",
      body: jsonEncode(request.toJson()),
      method: HttpMethod.post,
      useBearer: false,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      log('resp => $resp');
      return SignupResponse.fromJson(json.decode(response.bodyString.toString()));
    }
  }
}
