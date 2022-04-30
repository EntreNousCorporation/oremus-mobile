import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/operation_type_menu.dart';
import 'package:oremusapp/app/modules/service/data/repository/service_repository.dart';

class ServiceController extends GetxController {
  final ServiceRepository serviceRepository;
  var loading = true.obs;
  var showNotificationCount = 0.obs;

  RxList<OperationTypeMenu> operations = RxList<OperationTypeMenu>([]);

  var soldeLoading = false.obs;

  var unlockBackButton = true.obs;

  ServiceController({
    required this.serviceRepository,
  });

  @override
  void onInit() {
    super.onInit();
    initMenus();
  }

  void initMenus() {
    operations.value = [
      OperationTypeMenu(
        isVisble: true,
        title: 'ordinary_transfer'.tr,
        imageSVG: "assets/images/icon_transfert.svg",
        activeTint: colorBlack,
        goToPage: () {},
      ),
      OperationTypeMenu(
        isVisble: true,
        title: 'withdraw'.tr,
        imageSVG: "assets/images/icon_retrait.svg",
        activeTint: colorBlack,
        goToPage: () {},
      ),
      OperationTypeMenu(
        isVisble: true,
        title: 'account_transfer'.tr,
        imageSVG: "assets/images/icon_virement.svg",
        activeTint: colorBlack,
        goToPage: () {},
      ),
    ];

    operations.value = operations.where((element) => element.isVisble).toList();
  }
}
