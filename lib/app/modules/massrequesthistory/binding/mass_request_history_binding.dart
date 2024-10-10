import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MassRequestHistoryController(
        massRequestHistoryRepository:
            MassRequestHistoryRepository(ApiClientImpl()),
        massRequestRepository: MassRequestRepository(ApiClientImpl()),
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
    );
  }
}
