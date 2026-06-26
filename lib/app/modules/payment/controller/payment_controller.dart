import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/modules/payment/utils/payment_url_utils.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentController extends GetxController {
  PaymentRepository paymentRepository;

  PaymentController({required this.paymentRepository});

  var unlockBackButton = true.obs;
  var hasError = false.obs;
  var lockScreen = false.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var paroisseSelected = ContentPlace().obs;
  var paymentMethodSelected = PaymentMethodData().obs;

  var donationSelected = DonationResponse().obs;
  var massRequestResponseSelected = MassRequestResponse().obs;
  // Lazy : la construction d'un `WebViewController` requiert que
  // `WebViewPlatform.instance` soit set, ce qui n'est pas le cas en unit
  // test. On ne paie le coût qu'au 1er accès (= au build de l'écran).
  late final Rx<WebViewController> webViewController =
      Rx<WebViewController>(WebViewController());
  var paymentProcessing = false.obs;
  var paymentStatusMessage = ''.obs;
  var paymentType = PaymentType.none.obs;

  var checkingPaymentStatus = false.obs;
  var isTimerActive = false.obs;
  Timer? _timer;

  Rx<int> manualVerifyCount = Rx<int>(0);
  var manualVerify = false.obs;
  final int checkPaymentStatusInterval = 5;
  final String waveCode = 'WAVE';

  @override
  void onInit() {
    _getArguments();
    super.onInit();
  }

  _getArguments() {
    if (Get.arguments == null) return;
    Map<String, dynamic> arguments = Get.arguments;
    if (arguments.containsKey('paroisse_selected') && arguments['paroisse_selected'] != null) {
      paroisseSelected.value = ContentPlace.fromJson(arguments['paroisse_selected']);
    }
    if (arguments.containsKey('payment_method_selected') && arguments['payment_method_selected'] != null) {
      paymentMethodSelected.value = PaymentMethodData.fromJson(arguments['payment_method_selected']);
    }
    if (arguments.containsKey('payment_type')) {
      paymentType.value = Get.arguments['payment_type'];
      if (paymentType.value == PaymentType.donation) {
        if (arguments.containsKey('payment_response')) {
          donationSelected.value = DonationResponse.fromJson(arguments['payment_response']);
          _initWebview();
        }
      }
      if (paymentType.value == PaymentType.massRequest) {
        if (arguments.containsKey('payment_response')) {
          massRequestResponseSelected.value = MassRequestResponse.fromJson(arguments['payment_response']);
          _initWebview();
        }
      }
    }
  }

  @visibleForTesting
  @protected
  moveToError() {
    _timer?.cancel();
    Get.offNamed(
      Routes.PAYMENT_ERROR,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'payment_status_message': paymentStatusMessage.value,
        'payment_type': paymentType.value,
      },
    );
  }

  @visibleForTesting
  @protected
  moveToSuccess() {
    _timer?.cancel();
    Get.offNamed(
      Routes.PAYMENT_SUCCESS,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'payment_status_message': paymentStatusMessage.value,
        'payment_type': paymentType.value,
      },
    );
  }

  @visibleForTesting
  @protected
  void moveToProcessing() {
    _timer?.cancel();
    Get.toNamed(
      Routes.PAYMENT_PROCESSING,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'payment_type': paymentType.value,
      },
    );
  }

  doBack() async {
    _timer?.cancel();
    checkingPaymentStatus(true);
    Get.back();
  }

  _initWebview() {
    webViewController.value.setJavaScriptMode(JavaScriptMode.unrestricted);
    webViewController.value.setBackgroundColor(colorTransparent);
    webViewController.value.enableZoom(false);
    webViewController.value.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          OremusLogger.info('WebView is loading (progress : $progress%)');
        },
        onPageStarted: _onPageStarted,
        onPageFinished: _onPageFinished,
        onWebResourceError: _onWebResourceError,
        onNavigationRequest: (navigation) {
          if (PaymentUrlUtils.isExternalAppUrl(navigation.url)) {
            _handleInterceptedLink(navigation.url);
            isDataProcessing(false);
            _listenPaymentStatus();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    if (massRequestResponseSelected.value.paymentUrl?.isNotEmpty == true) {
      webViewController.value.loadRequest(
        Uri.parse(massRequestResponseSelected.value.paymentUrl ?? ''),
      );
    } else if (donationSelected.value.paymentUrl?.isNotEmpty == true) {
      webViewController.value.loadRequest(
        Uri.parse(donationSelected.value.paymentUrl ?? ''),
      );
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
    OremusLogger.info('_handleInterceptedLink value: $value');
    if (value.contains('wave.com')) {
      var newUrl = PaymentUrlUtils.extractWaveCaptureUrl(value);
      OremusLogger.info('_handleInterceptedLink newUrl: $newUrl');
      _launchWaveOrFallback(newUrl);
      await _listenForDeepLink(); //not really usefull for now
    }
  }

  Future<void> _listenForDeepLink() async {
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
        OremusLogger.info('subscription ::: ${uri.toString()}');
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
      OremusLogger.info('Erreur lors de l\'attente du retour de paiement: $e');
    } finally {
      timeoutTimer?.cancel();
      await subscription?.cancel();
    }
  }

  Future<void> _launchWaveOrFallback(String waveUrl) async {
    try {
      final launched = await launchUrl(
        Uri.parse(waveUrl),
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        _showWaveNotInstalledDialog();
      }
    } catch (e) {
      OremusLogger.info('Wave app launch failed: $e');
      _showWaveNotInstalledDialog();
    }
  }

  void _showWaveNotInstalledDialog() {
    showCustomDialog(
      Get.context!,
      title: 'Application Wave non trouvée',
      message: 'Veuillez installer l\'application Wave pour continuer.',
      positiveCallBack: () {
        Get.back();
        //Get.back();
      }
    );
  }

  _onPageStarted(String value) {
    isDataProcessing(true);
    OremusLogger.info('Page started loading: $value');
  }

  _onPageFinished(String value) {
    isDataProcessing(false);
    OremusLogger.info('Page finished loading: $value');
    if (paymentMethodSelected.value.code?.toUpperCase().contains(waveCode) == false) {
      _listenPaymentStatus();
    }
  }

  _onWebResourceError(WebResourceError webResourceError) {
    isDataProcessing(false);
    OremusLogger.info('Page finished errorCode: ${webResourceError.errorCode}');
    OremusLogger.info('Page finished description: ${webResourceError.description}');
    OremusLogger.info('Page finished errorType: ${webResourceError.errorType}');
  }

  _listenPaymentStatus() {
    if (isTimerActive.value) {
      return;
    }
    isTimerActive(true);
    _timer = Timer.periodic(Duration(seconds: checkPaymentStatusInterval), (_) {
      doGetPaymentStatus();
    });
  }

  //CHECK PAYMENT STATUS
  @visibleForTesting
  doGetPaymentStatus() {
    if (checkingPaymentStatus.value == true) {
      return;
    }

    String? transactionId;
    if (paymentType.value == PaymentType.donation) {
      transactionId = donationSelected.value.transactionId ?? '';
    }
    if (paymentType.value == PaymentType.massRequest) {
      transactionId = massRequestResponseSelected.value.transactionId ?? '';
    }

    checkingPaymentStatus(true);
    paymentRepository
        .paymentStatus(
          transactionId: transactionId ?? '',
          manualVerify: manualVerify.value,
        )
        .then(
          (value) {
            if (value.paymentStatus == PaymentStatus.REFUSED.name ||
                value.paymentStatus == PaymentStatus.FAILED.name) {
              checkingPaymentStatus(true);
              paymentStatusMessage.value = 'Le paiement a échoué. Veuillez réessayer svp !';
              moveToError();
              return;
            }
            if (value.paymentStatus == PaymentStatus.PENDING.name ||
                value.paymentStatus == PaymentStatus.INITIATED.name ||
                value.paymentStatus == PaymentStatus.INIT.name) {
              manualVerifyCount.value += 1;
              OremusLogger.info('manualVerifyCount ::: ${manualVerifyCount.value}');
              if (manualVerifyCount.value == 5) {
                manualVerify.value = true;
              }
              checkingPaymentStatus(false);
              return;
            }
            if (value.paymentStatus == PaymentStatus.ACCEPTED.name ||
                value.paymentStatus == PaymentStatus.SUCCESS.name) {
              checkingPaymentStatus(true);
              switch (paymentType.value) {
                case PaymentType.massRequest:
                  paymentStatusMessage.value =
                      'Votre demande de messe a été effectuée avec succès';
                  break;
                case PaymentType.donation:
                  paymentStatusMessage.value =
                      'Votre don a été effectué avec succès';
                  break;
                case PaymentType.none:
                  paymentStatusMessage.value = 'Payment effectué avec succès';
                  break;
              }
              moveToSuccess();
              return;
            }

            checkingPaymentStatus(false);
            moveToProcessing();
          },
          onError: (error) {
            checkingPaymentStatus(false);
            if (error is! CustomException) return;
            final err = error;
            OremusLogger.info(err.message.toString());
            showNotification(
              message: err.message ?? 'Une erreur interne est survenue',
            );
            OremusLogger.info(
              'doGetPaymentStatus onError ::: ${err.message ?? 'label_error_unknow_server'.tr}',
            );
            //paymentStatusMessage.value = err.message.toString();
            //moveToError();
          },
        );
  }
}
