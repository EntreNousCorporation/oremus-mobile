import 'package:get/get.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/data/repository/life_plan_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class LifePlanBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LifePlanController>(() => LifePlanController(
        lifePlanRepository: LifePlanRepository(ApiClientImpl()),
      ),
      fenix: true,
    );
  }
}
