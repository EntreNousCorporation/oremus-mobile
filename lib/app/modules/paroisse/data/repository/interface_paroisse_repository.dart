import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';

abstract class IParoisseRepository {
  Future<PlaceResponse> getParoisses({
    int? page = 0,
    SearchCriteria? searchCriteria,
  });
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(
      int idParoisse);
  Future<List<ActivityResponse>> getActivities(int idParoisse);
  Future<List<MovementResponse>> getMouvements(int idParoisse);
  Future<List<PlaceUser>> getPlaceOfWorshipUsers(int idParoisse);
  Future<List<PlaceType>> getPlaceOfWorshipTypes({int? page = 0});

  //For DB
  void addFavorite(ContentPlace paroisse);
  void deleteFavorite(ContentPlace paroisse);
}
