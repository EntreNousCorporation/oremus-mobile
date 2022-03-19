import 'package:get/get.dart';
import 'package:oremusapp/app/modules/signin/controller/signin_controller.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class SigninBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SigninController>(() {
      return SigninController(
        signinRepository: SigninRepository(ApiClientImpl())
      );
    });
  }
}