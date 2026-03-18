import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_recap_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassRequestRecapBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      MassRequestRecapController(
          massRequestRepository: MassRequestRepository(ApiClientImpl()),
          paymentRepository: PaymentRepository(ApiClientImpl()),
        ),
    );
  }
}
