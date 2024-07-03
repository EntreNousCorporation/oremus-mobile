import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';

abstract class IMassRequestHistoryRepository {
  //For API
  Future<MassRequestResponse> getMassRequests({int? page = 0, SearchCriteria? searchCriteria});
}
