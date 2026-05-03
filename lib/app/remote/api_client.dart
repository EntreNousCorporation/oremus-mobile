import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/dio_util.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/main.dart';

abstract class ApiClient {
  Future<dynamic> doRequest({
    required String endpoint,
    required HttpMethod method,
    dynamic body,
    bool useBearer = true,
    String? customBaseUrl,
  });
}

class ApiClientImpl implements ApiClient {
  Dio? _dio;

  @override
  Future doRequest({
    required String endpoint,
    required HttpMethod method,
    body,
    bool useBearer = true,
    String? customBaseUrl,
  }) async {
    try {
      if (customBaseUrl?.isNotEmpty == true) {
        _dio = await DioUtil(baseUrl: customBaseUrl, forceNew: true)
            .getInstance();
      } else {
        _dio = await DioUtil().getInstance();
      }

      Map<String, String> headers = <String, String>{};
      headers[HttpHeaders.contentTypeHeader] =
          'application/json; charset=utf-8';
      headers[HttpHeaders.acceptHeader] = 'application/json';
      headers['dId'] = phoneId;
      headers['platform'] = Platform.isAndroid ? 'Android' : 'iOS';
      if (useBearer) {
        headers[HttpHeaders.authorizationHeader] =
            'Bearer ${DB.getData(AppConstants.KEY_TOKEN)}';
      }
      _dio?.options.headers = headers;

      log("url => ${_dio?.options.baseUrl}$endpoint");
      log("headers => $headers");
      log("method => ${method.name}");

      Response? response;
      var resp;

      dynamic processedBody = body;

      // Process the body if it's not null
      if (body != null) {
        if (body is Map<String, dynamic>) {
          processedBody = removeNullFields(body);
        } else if (body is List) {
          processedBody = body.map((item) {
            if (item is Map<String, dynamic>) {
              return removeNullFields(item);
            }
            return item;
          }).toList();
        }
      }

      try {
        switch (method) {
          case HttpMethod.get:
            response = await _dio?.get(endpoint);
            break;
          case HttpMethod.post:
            response = await _dio?.post(endpoint, data: processedBody);
            break;
          case HttpMethod.patch:
            response = await _dio?.patch(endpoint, data: processedBody);
            break;
          case HttpMethod.put:
            response = await _dio?.put(endpoint, data: processedBody);
            break;
          case HttpMethod.delete:
            response = await _dio?.delete(endpoint, data: processedBody);
            break;
        }

        resp = _response(response);
        return resp;
      } on DioException catch (e) {
        OremusLogger.error('''
=== ApiClientImpl DioException ===
Status Code: ${e.response?.statusCode}
Path: ${e.requestOptions.path}
Error Type: ${e.type}
==============================
''');
        if (e.type == DioExceptionType.connectionError) {
          throw FetchDataException(
            900,
            'Pas de connexion à Internet. Veuillez vérifier votre connexion et réessayer.',
          );
        }

        if (e.response?.statusCode == 401) {
          if (e.error is UnauthorisedException) {
            throw e.error as UnauthorisedException;
          }
          throw UnauthorisedException(401, 'Session expirée');
        }

        if (e.response == null ||
            e.response.toString().isEmpty ||
            e.response?.data == null) {
          throw FetchDataException(
            e.response?.statusCode ?? 900,
            'Une erreur interne est survenue',
          );
        }
        resp = _response(e.response);
        return resp;
      }
    } catch (error) {
      OremusLogger.error('''
=== Request Failed ===
Endpoint: $endpoint
Error: $error
====================
''');
      rethrow;
    }
  }

  dynamic _response(Response? response) {
    switch (response?.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
      case 205:
        return response;
      case 400:
        throw BadRequestException(400, response?.data.toString());
      case 401:
        throw UnauthorisedException(401, 'Requête non authorisée');
      case 403:
        var e = ErrorResponse.fromJson(jsonDecode(jsonEncode(response?.data)));
        throw UnauthorisedException(403, e.debugMessage);
      case 409:
        throw ConflictedException(409, 'Un conflit de données est survenu');
      case 500:
        throw InternalServerErrorException(
            500, 'Une erreur interne du serveur est survenue');
      case 900:
        throw FetchDataException(900, 'Pas de connexion à Internet');
      default:
        throw FetchDataException(901, 'Une erreur inconnue est survenue');
    }
  }
}
