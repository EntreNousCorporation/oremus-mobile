import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';

abstract class IMassRequestRepository {
  //For API
  Future<List<TypeData>> getMassRequestType({int? page = 0});
}
