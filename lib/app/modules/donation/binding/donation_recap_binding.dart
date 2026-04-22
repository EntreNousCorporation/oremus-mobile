import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_recap_controller.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DonationRecapBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      DonationRecapController(
          donationRepository: DonationRepository(ApiClientImpl()),
          paymentRepository: PaymentRepository(ApiClientImpl()),
        ),
    );
  }
}
