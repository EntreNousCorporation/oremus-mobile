import 'package:get/get.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';
import 'package:oremusapp/app/modules/pray/data/repository/pray_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class PrayBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => PrayController(prayRepository: PrayRepository(ApiClientImpl())),
      fenix: true,
    );
  }
}
