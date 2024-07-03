import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';

abstract class IMassRequestClaimRepository {
  //For API
  Future<ClaimResponse> getClaims({int? page = 0, SearchCriteria? searchCriteria});
  Future<List<TypeData>> getClaimTypes({int? page = 0});
  Future<ClaimData> claim(ClaimRequest request);
}
