import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequestclaim/controller/mass_request_claim_controller.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestClaimBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        MassRequestClaimController(
          massRequestClaimRepository: MassRequestClaimRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ));
  }
}
