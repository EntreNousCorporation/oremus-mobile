import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_file_manager_service.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/services/interaction_zone_service.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // Services
    Get.put(AudioPlayerService(), permanent: true);
    Get.put(InteractionZoneService(), permanent: true);
    Get.put<AudioFileManagerService>(AudioFileManagerService(), permanent: true);

  }
}
