import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';


abstract class IPaymentRepository {
  Future<PaymentStatusData> paymentStatus({required String transactionId});
}

class PaymentRepository implements IPaymentRepository {

  final ApiClient _apiClient;
  PaymentRepository(this._apiClient);

  @override
  Future<PaymentStatusData> paymentStatus({required String transactionId}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/checkout/check-payment/$transactionId",
      method: HttpMethod.get,
    );
    final String resp = json.encode(response.bodyString);
    log('resp status code => ${response.statusCode}');
    if (response.statusCode! >= 200 && response.statusCode! <= 205) {
      log('resp => $resp');
      return PaymentStatusData.fromJson(json.decode(resp));
    } else {
      throw CustomException(response.statusCode, response.statusText);
    }
  }
}
