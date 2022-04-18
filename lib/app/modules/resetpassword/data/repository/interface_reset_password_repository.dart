
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';

abstract class IResetPasswordRepository {
  Future<Profile> initResetPassword(String username);
  Future<Signin> checkOtp(String username, String otp);
  Future<Signin> resetPassword(Signin request);
}