import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donationhistory/data/repository/donation_history_repository.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class DonationHistoryDetailController extends GetxController {
  final DonationHistoryRepository massRequestHistoryRepository;
  final ParoisseRepository paroisseRepository;

  DonationHistoryDetailController({
    required this.massRequestHistoryRepository,
    required this.paroisseRepository,
  });

  var unlockBackButton = true.obs;

  var isDataProcessing = false.obs;
  var hasData = false.obs;
  var hasError = false.obs;
  var isLiked = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var donationSelected = DonationResponse().obs;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments == null) return;
    Map<String, dynamic> arguments = Get.arguments;
    if (arguments.containsKey('paroisseSelected')) {
      paroisseSelected.value = ContentPlace.fromJson(arguments['paroisseSelected']);
    }
    if (arguments.containsKey('donationResponse')) {
      donationSelected.value = DonationResponse.fromJson(arguments['donationResponse']);
      donationSelected.value.bookings?.sort((a, b) => a.day!.compareTo(b.day!));
      log('donationSelected ::: ${jsonEncode(donationSelected.toJson())}');
    }
  }

  moveToDonation(DonationResponse? donationData) {
    Get.toNamed(
      Routes.DONATION,
      arguments: [
        paroisseSelected.toJson(),
        donationData?.toJson(),
      ],
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  canRedoDonation() {
    return donationSelected.value.status?.code == 'REQUEST_ACCEPTED' || donationSelected.value.status?.code == 'ACCEPTED_PAYMENT' || donationSelected.value.status?.code == 'REQUEST_REFUSED' || donationSelected.value.status?.code == 'REFUSED_PAYMENT';
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
      arguments: paroisseSelected.toJson(),
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
