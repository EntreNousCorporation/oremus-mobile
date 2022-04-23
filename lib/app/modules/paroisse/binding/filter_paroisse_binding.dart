import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FilterParoisseBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        FilterParoisseController(
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
        permanent: true);
  }
}
