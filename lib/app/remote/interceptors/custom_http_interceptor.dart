import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/internet_checker/internet_connection_checker.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/main.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class CustomHttpInterceptor extends Interceptor {
  final Dio _dio;
  final Connectivity _connectivity = Connectivity();

  CustomHttpInterceptor({
    required String baseUrl,
    Duration timeout = const Duration(seconds: AppConstants.REQUEST_TIMEOUT),
  }) : _dio = Dio()
          ..options = BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: timeout,
            receiveTimeout: timeout,
            sendTimeout: timeout,
          ) {
    _dio.interceptors.add(_createLoggerInterceptor());
  }

  Interceptor _createLoggerInterceptor() {
    return TalkerDioLogger(
      talker: LoggerService.talker,
      settings: TalkerDioLoggerSettings(
        printRequestHeaders: true,
        enabled: flavor != AppConstants.ENV_PROD,
        requestPen: AnsiPen()..rgb(r: 0.16, g: 1, b: 1),
        responsePen: AnsiPen()..rgb(r: 0, g: 0.67, b: 0),
        errorPen: AnsiPen()..red(),
      ),
    );
  }

  ConnectivityResult _getBestConnection(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    }
    return ConnectivityResult.none;
  }

  /// Vérifie à la fois la connectivité réseau et l'accès Internet
  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      final bestConnection = _getBestConnection(connectivityResult);

      if (bestConnection == ConnectivityResult.none) {
        return false;
      }

      // Adaptation du timeout en fonction du type de connexion
      final timeout = switch (bestConnection) {
        ConnectivityResult.ethernet => const Duration(seconds: 40),
        ConnectivityResult.wifi => const Duration(seconds: 30),
        ConnectivityResult.mobile => const Duration(seconds: 50),
        _ => const Duration(seconds: 30),
      };

      _dio.options.connectTimeout = timeout;
      _dio.options.receiveTimeout = timeout;

      return await InternetConnectionChecker().hasConnection;
    } catch (e) {
      OremusLogger.error('Erreur lors de la vérification de la connexion: $e');
      return false;
    }
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    OremusLogger.info('REQUEST[${options.method}] => PATH: ${options.path}');

    if (canCheckConnectivity == true) {
      final bool hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Pas de connexion à Internet. Veuillez vérifier votre connexion et réessayer.',
            type: DioExceptionType.connectionError,
          ),
        );
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    OremusLogger.info(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    OremusLogger.error('''
=== CustomHttpInterceptor Error ===
Status Code: ${err.response?.statusCode}
Path: ${err.requestOptions.path}
Error Type: ${err.type}
Error Message: ${err.message}
=================================
''');

    if (err.type == DioExceptionType.connectionError) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'Pas de connexion à Internet',
          type: DioExceptionType.connectionError,
        ),
      );
    }

    handler.next(err);
  }
}
