import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_controller.dart';
import 'package:oremusapp/app/modules/donationhistory/data/repository/donation_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DonationHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      DonationHistoryController(
        donationHistoryRepository:
            DonationHistoryRepository(ApiClientImpl()),
        donationRepository: DonationRepository(ApiClientImpl()),
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
    );
  }
}
