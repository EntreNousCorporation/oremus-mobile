import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/interface_mass_request_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class MassRequestRepository implements IMassRequestRepository {
  final ApiClient _apiClient;

  MassRequestRepository(this._apiClient);

  @override
  Future<List<TypeData>> getMassRequestType({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/types-of-mass-request?page=$page&size=${AppConstants.PAGING_SIZE_1000}&sort=code%2CASC",
      method: HttpMethod.get,
    );
    log('resp getParoisses => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => TypeData.fromJson(i))
          .toList();
    }
  }
}
