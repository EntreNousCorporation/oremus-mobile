import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/create_life_plan_request.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/repository/interface_life_plan_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/data_response.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class LifePlanRepository implements ILifePlanRepository {
  final ApiClient _apiClient;

  LifePlanRepository(this._apiClient);

  @override
  Future<DataResponse<LifePlan>> getAvailableLifePlans({int? page = 0, int? size = 50}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/life-plans?page=$page&size=$size",
      method: HttpMethod.get,
      useBearer: true,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return DataResponse<LifePlan>.fromJson(response.data);
    }
  }

  @override
  Future<DataResponse<UserLifePlan>> getUserLifePlans({int? page = 0, int? size = 10}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/users/life-plans?page=$page&size=$size",
      method: HttpMethod.get,
      useBearer: true,
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return DataResponse<UserLifePlan>.fromJson(response.data);
    }
  }

  @override
  Future<UserLifePlan> createUserLifePlan({required CreateLifePlanRequest request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/user-life-plans",
      method: HttpMethod.post,
      useBearer: true,
      body: request.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return UserLifePlan.fromJson(response.data);
    }
  }

  @override
  Future<UserLifePlan> updateUserLifePlan({required int id, required UpdateLifePlanRequest request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/user-life-plans/$id",
      method: HttpMethod.put,
      useBearer: true,
      body: request.toJson(),
    );

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    } else {
      return UserLifePlan.fromJson(response.data);
    }
  }

  @override
  Future<void> deleteUserLifePlan({required int id}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/user-life-plans/$id",
      method: HttpMethod.delete,
      useBearer: true,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      var e = ErrorResponse.fromJson(response.data);
      throw CustomException(e.debugMessage, e.status);
    }
  }
}
