import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';

abstract class IProfileRepository {
  Future<Profile> getProfile(String userId);
  Future<Profile> updatePassword(Signin request);
  Future<Profile> updateProfile(String userId, Signin request);
  Future<Profile> deleteAccount(String userId);
  Profile? getUserProfile();
  void saveUserProfile(Profile? profile);
}
