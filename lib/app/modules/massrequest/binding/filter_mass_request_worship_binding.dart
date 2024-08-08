import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_worship_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FilterMassRequestWorshipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      FilterMassRequestWorshipController(
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
  }
}
