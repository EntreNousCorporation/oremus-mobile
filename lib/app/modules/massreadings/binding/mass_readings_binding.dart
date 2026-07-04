import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massreadings/controller/mass_readings_controller.dart';
import 'package:oremusapp/app/modules/massreadings/data/repository/mass_readings_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassReadingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => MassReadingsController(
        massReadingsRepository: MassReadingsRepository(ApiClientImpl()),
      ),
      fenix: true,
    );
  }
}
