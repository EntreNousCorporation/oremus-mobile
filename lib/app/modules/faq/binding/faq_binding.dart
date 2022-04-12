import 'package:get/get.dart';
import 'package:oremusapp/app/modules/faq/controller/faq_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class FaqBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(FaqController());
  }
}
