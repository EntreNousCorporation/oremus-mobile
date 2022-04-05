import 'dart:convert';
import 'dart:developer';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/interface_diocese_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DioceseRepository implements IDioceseRepository {

  final ApiClient _apiClient;

  DioceseRepository(this._apiClient);

  @override
  Future<PlaceResponse> getDioceses({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/dioceses?page=$page&size=${AppConstants.PAGING_SIZE}",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      log('resp => $resp');
      return PlaceResponse.fromJson(json.decode(response.bodyString.toString()));
    }
  }
}
