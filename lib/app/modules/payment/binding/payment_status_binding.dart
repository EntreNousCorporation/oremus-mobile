import 'package:get/get.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_status_controller.dart';

class PaymentStatusBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      PaymentStatusController(),
    );
  }
}
