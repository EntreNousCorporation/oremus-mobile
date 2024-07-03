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
import 'package:oremusapp/app/remote/error_response.dart';

class MassRequestHistoryRepository implements IMassRequestHistoryRepository {
  final ApiClient _apiClient;

  MassRequestHistoryRepository(this._apiClient);

  @override
  Future<MassRequestResponse> getMassRequests({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests?page=$page&size=${AppConstants.MASS_REQUEST_PAGING_SIZE}&sort=createdBy%2CDESC${(searchCriteria?.worshipPlace == null) ? '' : '&worshipPlace=${searchCriteria?.worshipPlace}'}${(searchCriteria?.typeOfMassRequest == null || searchCriteria?.typeOfMassRequest?.isEmpty == true) ? '' : '&typeOfMassRequest=${searchCriteria?.typeOfMassRequest}'}${(searchCriteria?.startDate == null || searchCriteria?.startDate?.isEmpty == true) ? '' : '&startDate=${searchCriteria?.startDate}'}${(searchCriteria?.endDate == null || searchCriteria?.endDate?.isEmpty == true) ? '' : '&endDate=${searchCriteria?.endDate}'}",
      method: HttpMethod.get,
      useBearer: true,
    );
    final String resp = json.encode(response.bodyString.toString());
    log('resp => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return MassRequestResponse.fromJson(
          json.decode(response.bodyString.toString()));
    }
  }
}
