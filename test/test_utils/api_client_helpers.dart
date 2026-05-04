import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

Response<dynamic> okResponse(dynamic data, {int code = 200}) => Response(
      statusCode: code,
      data: data,
      requestOptions: RequestOptions(path: ''),
    );

Response<dynamic> errResponse(int code, {Map<String, dynamic>? data}) =>
    Response(
      statusCode: code,
      data: data ?? {'status': '$code', 'debugMessage': 'error'},
      requestOptions: RequestOptions(path: ''),
    );

void registerHttpMethodFallback() {
  registerFallbackValue(HttpMethod.get);
}
