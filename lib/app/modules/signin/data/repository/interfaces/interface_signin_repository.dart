import 'package:oremusapp/app/modules/signin/data/model/refresh_token_request.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';

abstract class ISigninRepository {
  Future<SigninResponse> loginUser(Signin request);
  Future<SigninResponse> devices(Signin request);
  Future<SigninResponse> refreshToken(RefreshTokenRequest request);
  Future<void> logout(RefreshTokenRequest request);
}