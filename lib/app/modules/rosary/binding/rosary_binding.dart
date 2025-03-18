import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/data/repository/rosary_repository.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class RosaryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RosaryController(rosaireRepository: RosaryRepository(ApiClientImpl())));
    Get.lazyPut<AudioPlayerService>(() => AudioPlayerService(), fenix: true);
  }
}
