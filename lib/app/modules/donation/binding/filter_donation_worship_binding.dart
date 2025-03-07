import 'package:get/get.dart';
import 'package:oremusapp/app/modules/donation/controller/filter_donation_worship_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FilterDonationWorshipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      FilterDonationWorshipController(
        paroisseRepository: ParoisseRepository(ApiClientImpl()),
      ),
      permanent: true,
    );
  }
}
