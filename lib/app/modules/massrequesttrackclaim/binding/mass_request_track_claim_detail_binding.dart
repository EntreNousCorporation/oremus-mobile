import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_detail_controller.dart';

class MassRequestTrackClaimDetialsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MassRequestTrackClaimDetailController(),
    );
  }
}
