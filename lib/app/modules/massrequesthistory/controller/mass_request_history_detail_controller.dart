import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/data/repository/mass_request_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class MassRequestHistoryDetailController extends GetxController {
  final MassRequestHistoryRepository massRequestHistoryRepository;
  final ParoisseRepository paroisseRepository;

  MassRequestHistoryDetailController({
    required this.massRequestHistoryRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var isLiked = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var massRequestSelected = MassRequestResponse().obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments[0]);
      massRequestSelected.value = MassRequestResponse.fromJson(Get.arguments[1]);
    }
  }

  moveToMassRequest(MassRequestResponse massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData.toJson(),
      ],
    );
  }

  moveToMassRequestClaims(MassRequestResponse massRequestData) {
    Get.toNamed(
      Routes.MASS_REQUEST_CLAIM,
      arguments: [
        paroisseSelected.toJson(),
        massRequestData.toJson(),
      ],
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }

  canClaimMassRequest() {
    return massRequestSelected.value.status?.code == 'REQUEST_ACCEPTED' || massRequestSelected.value.status?.code == 'ACCEPTED_PAYMENT' || massRequestSelected.value.status?.code == 'REQUEST_REFUSED' || massRequestSelected.value.status?.code == 'REFUSED_PAYMENT';
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  bool isWorshipPlaceFavorite(ContentPlace paroisse) {
    var isFavorite = false;
    var favorites = paroisseRepository.getAllFavorites();
    var hasParoisse = favorites
        .indexWhere((element) => element.identifier == paroisse.identifier);
    if (hasParoisse != -1) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }
    return isFavorite;
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: paroisseSelected.value.toJson(),
    );
  }

  saveFavorite(ContentPlace paroisse, bool state) {
    log('saveFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.addFavorite(paroisse);
  }

  removeFavorite(ContentPlace paroisse, bool state) {
    log('removeFavorite 1 => ${paroisse.isFavorite}');
    paroisseRepository.deleteFavorite(paroisse);
  }
}
