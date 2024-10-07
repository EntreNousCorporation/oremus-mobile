import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class MassRequestTrackClaimDetailController extends GetxController {

  MassRequestTrackClaimDetailController();

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var claimSelected = Rx<ClaimData?>(null);
  var paroisseSelected = ContentPlace().obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[0]);
      claimSelected.value = ClaimData.fromJson(Get.arguments[1]);
    }
  }
}
