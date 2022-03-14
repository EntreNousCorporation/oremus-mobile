import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/connexion/data/model/connection.dart';
import 'package:oremusapp/app/modules/connexion/data/model/connection_response.dart';
import 'package:oremusapp/app/modules/connexion/data/repository/interfaces/interface_connexion_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ConnexionRepository implements IConnexionRepository {

  final ApiClient _apiClient;

  ConnexionRepository(this._apiClient);

  @override
  Future<ConnectionResponse> loginUser(Connection request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/auth/login",
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
      return ConnectionResponse.fromJson(json.decode(response.bodyString.toString()));
    }
  }
}
