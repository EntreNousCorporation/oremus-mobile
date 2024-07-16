import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';

abstract class IMassRequestRepository {
  //For API
  Future<List<TypeData>> getMassRequestType({int? page = 0});
  Future<PriceResponse> getMassRequestPrice({required List<PriceData> request, required String workshipId});
  Future<List<PrayerIntentData>> getPrayerIntent({int? page = 0});
  Future<MassRequestResponse> sendMassRequest({required MassRequestData request});
}
