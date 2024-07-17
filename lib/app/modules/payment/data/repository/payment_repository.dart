import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';


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
      method: HttpMethod.post,
    );
    log('resp status code => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return PaymentStatusData.fromJson(json.decode(response.bodyString.toString()));
    }
  }
}
