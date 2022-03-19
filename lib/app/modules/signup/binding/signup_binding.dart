import 'package:get/get.dart';
import 'package:oremusapp/app/modules/signup/controller/signup_controller.dart';
import 'package:oremusapp/app/modules/signup/data/repository/signup_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class SignupBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() {
      return SignupController(
        signupRepository: SignupRepository(ApiClientImpl())
      );
    });
  }
}