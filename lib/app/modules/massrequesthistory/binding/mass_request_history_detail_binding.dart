import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_detail_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestHistoryDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MassRequestHistoryDetailController(
        massRequestHistoryRepository:
            MassRequestHistoryRepository(ApiClientImpl()),
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
    );
  }
}
