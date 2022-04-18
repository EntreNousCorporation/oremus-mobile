import 'package:get/get.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/otp_controller.dart';
import 'package:oremusapp/app/modules/resetpassword/data/repository/reset_password_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class OtpBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() {
      return OtpController(
          resetPasswordRepository: ResetPasswordRepository(ApiClientImpl())
      );
    });
  }
}