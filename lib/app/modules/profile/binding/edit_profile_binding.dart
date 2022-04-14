import 'package:get/get.dart';
import 'package:oremusapp/app/modules/profile/controller/edit_profile_controller.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class EditProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        EditProfileController(
          profileRepository: ProfileRepository(ApiClientImpl()),
        ));
  }
}
