import 'dart:convert';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/connexion/data/model/connection_response.dart';
import 'package:oremusapp/app/modules/home/data/model/operation_type_menu.dart';
import 'package:oremusapp/app/modules/home/data/repository/home_repository.dart';
import 'package:oremusapp/main.dart';

class HomeController extends GetxController {
  final HomeRepository homeRepository;
  var loading = true.obs;
  var showNotificationCount = 0.obs;
  var userConnection = ConnectionResponse().obs;

  RxList<OperationTypeMenu> operations = RxList<OperationTypeMenu>([]);

  var soldeLoading = false.obs;

  var unlockBackButton = true.obs;

  HomeController({
    required this.homeRepository,
  });

  @override
  void onInit() {
    super.onInit();
    //getUserInfo();
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

  getUserInfo() {
    var userInfo = encryptedBox.get(AppConstants.USER_LOG_INFOS);
    ConnectionResponse userConnected =
        ConnectionResponse.fromJson(jsonDecode(userInfo));
    userConnection.value = userConnected;
  }
}
