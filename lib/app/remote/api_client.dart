import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/storage_request.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/main.dart';

abstract class ApiClient extends GetConnect {
  Future<dynamic> doRequest({
    required String endpoint,
    required HttpMethod method,
    dynamic body,
    bool useBearer = true,
  });
}

class ApiClientImpl extends GetConnect implements ApiClient {
  @override
  Future doRequest({
    required String endpoint,
    required HttpMethod method,
    body,
    bool useBearer = true,
  }) async {
    Map<String, String> headers = <String, String>{};
    headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=utf-8';
    headers[HttpHeaders.acceptHeader] = 'application/json';
    if (useBearer) {
      headers[HttpHeaders.authorizationHeader] =
          'Bearer ${StorageRequest.getData(AppConstants.KEY_TOKEN)}';
    }
    timeout = const Duration(seconds: AppConstants.REQUEST_TIMEOUT);

    Response response;
    var resp;

    try {
      switch (method) {
        case HttpMethod.get:
          response = await get(appUrl + endpoint, headers: headers);
          break;
        case HttpMethod.post:
          response = await post(appUrl + endpoint, body, headers: headers);
          break;
        case HttpMethod.patch:
          response = await patch(appUrl + endpoint, body, headers: headers);
          break;
        case HttpMethod.put:
          response = await put(appUrl + endpoint, body, headers: headers);
          break;
        case HttpMethod.delete:
          response = await delete(appUrl + endpoint, headers: headers);
          break;
      }

      resp = _response(response);

      log("statusCode ${response.statusCode}");
      log("bodystring => " + response.bodyString.toString());
      log("headers => " + headers.toString());
      log("url => " + appUrl + endpoint);
      log("body => " + body);
      log("method => " + method.name);

    } on SocketException {
      throw FetchDataException(100, 'No Internet connection');
    }

    return resp;
  }

  dynamic _response(Response response) {
    switch (response.statusCode) {
      case 200:
        return response;
      case 400:
        throw BadRequestException(400, response.body.toString());
      case 401:
        throw UnauthorisedException(401, 'Requête non authorisée');
      case 403:
        throw UnauthorisedException(403, 'Requête non authorisée');
      case 500:
      default:
        throw FetchDataException(100, 'Error occured while Communication with Server with StatusCode: ${response.statusCode}');
    }
  }
}
