import 'package:oremusapp/app/modules/profile/data/model/profile.dart';

abstract class IProfileRepository {
  Future<Profile> getProfile(String userId);
}
