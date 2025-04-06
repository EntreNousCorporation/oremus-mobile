import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/data_response.dart';

abstract class IMassRequestHistoryRepository {
  //For API
  Future<DataResponse<MassRequestResponse>> getMassRequests({int? page = 0, SearchCriteria? searchCriteria});
  Future<List<MassRequestStatusData>> getMassRequestsStatus({int? page = 0, SearchCriteria? searchCriteria});
  Future<List<MassRequestAvailablesStatusesData>> getMassRequestsAvailablesStatuses({int? page = 0});
}
