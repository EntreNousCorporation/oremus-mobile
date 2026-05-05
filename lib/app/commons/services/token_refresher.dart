import 'dart:async';

import 'package:meta/meta.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/services/token_store.dart';
import 'package:oremusapp/app/modules/signin/data/model/refresh_token_request.dart';
import 'package:oremusapp/app/modules/signin/data/repository/interfaces/interface_signin_repository.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class TokenRefresher {
  // Mutex : N requêtes en 401 simultanées partagent le même refresh.
  static Completer<String?>? _inFlight;

  // DI seam pour les tests : remplaçable pour injecter un fake repository.
  @visibleForTesting
  static ISigninRepository Function() repositoryBuilder =
      () => SigninRepository(ApiClientImpl());

  @visibleForTesting
  static void resetForTesting() {
    _inFlight = null;
    repositoryBuilder = () => SigninRepository(ApiClientImpl());
  }

  static Future<String?> refreshIfNeeded() async {
    final pending = _inFlight;
    if (pending != null) return pending.future;

    // Pose le lock de façon synchrone AVANT tout await, sinon les N callers
    // parallèles voient tous _inFlight == null et chacun lance son propre
    // refresh (TOCTOU : await yield au scheduler, fenêtre exploitée).
    final completer = Completer<String?>();
    _inFlight = completer;

    try {
      final refresh = await TokenStore.getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        completer.complete(null);
        return null;
      }

      final response = await repositoryBuilder().refreshToken(
        RefreshTokenRequest(refreshToken: refresh),
      );

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
