import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/repository/mass_request_claim_repository.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestTrackClaimBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MassRequestTrackClaimController(
        massRequestClaimRepository: MassRequestClaimRepository(ApiClientImpl()),
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
    );
  }
}
