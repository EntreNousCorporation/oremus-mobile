import 'package:get/get.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/init_reset_password_controller.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/reset_password_repository.dart';
import 'package:oremusapp/app/modules/signin/controller/signin_controller.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class InitResetPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InitResetPasswordController>(() {
      return InitResetPasswordController(
          resetPasswordRepository: ResetPasswordRepository(ApiClientImpl())
      );
    });
  }
}