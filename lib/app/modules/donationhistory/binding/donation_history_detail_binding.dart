import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_detail_controller.dart';
import 'package:oremusapp/app/modules/donationhistory/data/repository/donation_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class DonationHistoryDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      DonationHistoryDetailController(
        massRequestHistoryRepository:
            DonationHistoryRepository(ApiClientImpl()),
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
    );
  }
}
