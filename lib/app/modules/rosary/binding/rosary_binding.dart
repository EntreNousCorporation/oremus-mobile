import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';

class RosaryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RosaryController());
    Get.lazyPut<AudioPlayerService>(() => AudioPlayerService(), fenix: true);
  }
}
