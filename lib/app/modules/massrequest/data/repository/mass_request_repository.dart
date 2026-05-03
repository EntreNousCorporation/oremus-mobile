import 'package:dio/dio.dart';
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
      endpoint: "/types-of-mass-request?page=$page&size=${AppConstants.PAGING_SIZE_100}&sort=code%2CASC",
      method: HttpMethod.get,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => TypeData.fromJson(i))
          .toList();
    }
  }

  @override
  Future<List<PrayerIntentData>> getPrayerIntent({int? page = 0}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/prayers-intent?page=$page&size=${AppConstants.PAGING_SIZE_100}&sort=code%2CASC",
      method: HttpMethod.get,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (response.data as List)
          .map((i) => PrayerIntentData.fromJson(i))
          .toList();
    }
  }

  @override
  Future<PriceResponse> getMassRequestPrice({required List<PriceData?> request, required String workshipId}) async {
    final requestData = request
        .where((element) => element != null)
        .map((e) => e!.toJson())
        .toList();

    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests/$workshipId/quotation",
      method: HttpMethod.post,
      body: requestData,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return PriceResponse.fromJson(response.data);
    }
  }

  @override
  Future<MassRequestResponse> sendMassRequest({required MassRequestData request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-requests",
      method: HttpMethod.post,
      body: request.toJson(),
    );

    if (response.statusCode! >= 200 && response.statusCode! <= 204) {
      return MassRequestResponse.fromJson(response.data);
    } else {
      var e = ErrorResponse.fromJson(response.data);
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

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 204) {
      return MassRequestResponse.fromJson(response.data);
    } else {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    }
  }
}
