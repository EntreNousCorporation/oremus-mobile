import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class PaymentStatusController extends GetxController {

  PaymentStatusController();

  var unlockBackButton = true.obs;
  var subscriptionSelected = MassRequestResponse().obs;
  var paymentStatusMessage = ''.obs;
  var paroisseSelected = ContentPlace().obs;
  var paymentType = PaymentType.none.obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments == null) return;
    Map<String, dynamic> arguments = Get.arguments;
    if (arguments.containsKey('payment_type')) {
      paymentType.value = Get.arguments['payment_type'];
    }
    if (arguments.containsKey('paroisse_selected')) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments['paroisse_selected']);
    }
    if (arguments.containsKey('payment_status_message')) {
      paymentStatusMessage.value = arguments['payment_status_message'];
    }
    OremusLogger.debug('massRequestData 333 ::: ${paroisseSelected.toJson()}');
  }

  doRedirection() {
    switch (paymentType.value) {
      case PaymentType.massRequest:
        moveToMassRequestHistory();
        break;
      case PaymentType.donation:
        moveToDonationHistory();
        break;
      case PaymentType.none:
        break;
    }
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  moveToMassRequestHistory() {
    if (Get.isRegistered<MassRequestHistoryController>()) {
      Get.find<MassRequestHistoryController>().refreshData();
    }

    Get.offNamed(
      Routes.MASS_REQUEST_HISTORY,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'can_go_to_home': true,
      },
    );
  }

  moveToDonationHistory() async {
    if (Get.isRegistered<DonationHistoryController>()) {
      Get.find<DonationHistoryController>().refreshData();
    }
    Get.offNamed(
      Routes.DONATION_HISTORY,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'can_go_to_home': true,
      },
    );
  }
}
