
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';

abstract class ISignupRepository {
  Future<SigninResponse> signupUser(Signin request);
}