import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_controller.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DonationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
        DonationController(
          donationRepository: DonationRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
    );
  }
}
