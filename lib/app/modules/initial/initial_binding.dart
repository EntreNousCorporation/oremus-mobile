import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/services/interaction_zone_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Initialiser le service audio player
    Get.put(AudioPlayerService(), permanent: true);
    Get.put(InteractionZoneService(), permanent: true);
  }
}
