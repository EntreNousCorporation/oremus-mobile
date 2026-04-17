import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';
import 'package:oremusapp/app/modules/pray/data/repository/interface_pray_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class PrayRepository implements IPrayRepository {
  final ApiClient _apiClient;

  PrayRepository(this._apiClient);

  @override
  Future<List<Prayer>> getPrayers({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/specific-prayers?page=$page&size=${AppConstants.PRAY_PAGING_SIZE}&sort=ASC",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      throw Exception(json.encode(response.data));
    } else {
      return (response.data as List)
          .map((i) => Prayer.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<Prayer>> getCustomPrayers({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/customary-prayers?page=$page&size=${AppConstants.PRAY_PAGING_SIZE}&sort=ASC",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      throw Exception(json.encode(response.data));
    } else {
      return (response.data as List)
          .map((i) => Prayer.fromJson(i))
          .toList();
    }
  }
}
