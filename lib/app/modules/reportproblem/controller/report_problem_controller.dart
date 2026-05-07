import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/reportproblem/data/model/report_problem_data.dart';
import 'package:oremusapp/app/modules/reportproblem/data/repository/report_problem_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class ReportProblemController extends GetxController {
  final ReportProblemRepository reportProblemRepository;

  ReportProblemController({
    required this.reportProblemRepository,
  });

  var unlockBackButton = true.obs;

  var isReportProblemTypeProcessing = false.obs;
  var hasData = false.obs;

  var emailController = TextEditingController();
  var descriptionController = TextEditingController();

  RxList<ReportProblemTypeData?> reportProblemTypes = RxList<ReportProblemTypeData?>([]);
  Rx<ReportProblemTypeData?> reportProblemTypeSelected = Rx<ReportProblemTypeData?>(null);

  var paroisseSelected = ContentPlace().obs;
  var isValidForm = false.obs;

  @override
  void onInit() {
    getArguments();
    doGetReportProblemTypes();
    super.onInit();
  }

  @override
  void dispose() {
    emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments);
    }
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  void checkForm() {
    isValidForm.value = reportProblemTypeSelected.value != null &&
        descriptionController.text.trim().isNotEmpty &&
        emailController.text.isNotEmpty && GetUtils.isEmail(emailController.text);
  }

  updateReportProblemTypeFilter(ReportProblemTypeData? typeData) {
    reportProblemTypeSelected.value = typeData;
    checkForm();
  }

  doGetReportProblemTypes() {
    hideKeyboard();

    isReportProblemTypeProcessing(true);
    hasData(false);
    log('request doGetReportProblemTypes :::');

    reportProblemRepository.getReportProblemTypes().then((value) {
      isReportProblemTypeProcessing(false);
      hasData(true);
      reportProblemTypes.value = value;
    }, onError: (error) {
      isReportProblemTypeProcessing(false);
      hasData(false);
      if (error is! CustomException) return;
      final err = error;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else if (err.code == 900) {
        log('Error doGetReportProblemTypes ::: ${err.message.toString()}');
      }
      debugPrint("Error doGetReportProblemTypes => ${error.toString()}");
    });
  }

  doSendReportProblem() {
    hideKeyboard();
    EasyLoading.show(
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = ReportProblemData(
      description: descriptionController.text.trim(),
      email: emailController.text.trim(),
      worshipPlaceId: paroisseSelected.value.identifier,
      reportProblemTypeId: reportProblemTypeSelected.value?.identifier,
    );

    log('request doSendReportProblem => ${jsonEncode(request.toJson())}');

    reportProblemRepository.reportProblem(request: request).then((value) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      resetForm();
      showCustomDialog(
        Get.context!,
        message: 'Merci d\'avoir pris le temps de signaler ce souci. Votre demande a bien été envoyée.',
      );
    }, onError: (error) {
      EasyLoading.dismiss(animation: true).then((v) {
        unlockBackButton.value = true;
      });
      debugPrint("error => ${error.toString()}");
      if (error is! CustomException) return;
      final err = error;
      if (err.code == 401) {
        showCustomDialog(
          Get.context!,
          message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
        ).then((value) {
          doLogout();
        });
      } else {
        showNotification(
            message: err.message.toString(),
            duration: const Duration(seconds: 4));
      }
    });
  }

  resetForm() {
    reportProblemTypeSelected.value = null;
    descriptionController.clear();
    emailController.clear();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
