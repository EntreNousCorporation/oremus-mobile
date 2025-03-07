import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/data_response.dart';

abstract class IDonationHistoryRepository {
  //For API
  Future<DataResponse<DonationResponse>> getDonations({int? page = 0, SearchCriteria? searchCriteria});
}
