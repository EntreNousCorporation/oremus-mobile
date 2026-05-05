import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Adapter Dio scripté par préfixe de path. À installer après
/// `bootstrap()` via `(await DioUtil().getInstance()).httpClientAdapter = ...`.
///
/// Toute requête dont le path commence par un préfixe enregistré reçoit la
/// `ResponseBody` produite par le handler. Les requêtes non matchées
/// reçoivent un 404 JSON pour faire échouer fort plutôt que silencieusement.
class RoutingMockAdapter implements HttpClientAdapter {
  final List<MapEntry<String, ResponseBody Function(RequestOptions)>>
      _routes = [];
  final List<RequestOptions> calls = [];

  /// Enregistre un handler pour les requêtes dont `path` commence par
  /// `pathPrefix`. Les routes sont parcourues dans l'ordre d'enregistrement
  /// (longest match recommandé en premier).
  void mock(
    String pathPrefix,
    ResponseBody Function(RequestOptions) handler,
  ) {
    _routes.add(MapEntry(pathPrefix, handler));
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    for (final entry in _routes) {
      if (options.path.startsWith(entry.key)) {
        return entry.value(options);
      }
    }
    return jsonBody(404, {
      'status': '404',
      'debugMessage': 'No mock registered for ${options.method} ${options.path}',
    });
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(int status, dynamic data) => ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
