import 'package:get/get.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        ProfileController(
          profileRepository: ProfileRepository(ApiClientImpl()),
          signinRepository: SigninRepository(ApiClientImpl()),
        ),
        permanent: true);
  }
}
