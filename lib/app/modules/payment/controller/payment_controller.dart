import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentController extends GetxController {
  PaymentRepository paymentRepository;

  PaymentController({
    required this.paymentRepository,
  });

  var unlockBackButton = true.obs;
  var hasError = false.obs;
  var lockScreen = false.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var massRequestResponseSelected = MassRequestResponse().obs;
  var webViewController = Rx<WebViewController>(WebViewController());
  var paymentProcessing = false.obs;
  var paymentStatusMessage = ''.obs;

  var checkingPaymentStatus = false.obs;
  var isTimerActive = false.obs;
  late Timer timer;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      massRequestResponseSelected.value = MassRequestResponse.fromJson(Get.arguments);
      initWebview();
    }
  }

  moveToError() {
    if (isTimerActive.value == true) {
      timer.cancel();
    }
    Get.offAllNamed(
      Routes.PAYMENT_ERROR,
      arguments: paymentStatusMessage.value,
    );
  }

  moveToSuccess() {
    if (isTimerActive.value == true) {
      timer.cancel();
    }
    Get.offAllNamed(
      Routes.PAYMENT_SUCCESS,
      arguments: paymentStatusMessage.value,
    );
  }

  moveToHome() {
    Get.offAllNamed(Routes.CUSTOM_HOME);
  }

  doBack() async {
    log('isTimerActive ::: ${isTimerActive.value}');
    if (isTimerActive.value == true) {
      timer.cancel();
    }
    Get.back();
  }

  initWebview() {
    webViewController.value.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.value.setBackgroundColor(colorTransparent);
    webViewController.value.enableZoom(false);
    webViewController.value.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          log('WebView is loading (progress : $progress%)');
        },
        onPageStarted: onPageStarted,
        onPageFinished: onPageFinished,
        onWebResourceError: onWebResourceError,
      ),
    );

    if (massRequestResponseSelected.value.paymentUrl?.isNotEmpty ==
        true) {
      webViewController.value.loadRequest(Uri.parse(
          massRequestResponseSelected.value.paymentUrl ?? ''));
    } else {
      showCustomDialog(
        Get.context!,
        message: 'Une erreur interne est survenue',
        positiveCallBack: () {
          Get.back();
        },
      );
    }
  }

  onPageStarted(String value) {
    isDataProcessing(true);
    log('Page started loading: $value');
  }

  onPageFinished(String value) {
    isDataProcessing(false);
    log('Page finished loading: $value');
    listenPaymentStatus();
  }

  onWebResourceError(WebResourceError webResourceError) {
    isDataProcessing(false);
    log('Page finished errorCode: ${webResourceError.errorCode}');
    log('Page finished description: ${webResourceError.description}');
    log('Page finished errorType: ${webResourceError.errorType}');
  }

  listenPaymentStatus() {
    log('request listenPaymentStatus');
    isTimerActive(true);
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      doGetPaymentStatus();
    });
  }

  //CHECK PAYMENT STATUS
  doGetPaymentStatus() {
    if (checkingPaymentStatus.isTrue) {
      return;
    }

    log('request doGetPaymentStatus :::');

    checkingPaymentStatus(true);
    paymentRepository.paymentStatus(transactionId: massRequestResponseSelected.value.transactionId ?? '').then((value) {
      if (value.status == 'REFUSED') {
        checkingPaymentStatus(true);
        moveToError();
        return;
      }
      if (value.status == 'PENDING') {
        checkingPaymentStatus(false);
        return;
      }
      //ACCEPTED
      checkingPaymentStatus(true);
      paymentStatusMessage.value = 'Votre demande de messe a été effectué avec succès';
      moveToSuccess();
    }, onError: (error) {
      checkingPaymentStatus(false);
      var err = error as CustomException;
      log(err.message.toString());
      showNotification(message: err.message ?? 'Une erreur interne est survenue');
      log('doGetPaymentStatus onError ::: ${err.message ?? 'label_error_unknow_server'.tr}');
      //paymentStatusMessage.value = err.message.toString();
      //moveToError();
    });
  }
}
