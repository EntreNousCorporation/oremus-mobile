import 'dart:convert';
import 'dart:developer';

import 'package:get/get_connect/connect.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/interface_mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/data_response.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class MassRequestHistoryRepository implements IMassRequestHistoryRepository {
  final ApiClient _apiClient;

  MassRequestHistoryRepository(this._apiClient);

  @override
  Future<DataResponse<MassRequestResponse>> getMassRequests({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests?page=$page&size=${AppConstants.MASS_REQUEST_PAGING_SIZE}&sort=updatedAt,desc${(searchCriteria?.worshipPlace == null) ? '' : '&worshipPlace=${searchCriteria?.worshipPlace}'}${(searchCriteria?.typeOfMassRequest == null || searchCriteria?.typeOfMassRequest?.isEmpty == true) ? '' : '&typeOfMassRequest=${searchCriteria?.typeOfMassRequest}'}${(searchCriteria?.startDate == null || searchCriteria?.startDate?.isEmpty == true) ? '' : '&createdAtStartDate=${searchCriteria?.startDate}'}${(searchCriteria?.endDate == null || searchCriteria?.endDate?.isEmpty == true) ? '' : '&createdAtEndDate=${searchCriteria?.endDate}'}",
      method: HttpMethod.get,
      useBearer: true,
    );
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return DataResponse<MassRequestResponse>.fromJson(
          json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<List<MassRequestStatusData>> getMassRequestsStatus({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests/${searchCriteria?.traceId}/histories?page=$page&size=${AppConstants.MASS_REQUEST_PAGING_SIZE}&sort=createdAt,desc${(searchCriteria?.worshipPlace == null) ? '' : '&worshipPlace=${searchCriteria?.worshipPlace}'}${(searchCriteria?.typeOfMassRequest == null || searchCriteria?.typeOfMassRequest?.isEmpty == true) ? '' : '&typeOfMassRequest=${searchCriteria?.typeOfMassRequest}'}${(searchCriteria?.startDate == null || searchCriteria?.startDate?.isEmpty == true) ? '' : '&startDate=${searchCriteria?.startDate}'}${(searchCriteria?.endDate == null || searchCriteria?.endDate?.isEmpty == true) ? '' : '&endDate=${searchCriteria?.endDate}'}",
      method: HttpMethod.get,
      useBearer: true,
    );
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => MassRequestStatusData.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<MassRequestAvailablesStatusesData>> getMassRequestsAvailablesStatuses({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-request-statutes?page=$page&size=${AppConstants.MASS_REQUEST_STATUSES_PAGING_SIZE}&sort=createdAt,desc",
      method: HttpMethod.get,
      useBearer: true,
    );
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => MassRequestAvailablesStatusesData.fromJson(i))
          .toList();
    }
  }
}
