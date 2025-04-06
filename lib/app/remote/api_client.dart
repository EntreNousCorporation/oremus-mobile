import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/internet_checker/internet_connection_checker.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';
import 'package:oremusapp/main.dart';

abstract class ApiClient extends GetConnect {
  Future<dynamic> doRequest({
    required String endpoint,
    required HttpMethod method,
    dynamic body,
    bool useBearer = true,
    String? customBaseUrl,
  });
}

class ApiClientImpl extends ApiClient {
  @override
  Future doRequest({
    required String endpoint,
    required HttpMethod method,
    body,
    bool useBearer = true,
    String? customBaseUrl,
  }) async {
    Map<String, String> headers = <String, String>{};
    headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=utf-8';
    headers[HttpHeaders.acceptHeader] = 'application/json';
    headers['dId'] = phoneId;
    if (useBearer) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer ${DB.getData(AppConstants.KEY_TOKEN)}';
    }
    timeout = const Duration(seconds: AppConstants.REQUEST_TIMEOUT);

    // Utiliser l'URL de base personnalisée si elle est fournie, sinon utiliser l'URL d'application par défaut
    final baseUrl = customBaseUrl ?? appUrl;
    log("url => " + baseUrl + endpoint);
    log("headers => " + headers.toString());
    log("method => " + method.name);
    //log("body => " + body != null ? body: '');

    if (canCheckConnectivity) {
      await checkConnectivity();
    }

    Response response;
    var resp;

    dynamic processedBody = body;

    // Process the body if it's not null
    if (body != null) {
      if (body is Map<String, dynamic>) {
        processedBody = removeNullFields(body);
      } else if (body is List) {
        // Si c'est une liste d'objets
        processedBody = body.map((item) {
          if (item is Map<String, dynamic>) {
            return removeNullFields(item);
          }
          return item;
        }).toList();
      }
    }

    log('request Body => $processedBody');

    try {
      switch (method) {
        case HttpMethod.get:
          response = await get(baseUrl + endpoint, headers: headers);
          break;
        case HttpMethod.post:
          response = await post(baseUrl + endpoint, processedBody, headers: headers);
          break;
        case HttpMethod.patch:
          response = await patch(baseUrl + endpoint, processedBody, headers: headers);
          break;
        case HttpMethod.put:
          response = await put(baseUrl + endpoint, processedBody, headers: headers);
          break;
        case HttpMethod.delete:
          response = await delete(baseUrl + endpoint, headers: headers);
          break;
      }

      log("statusCode ${baseUrl + endpoint} => ${response.statusCode}");
      log("bodystring => " + response.bodyString.toString());

      resp = _response(response);

    } on SocketException {
      throw FetchDataException(100, 'No Internet connection');
    }

    return resp;
  }

  dynamic _response(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
      case 205:
        return response;
      case 400:
        throw BadRequestException(400, response.body.toString());
      case 401:
        throw UnauthorisedException(401, 'Requête non authorisée');
      case 403:
        var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
        throw UnauthorisedException(403, e.debugMessage);
    //throw UnauthorisedException(403, 'Requête non authorisée');
      case 409:
        throw ConflictedException(409, 'Conflit survenu');
      case 500:
        throw InternalServerErrorException(500, 'Une erreur interne du serveur est survenue');
      case 900:
        throw FetchDataException(900, 'Pas de connexion à Internet');
      default:
        throw FetchDataException(901, 'Une erreur inconnue est survenue');
    }
  }

  ///Vérification de la connectivité avant la d'effectuer la requête
  checkConnectivity() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == false) {
      throw FetchDataException(900, 'Vous êtes actuellement hors connexion! \nVeuillez vérifier votre connexion à Internet!');
    } else {
      log('is ok for Internet');
    }
  }
}
