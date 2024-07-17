import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

class FilterMassRequestDateBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      FilterMassRequestDateController(),
      permanent: true,
    );
  }
}
