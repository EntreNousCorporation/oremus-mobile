import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donation/data/repository/interface_donation_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class DonationRepository implements IDonationRepository {
  final ApiClient _apiClient;

  DonationRepository(this._apiClient);

  @override
  Future<DonationResponse> sendDonation({required DonationData request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/donations",
      method: HttpMethod.post,
      body: request.toJson(),
    );
    log('resp sendMassRequest => ${response.statusCode}');

    if (response.statusCode! >= 200 && response.statusCode! <= 204) {
      return DonationResponse.fromJson(json.decode(response.bodyString.toString()));
    } else {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    }
  }

  @override
  Future<DonationResponse> donationRetryPayment({required PaymentStatusData request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/donations/retry-payment",
      method: HttpMethod.put,
      body: request.toJson(),
    );
    log('resp sendMassRequest => ${response.statusCode}');

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 204) {
      return DonationResponse.fromJson(json.decode(response.bodyString.toString()));
    } else {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    }
  }
}
