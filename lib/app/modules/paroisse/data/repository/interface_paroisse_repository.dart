import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/favorite_check_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_type.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/remote/data_response.dart';

abstract class IParoisseRepository {
  //For API
  Future<DataResponse<ContentPlace>> getParoisses({int? page = 0, SearchCriteria? searchCriteria,});
  Future<ContentPlace> getParoisseDetails({int? worshipId = 0});
  Future<List<LiturgicalCelebrationResponse>> getLiturgicalCelebration(int idParoisse);
  Future<List<ActivityResponse>> getActivities(int idParoisse);
  Future<List<MovementResponse>> getMouvements(int idParoisse);
  Future<List<PlaceUser>> getPlaceOfWorshipUsers(int idParoisse);
  Future<List<PlaceType>> getPlaceOfWorshipTypes({int? page = 0});
  Future<List<LiturgicalCelebrationResponse>> getOfficeTimes(int idParoisse);
  Future<List<Contact>> getPlaceOfWorshipContacts(int idParoisse);
  Future<DataResponse<ContentPlace>> getParoissesBySchedule({int? page = 0, required String query});
  Future<List<FavoriteCheckResponse>> getUserFavoritesForPlaces(List<int> worshipPlaceIds);

  //For DB
  List<ContentPlace> getAllFavorites();
  void addFavorite(ContentPlace paroisse);
  void deleteFavorite(ContentPlace paroisse);

  Future<void> syncFavorites();
  Future<DataResponse<ContentPlace>> getServerFavorites();
  Future<bool> addServerFavorite(ContentPlace? paroisse);
  Future<bool> removeServerFavorite(ContentPlace? paroisse);
}
