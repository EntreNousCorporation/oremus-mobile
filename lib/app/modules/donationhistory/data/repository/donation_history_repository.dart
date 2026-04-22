import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donationhistory/data/repository/interface_donation_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/data_response.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class DonationHistoryRepository implements IDonationHistoryRepository {
  final ApiClient _apiClient;

  DonationHistoryRepository(this._apiClient);

  @override
  Future<DataResponse<DonationResponse>> getDonations({
    int? page = 0,
    SearchCriteria? searchCriteria,
  }) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/donations/me?page=$page&size=${AppConstants.MASS_REQUEST_PAGING_SIZE}&sort=updatedAt,desc${(searchCriteria?.worshipPlace == null) ? '' : '&worshipPlace=${searchCriteria?.worshipPlace}'}${(searchCriteria?.typeOfMassRequest == null || searchCriteria?.typeOfMassRequest?.isEmpty == true) ? '' : '&typeOfMassRequest=${searchCriteria?.typeOfMassRequest}'}${(searchCriteria?.startDate == null || searchCriteria?.startDate?.isEmpty == true) ? '' : '&startDate=${searchCriteria?.startDate}'}${(searchCriteria?.endDate == null || searchCriteria?.endDate?.isEmpty == true) ? '' : '&endDate=${searchCriteria?.endDate}'}",
      method: HttpMethod.get,
      useBearer: true,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return DataResponse<DonationResponse>.fromJson(response.data);
    }
  }
}
