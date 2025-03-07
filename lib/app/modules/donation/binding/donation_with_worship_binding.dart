import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_with_worship_controller.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DonationWithWorshipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      DonationWithWorshipController(
          donationRepository: DonationRepository(ApiClientImpl()),
          paroisseRepository: ParoisseRepository(ApiClientImpl()),
        ),
    );
  }
}
