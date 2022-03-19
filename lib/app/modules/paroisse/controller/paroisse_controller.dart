import 'dart:convert';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/operation_type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/main.dart';

class ParoisseController extends GetxController {
  final ParoisseRepository paroisseRepository;
  var loading = true.obs;
  var showNotificationCount = 0.obs;
  var userConnection = SigninResponse().obs;

  RxList<OperationTypeMenu> operations = RxList<OperationTypeMenu>([]);

  var soldeLoading = false.obs;

  var unlockBackButton = true.obs;

  ParoisseController({
    required this.paroisseRepository,
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
    SigninResponse userConnected =
    SigninResponse.fromJson(jsonDecode(userInfo));
    userConnection.value = userConnected;
  }
}
