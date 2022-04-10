import 'package:get/get.dart';
import 'package:oremusapp/app/modules/editpassword/controller/edit_password_controller.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class EditPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      EditPasswordController(
        profileRepository: ProfileRepository(ApiClientImpl()),
      ),
    );
  }
}
