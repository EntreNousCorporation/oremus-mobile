import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';

abstract class IParoisseRepository {
  Future<PlaceResponse> getParoisses({int? page = 0});
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(int idParoisse);
  Future<List<ActivityResponse>> getActivities(int idParoisse);
  Future<List<MovementResponse>> getMouvements(int idParoisse);
  Future<List<PlaceUser>> getPlaceOfWorshipUsers(int idParoisse);

  //For DB
  void addFavorite(ContentPlace paroisse);
  void deleteFavorite(ContentPlace paroisse);
}
