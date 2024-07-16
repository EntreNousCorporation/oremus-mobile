import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class PaymentStatusController extends GetxController {

  PaymentStatusController();

  var unlockBackButton = true.obs;
  var subscriptionSelected = MassRequestResponse().obs;
  var paymentStatusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getArguments();
    super.onReady();
  }

  getArguments() {
    if (Get.arguments != null) {
      paymentStatusMessage.value = Get.arguments;
    }
  }

  moveToHome() {
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }
}
