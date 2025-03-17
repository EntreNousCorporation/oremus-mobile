import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';

abstract class IRosaireRepository {
  //For API
  Future<List<Prayer>> getPrayers({int? page = 0});
}
