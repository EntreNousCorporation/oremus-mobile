import 'package:get/get.dart';
import 'package:oremusapp/app/modules/diocese/data/repository/diocese_repository.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/filter_mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FilterMassRequestHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      FilterMassRequestHistoryController(
        massRequestRepository: MassRequestRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
  }
}
