import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/provider/remote/data_response.dart';
import 'package:oremusapp/app/provider/remote/to_json_interface.dart';
import 'package:oremusapp/main.dart';

class ApiClient<T extends ToJsonInterface> extends GetConnect {

  Future<DataResponse<T>> postRequest(
      {required String endpoint, dynamic data}) async {
    Map<String, String> headers = <String, String>{};
    headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=utf-8';
    headers['no-encrypt'] = 'true';
    timeout = const Duration(seconds: AppConstants.REQUEST_TIMEOUT);

    final response = await post(appUrl + endpoint, data, headers: headers);
    log("bodystring" + response.bodyString.toString());
    log("url " + appUrl + endpoint);
    log("headers send" + headers.toString());
    log("headers " + response.headers.toString());
    if (response.status.hasError) {
      log("Future.error ${response.status.hasError}");
      return Future.error(response);
    } else {
      return DataResponse<T>.fromJson(json.decode(response.bodyString ?? ''));
    }
  }
}
