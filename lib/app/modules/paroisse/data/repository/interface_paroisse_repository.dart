import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/paroisse_response.dart';

abstract class IParoisseRepository {
  Future<PlaceResponse> getParoisses({int? page = 0});
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(int idParoisse);
}
