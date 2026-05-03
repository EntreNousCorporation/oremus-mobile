import 'dart:async';

import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/services/token_store.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class TokenRefresher {
  // Mutex : N requêtes en 401 simultanées partagent le même refresh.
  static Completer<String?>? _inFlight;

  static Future<String?> refreshIfNeeded() async {
    final pending = _inFlight;
    if (pending != null) return pending.future;

    final refresh = await TokenStore.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    final completer = Completer<String?>();
    _inFlight = completer;

    try {
      final response = await SigninRepository(
        ApiClientImpl(),
      ).refreshToken(refresh);

      if (response.accessToken != null && response.refreshToken != null) {
        await TokenStore.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
        completer.complete(response.accessToken);
      } else {
        OremusLogger.warning('TokenRefresher: réponse incomplète, abandon');
        completer.complete(null);
      }
    } catch (e, st) {
      OremusLogger.error('TokenRefresher: échec du refresh: $e\n$st');
      completer.complete(null);
    } finally {
      _inFlight = null;
    }

    return completer.future;
  }
}
