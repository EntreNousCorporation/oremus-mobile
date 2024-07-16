import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/remote/data_response.dart';

abstract class IDioceseRepository {
  Future<DataResponse<ContentPlace>> getDioceses({int? page = 0});
}
