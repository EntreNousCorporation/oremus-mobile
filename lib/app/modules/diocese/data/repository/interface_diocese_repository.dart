import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';

abstract class IDioceseRepository {
  Future<PlaceResponse> getDioceses({int? page = 0});
}
