import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequest/data/repository/interface_mass_request_repository.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class MassRequestRepository implements IMassRequestRepository {
  final ApiClient _apiClient;

  MassRequestRepository(this._apiClient);

  @override
  Future<List<TypeData>> getMassRequestType({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/types-of-mass-request?page=$page&size=${AppConstants.PAGING_SIZE_1000}&sort=code%2CASC",
      method: HttpMethod.get,
    );
    log('resp getMassRequestType => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => TypeData.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<PrayerIntentData>> getPrayerIntent({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/prayers-intent?page=$page&size=${AppConstants.PAGING_SIZE_1000}&sort=code%2CASC",
      method: HttpMethod.get,
    );
    log('resp getMassRequestType => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => PrayerIntentData.fromJson(i))
          .toList();
    }
  }

  @override
  Future<PriceResponse> getMassRequestPrice({required List<PriceData> request, required String workshipId}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests/$workshipId/quotation",
      method: HttpMethod.post,
      body: jsonEncode(request),
    );
    log('resp getMassRequestPrice => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return PriceResponse.fromJson(json.decode(response.bodyString.toString()));
    }
  }

  @override
  Future<MassRequestResponse> sendMassRequest({required MassRequestData request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests",
      method: HttpMethod.post,
      body: request.toJson(),
    );
    log('resp sendMassRequest => ${response.statusCode}');

    if (response.statusCode! >= 200 && response.statusCode! <= 204) {
      return MassRequestResponse.fromJson(json.decode(response.bodyString.toString()));
    } else {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    }
  }

  @override
  Future<MassRequestResponse> retryPayment({required PaymentStatusData request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests/retry-payment",
      method: HttpMethod.put,
      body: request.toJson(),
    );
    log('resp sendMassRequest => ${response.statusCode}');

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 204) {
      return MassRequestResponse.fromJson(json.decode(response.bodyString.toString()));
    } else {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    }
  }
}
