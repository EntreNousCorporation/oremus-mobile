import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/app/remote/interceptors/custom_http_interceptor.dart';
import 'package:oremusapp/main.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DioUtil {
  static DioUtil? _instance;
  Dio? _dio;
  String _baseUrl;

  factory DioUtil({String? baseUrl, bool forceNew = false}) {
    if (forceNew) {
      return DioUtil._internal(baseUrl: baseUrl);
    }
    return _instance ??= DioUtil._internal(baseUrl: baseUrl);
  }

  DioUtil._internal({String? baseUrl}) : _baseUrl = baseUrl ?? appUrl;

  Future<void> initialize() async {
    if (_dio != null) return;
    await _initializeDio();
  }

  Future<void> _initializeDio() async {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: AppConstants.REQUEST_TIMEOUT),
      receiveTimeout: const Duration(seconds: AppConstants.REQUEST_TIMEOUT),
      sendTimeout: const Duration(seconds: AppConstants.REQUEST_TIMEOUT),
      validateStatus: (status) {
        if (status == 401 || status == 403) {
          return false;
        }
        return status != null && status < 500;
      },
    ));

    _configureSslPinning(_dio);

    _dio?.interceptors.addAll([
      _createLoggerInterceptor(),
      _createRetryInterceptor(),
      CustomHttpInterceptor(baseUrl: _baseUrl),
    ]);
  }

  Interceptor _createLoggerInterceptor() {
    return TalkerDioLogger(
      talker: LoggerService.talker,
      settings: TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseHeaders: true,
        enabled: flavor != AppConstants.ENV_PROD,
        requestPen: AnsiPen()..rgb(r: 0.16, g: 1, b: 1),
        responsePen: AnsiPen()..rgb(r: 0, g: 0.67, b: 0),
        errorPen: AnsiPen()..red(),
      ),
    );
  }

  Interceptor _createRetryInterceptor() {
    return QueuedInterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          int attempts = 0;
          const maxAttempts = 3;
          const baseDelay = Duration(seconds: 1);

          while (attempts < maxAttempts) {
            try {
              await Future.delayed(baseDelay * pow(2, attempts));
              final response = await _retryRequest(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              attempts++;
              if (attempts == maxAttempts) {
                return handler.next(error);
              }
            }
          }
        }
        return handler.next(error);
      },
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      extra: requestOptions.extra,
      validateStatus: requestOptions.validateStatus,
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
    );

    return await _dio!.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void _configureSslPinning(Dio? dio) {
    dio?.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return bypassCert ?? false;
        };
        return client;
      },
    );
  }

  Future<Dio> getInstance() async {
    await initialize();
    return _dio!;
  }
}
