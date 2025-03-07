import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
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

  var paroisseSelected = ContentPlace().obs;

  var donationSelected = DonationResponse().obs;
  var massRequestResponseSelected = MassRequestResponse().obs;
  var webViewController = Rx<WebViewController>(WebViewController());
  var paymentProcessing = false.obs;
  var paymentStatusMessage = ''.obs;
  var paymentType = PaymentType.none.obs;

  var checkingPaymentStatus = false.obs;
  var isTimerActive = false.obs;
  late Timer timer;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments == null) return;
    Map<String, dynamic> arguments = Get.arguments;
    if (arguments.containsKey('payment_type')) {
      paymentType.value = Get.arguments['payment_type'];
      if (paymentType.value == PaymentType.donation) {
        if (arguments.containsKey('payment_response')) {
          donationSelected.value = DonationResponse.fromJson(Get.arguments['payment_response']);
          initWebview();
        }
      }
      if (paymentType.value == PaymentType.massRequest) {
        if (arguments.containsKey('payment_response')) {
          massRequestResponseSelected.value = MassRequestResponse.fromJson(Get.arguments['payment_response']);
          initWebview();
        }
      }
    }
  }

  moveToError() {
    if (isTimerActive.value == true) {
      timer.cancel();
    }
    Get.offNamed(
      Routes.PAYMENT_ERROR,
      arguments: [
        paroisseSelected.toJson(),
        paymentStatusMessage.value,
      ],
    );
  }

  moveToSuccess() {
    if (isTimerActive.value == true) {
      timer.cancel();
    }
    Get.offNamed(
      Routes.PAYMENT_SUCCESS,
      arguments: [
        paroisseSelected.toJson(),
        paymentStatusMessage.value,
      ],
    );
  }

  doBack() async {
    log('isTimerActive ::: ${isTimerActive.value}');
    if (isTimerActive.value == true) {
      timer.cancel();
    }
    checkingPaymentStatus(true);
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
        onNavigationRequest: (navigation) {
          log('onNavigationRequest URL ::: ${navigation.url}');
          /*counter.value = counter.value + 1;
          _handleInterceptedLink(navigation.url);
          if (counter.value == 100) {
            return NavigationDecision.navigate;
          }*/
          _handleInterceptedLink(navigation.url);
          return NavigationDecision.navigate;
          //return NavigationDecision.prevent;
        },
      ),
    );

    if (massRequestResponseSelected.value.paymentUrl?.isNotEmpty == true) {
      webViewController.value.loadRequest(
          Uri.parse(massRequestResponseSelected.value.paymentUrl ?? ''));
    } else {
      Timer(const Duration(seconds: 1), () {
        showCustomDialog(
          Get.context!,
          message: 'Une erreur interne est survenue',
          positiveCallBack: () {
            Get.back();
          },
        );
      });
    }
  }

  _handleInterceptedLink(String value) async {
    log('_handleInterceptedLink value: $value');
    if (value.contains('wave.com')) {
      var newUrl = value.split('capture/').last;
      log('_handleInterceptedLink newUrl: $newUrl');
      launchWaveOrFallback(newUrl);
      await listenForDeepLink(); //not really usefull for now
    }
  }

  Future<void> listenForDeepLink() async {
    Timer? timeoutTimer;
    StreamSubscription? subscription;
    final appLinks = AppLinks();

    try {
      Completer<void> completer = Completer<void>();

      timeoutTimer = Timer(const Duration(minutes: 5), () {
        completer.completeError(TimeoutException('Délai d\'attente dépassé'));
      });

      // Subscribe to all events (initial link and further)
      subscription = appLinks.uriLinkStream.listen((Uri? uri) {
        log('subscription ::: ${uri.toString()}');
        if (uri != null) {
          //String status = uri.queryParameters['status'] ?? '';
          //String transactionId = uri.queryParameters['transactionId'] ?? '';
          //handlePaymentResult(status, transactionId);
          completer.complete();
        }
      });

      await completer.future;
    } catch (e) {
      // Gérer les erreurs (timeout, erreurs de liens profonds, etc.)
      timeoutTimer?.cancel();
      await subscription?.cancel();
      print('Erreur lors de l\'attente du retour de paiement: $e');
    } finally {
      timeoutTimer?.cancel();
      await subscription?.cancel();
    }
  }

  Future<void> launchWaveOrFallback(String waveUrl) async {
    if (await canLaunchUrl(Uri.parse(waveUrl))) {
      await launchUrl(Uri.parse(waveUrl), mode: LaunchMode.externalNonBrowserApplication);
    } else {
      // L'application Wave n'est pas installée
      // Redirigez l'utilisateur vers le site Web de Wave ou affichez un message
      showCustomDialog(Get.context!,
          title: 'Application Wave non trouvée',
          message: 'Veuillez installer l\'application Wave pour continuer.');
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
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      doGetPaymentStatus();
    });
  }

  //CHECK PAYMENT STATUS
  doGetPaymentStatus() {
    if (checkingPaymentStatus.value == true) {
      return;
    }

    log('request doGetPaymentStatus :::');

    checkingPaymentStatus(true);
    paymentRepository.paymentStatus(transactionId: massRequestResponseSelected.value.transactionId ?? '').then((value) {
      if (value.paymentStatus == PaymentStatus.REFUSED.name) {
        checkingPaymentStatus(true);
        paymentStatusMessage.value = 'Le paiement a échoué. Veuillez réessayer svp !';
        moveToError();
        return;
      }
      if (value.paymentStatus == PaymentStatus.PENDING.name) {
        checkingPaymentStatus(false);
        return;
      }

      //ACCEPTED
      checkingPaymentStatus(true);
      switch (paymentType.value) {
        case PaymentType.massRequest:
          paymentStatusMessage.value = 'Votre demande de messe a été effectué avec succès';
          break;
        case PaymentType.donation:
          paymentStatusMessage.value = 'Votre don a été effectué avec succès';
          break;
        case PaymentType.none:
          paymentStatusMessage.value = 'Payment effectué avec succès';
          break;
      }
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
