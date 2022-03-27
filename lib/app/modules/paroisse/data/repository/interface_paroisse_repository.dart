import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';

abstract class IParoisseRepository {
  Future<ParoisseResponse> getParoisses({int? page = 0});
}
