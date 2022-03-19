
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';

abstract class ISigninRepository {
  Future<SigninResponse> loginUser(Signin request);
}