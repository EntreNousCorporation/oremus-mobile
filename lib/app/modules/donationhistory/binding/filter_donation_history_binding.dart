import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/filter_donation_history_controller.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FilterDonationHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      FilterDonationHistoryController(
        massRequestRepository: DonationRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
  }
}
