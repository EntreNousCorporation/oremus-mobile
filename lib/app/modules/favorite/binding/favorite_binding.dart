import 'package:get/get.dart';
import 'package:oremusapp/app/modules/favorite/controller/favorite_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
import 'package:oremusapp/app/modules/profile/data/repository/profile_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FavoriteBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        FavoriteController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: false);
  }
}
