import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';

abstract class IRosaryRepository {
  //For API
  Future<List<Prayer>> getPrayers({int? page = 0});
}
