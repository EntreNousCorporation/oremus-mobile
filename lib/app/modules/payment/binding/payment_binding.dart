import 'package:get/get.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_controller.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class PaymentBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      PaymentController(paymentRepository: PaymentRepository(ApiClientImpl())),
    );
  }
}
