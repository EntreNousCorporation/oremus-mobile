import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart' hide PrayerIntentData, PriceData;
import 'package:oremusapp/app/modules/massrequest/controller/payment_method_selectable.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart' hide TypeData, MassTypeRepetitionData;
import 'package:oremusapp/app/modules/massrequest/data/repository/mass_request_repository.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/history_mass_request_selectable.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/history_mass_date_dialog.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/modules/payment/data/repository/payment_repository.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class MassRequestRecapController extends GetxController implements PaymentMethodSelectable, HistoryMassRequestSelectable {
  final PaymentRepository paymentRepository;
  final MassRequestRepository massRequestRepository;

  MassRequestRecapController({
    required this.paymentRepository,
    required this.massRequestRepository,
  });

  var unlockBackButton = true.obs;

  @override
  final RxList<PaymentMethodData> paymentMethods = <PaymentMethodData>[].obs;

  @override
  final Rx<PaymentMethodData?> paymentMethodSelected = Rx(null);

  var paroisseSelected = ContentPlace().obs;
  Rx<String?> prayerIntentSelected = Rx<String?>(null);
  Rx<String?> price = Rx<String?>(null);
  RxList<PriceData?> datesChoosen = RxList<PriceData?>([]);
  Rx<TypeData?> massRequestTypeSelected = Rx<TypeData?>(null);
  Rx<MassTypeRepetitionData?> massRequestTypeRepetitionSelected = Rx<MassTypeRepetitionData?>(null);

  var selectedDate = Rx<PriceData?>(null);
  var selectedHour = Rx<Slot?>(null);

  late TextEditingController phoneNumberController;

  var isValidForm = false.obs;
  var phoneCode = '+225';
  var useOtherNumber = false.obs;
  var enableUseOtherNumberSwitch = true.obs;
  var ciNumberLength = 10;

  @override
  var massRequestSelected = MassRequestResponse().obs;

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
    if (arguments.containsKey('prayerIntent') && arguments['prayerIntent'] != null) {
      prayerIntentSelected.value = arguments['prayerIntent'];
    }
    if (arguments.containsKey('typeOfMassRequest') && arguments['typeOfMassRequest'] != null) {
      massRequestTypeSelected.value = TypeData.fromJson(arguments['typeOfMassRequest']);
    }
    if (arguments.containsKey('slots') && arguments['slots'] != null) {
      datesChoosen.value = (arguments['slots']).whereType<PriceData>().toList();
    }
    if (arguments.containsKey('price') && arguments['price'] != null) {
      price.value = arguments['price'];
    }
    if (arguments.containsKey('massRequestTypeRepetitionSelected') && arguments['massRequestTypeRepetitionSelected'] != null) {
      massRequestTypeRepetitionSelected.value = MassTypeRepetitionData.fromJson(arguments['massRequestTypeRepetitionSelected']);
    }
    if (arguments.containsKey('selectedDate') && arguments['selectedDate'] != null) {
      selectedDate.value = PriceData.fromJson(arguments['selectedDate']);
      OremusLogger.debug('selectedDate ::: ${selectedDate.toJson()}');
    }
    if (arguments.containsKey('selectedHour') && arguments['selectedHour'] != null) {
      selectedHour.value = Slot.fromJson(arguments['selectedHour']);
      OremusLogger.debug('selectedHour ::: ${selectedHour.toJson()}');
    }
    OremusLogger.debug('massRequestData 444 ::: ${paroisseSelected.toJson()}');
  }

  showMassHours() {
    final bookings = datesChoosen.whereType<PriceData>().toList();
    var mr = MassRequestResponse(bookings: bookings);
    massRequestSelected.value = mr;
    historyMassDateDialog(this);
  }

  moveToPayment(MassRequestResponse massRequestResponse) {
    Get.toNamed(
      Routes.PAYMENT,
      arguments: {
        'paroisse_selected': paroisseSelected.toJson(),
        'payment_response': massRequestResponse.toJson(),
        'payment_type': PaymentType.massRequest,
        'payment_method_selected': paymentMethodSelected.toJson(),
      },
    );
  }

  moveToHome() {
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.CUSTOM_HOME_NEW);
  }

  bool canShowSingleDate() {
    return massRequestTypeRepetitionSelected.value?.code == RepetitionType.once.name;
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
    log('getUserSigninInfo ::: ${DB.getUserSigninInfo()?.toJson()}');
    return DB.getUserSigninInfo()?.phone.toString().phoneFormat() ?? '-';
  }

  String showDate() {
    return "${selectedDate.value?.dayToDisplay ?? '-'} à ${getTime(selectedHour.value?.startTime ?? '')}";
  }

  String getTime(String value) {
    if (value.isEmpty) return '-';
    return '${value.split(':').first}:${value.split(':')[1]}';
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
          showNotification(message: err.message.toString());
        }
        debugPrint("error => ${error.toString()}");
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


  doSendMassRequest({bool? forceDuplicateCreation}) {
    hideKeyboard();
    EasyLoading.show(
      status: 'Traitement en cours...',
      maskType: EasyLoadingMaskType.black,
      indicator: LottieLoadingView(),
    ).then((v) {
      unlockBackButton.value = false;
    });

    var request = MassRequestData(
      prayerIntent: prayerIntentSelected.value,
      typeOfMassRequest: massRequestTypeSelected.value?.code,
      slots: datesChoosen,
      worshipPlace: paroisseSelected.value.identifier,
      forceDuplicateCreation: forceDuplicateCreation,
      paymentMethod: paymentMethodSelected.value?.code,
      phoneNumber: '$phoneCode${phoneNumberController.text.replaceAll(RegExp(r'\s'), '')}',
    );

    log('request doSendMassRequest => ${jsonEncode(request.toJson())}');

    massRequestRepository
        .sendMassRequest(request: request)
        .then(
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
            if (error is! CustomException) return;
            final err = error;
            if (err.code == 401) {
              showCustomDialog(
                Get.context!,
                message:
                    'Votre session a expiré\nVeuillez-vous reconnecter svp',
              ).then((value) {
                doLogout();
              });
              return;
            }
            if (err.code == 409) {
              showCustomDialog(
                Get.context!,
                message:
                    'Vous venez de faire une demande de messe identique. Souhaitez-vous confirmer cette demande ?',
                positiveLabel: 'OUI',
                positiveCallBack: () {
                  doSendMassRequest(forceDuplicateCreation: true);
                },
                negativeLabel: 'NON',
              );
              return;
            }
            showNotification(
              message: 'Une erreur est survenue',
              duration: const Duration(seconds: 4),
            );
          },
        );
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
