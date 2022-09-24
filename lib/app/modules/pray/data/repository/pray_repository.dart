import 'dart:convert';
import 'dart:developer';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';
import 'package:oremusapp/app/modules/pray/data/repository/interface_pray_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class PrayRepository implements IPrayRepository {
  final ApiClient _apiClient;

  PrayRepository(this._apiClient);

  @override
  Future<List<Prayer>> getPrayers({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      //endpoint: "/specific-prayers?page=$page&size=${AppConstants.PAGING_SIZE}&sort=ASC",
      endpoint: "/specific-prayers?page=$page&size=50&sort=ASC",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(resp);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => Prayer.fromJson(i))
          .toList();
    }
  }
}
