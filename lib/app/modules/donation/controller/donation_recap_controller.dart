import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart' hide PrayerIntentData, PriceData;
import 'package:oremusapp/app/modules/donation/data/repository/donation_repository.dart';
import 'package:oremusapp/app/modules/massrequest/controller/payment_method_selectable.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class DonationRecapController extends GetxController implements PaymentMethodSelectable {
  final PaymentRepository paymentRepository;
  final DonationRepository donationRepository;

  DonationRecapController({
    required this.paymentRepository,
    required this.donationRepository,
  });

  @override
  final RxList<PaymentMethodData> paymentMethods = <PaymentMethodData>[].obs;

  @override
  final Rx<PaymentMethodData?> paymentMethodSelected = Rx(null);

  var unlockBackButton = true.obs;
  var paroisseSelected = ContentPlace().obs;
  Rx<String?> amount = Rx<String?>(null);
  Rx<String?> description = Rx<String?>(null);

  late TextEditingController phoneNumberController;

  var isValidForm = false.obs;
  var phoneCode = '+225';
  var useOtherNumber = false.obs;
  var enableUseOtherNumberSwitch = true.obs;
  var ciNumberLength = 10;

  @override
  void onInit() {
    getArguments();
    initControllers();
    doGetPaymentMethod();
    super.onInit();
  }

  initControllers() {
    phoneNumberController = TextEditingController(text: getUserPhoneNumber());
    checkForm();
  }

  getArguments() {
    if (Get.arguments == null) return;
    Map arguments = Get.arguments;
    if (arguments.containsKey('worshipPlace') && arguments['worshipPlace'] != null) {
      paroisseSelected.value = ContentPlace.fromJson(arguments['worshipPlace']);
    }
    if (arguments.containsKey('donationDescription') && arguments['donationDescription'] != null) {
      description.value = arguments['donationDescription'];
    }
    if (arguments.containsKey('donationAmount') && arguments['donationAmount'] != null) {
      amount.value = arguments['donationAmount'];
    }
  }

  String getAmount() {
    return "${amount.value?.amountFormat() ?? '-'} Fcfa";
  }

  String getDescription() {
    return description.value?.isNotEmpty == true ? description.value! : '-';
  }

  moveToPayment(DonationResponse donationResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'payment_response': donationResponse.toJson(),
        'payment_type': PaymentType.donation,
      },
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  toggleUseOtherNumber() {
    useOtherNumber.toggle();
    if (useOtherNumber.isTrue) {
      phoneNumberController.clear();
    } else {
      phoneNumberController.text = getUserPhoneNumber();
    }
    checkForm();
  }

  String getUserPhoneNumber() {
    return DB.getUserSigninInfo()?.phone.toString().phoneFormat() ?? '-';
  }

  doGetPaymentMethod() {
    hideKeyboard();

    paymentRepository.getPaymentMethods().then((value) {
        if (value.isNotEmpty == true) {
          paymentMethods.value = value;
        }
        update();
      },
      onError: (error) {
        var err = error as CustomException;
        if (err.code == 401) {
          showCustomDialog(
            Get.context!,
            message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
          ).then((value) {
            doLogout();
          });
        } else if (err.code == 900) {
          showNotification(message: err.message.toString());
        }
      },
    );
  }

  @override
  void checkForm() {
    isValidForm.value = phoneNumberController.text.isNotEmpty && phoneNumberController.text.replaceAll(RegExp(r'\s'), '').length == ciNumberLength && paymentMethodSelected.value != null;
    update();
  }

  @override
  onPaymentMethodSelected(PaymentMethodData pmd) {
    if (pmd.code?.toUpperCase().contains('WAVE') == true) {
      useOtherNumber.value = false;
      enableUseOtherNumberSwitch.value = false;
      phoneNumberController.text = getUserPhoneNumber();
    } else {
      enableUseOtherNumberSwitch.value = true;
    }
    paymentMethodSelected.value = pmd;
  }

  doSendDonation({bool? forceDuplicateCreation}) {
    hideKeyboard();
    EasyLoading.show(
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = DonationData(
      amount: amount.value?.replaceAll(RegExp(r'\s'), ''),
      description: description.value,
      worshipPlace: paroisseSelected.value.identifier.toString(),
      phoneNumber: '$phoneCode${phoneNumberController.text.replaceAll(RegExp(r'\s'), '')}',
      paymentMethod: paymentMethodSelected.value?.code,
      forceDuplicateCreation: forceDuplicateCreation,
    );

    donationRepository.sendDonation(request: request).then(
          (value) {
        EasyLoading.dismiss(animation: true).then((v) {
          unlockBackButton.value = true;
        });
        moveToPayment(value);
      },
      onError: (error) {
        EasyLoading.dismiss(animation: true).then((v) {
          unlockBackButton.value = true;
        });
        debugPrint("error => ${error.toString()}");
        var err = error as CustomException;
        if (err.code == 401) {
          showCustomDialog(
            Get.context!,
            message: 'Votre session a expiré\nVeuillez-vous reconnecter svp',
          ).then((value) {
            doLogout();
          });
          return;
        }
        if (err.code == 409) {
          showCustomDialog(
            Get.context!,
            message:
            'Vous venez de faire un don identique. Souhaitez-vous confirmer ce don ?',
            positiveLabel: 'OUI',
            positiveCallBack: () {
              doSendDonation(forceDuplicateCreation: true);
            },
            negativeLabel: 'NON',
          );
          return;
        }
        showNotification(
            message: 'Une erreur est survenue',
            duration: const Duration(seconds: 4));
      },
    );
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
