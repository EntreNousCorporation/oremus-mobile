import 'package:get/get.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';

abstract class PaymentMethodSelectable {
  RxList<PaymentMethodData> get paymentMethods;
  Rx<PaymentMethodData?> get paymentMethodSelected;
  void checkForm();
  void onPaymentMethodSelected(PaymentMethodData pmd);
}