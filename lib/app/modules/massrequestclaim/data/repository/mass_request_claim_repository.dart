import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/interface_mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/data_response.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class MassRequestClaimRepository implements IMassRequestClaimRepository {
  final ApiClient _apiClient;

  MassRequestClaimRepository(this._apiClient);

  @override
  Future<ClaimData> claim(ClaimRequest request) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/claims",
      body: request.toJson(),
      method: HttpMethod.post,
    );

    if (response.statusCode! >= 200 && response.statusCode! <= 205) {
      return ClaimData.fromJson(response.data);
    } else {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    }
  }

  @override
  Future<DataResponse<ClaimData>> getClaims({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/claims?page=$page&size=${AppConstants.MASS_REQUEST_PAGING_SIZE}&sort=createdAt,desc${(searchCriteria?.worshipPlace == null) ? '' : '&worshipPlace=${searchCriteria?.worshipPlace}'}${(searchCriteria?.typeOfClaim == null || searchCriteria?.typeOfClaim?.isEmpty == true) ? '' : '&typeOfClaim=${searchCriteria?.typeOfClaim}'}",
      method: HttpMethod.get,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return DataResponse<ClaimData>.fromJson(response.data);
    }
  }

  @override
  Future<List<TypeData>> getClaimTypes({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/types-of-claim?page=$page&size=${AppConstants.PAGING_SIZE_1000}&sort=code%2CASC",
      method: HttpMethod.get,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => TypeData.fromJson(i))
          .toList();
    }
  }
}
