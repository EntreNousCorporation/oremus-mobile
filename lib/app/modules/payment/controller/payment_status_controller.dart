import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class PaymentStatusController extends GetxController {

  PaymentStatusController();

  var unlockBackButton = true.obs;
  var subscriptionSelected = MassRequestResponse().obs;
  var paymentStatusMessage = ''.obs;
  var paroisseSelected = ContentPlace().obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[0]);
      paymentStatusMessage.value = Get.arguments[1];
    }
  }

  moveToHome() {
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }

  moveToMassRequestHistory() async {
    await Get.offNamed(
      Routes.MASS_REQUEST_HISTORY,
      arguments: paroisseSelected.toJson(),
    );
  }
}
