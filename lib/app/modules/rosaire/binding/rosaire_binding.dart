import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosaire/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosaire/controller/rosaire_controller.dart';
import 'package:oremusapp/app/modules/rosaire/data/repository/rosaire_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class RosaireBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RosaireController(rosaireRepository: RosaireRepository(ApiClientImpl())));
    Get.lazyPut<AudioPlayerService>(() => AudioPlayerService(), fenix: true);
  }
}
