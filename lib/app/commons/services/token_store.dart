import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';

class TokenStore {
  static const String KEY_ACCESS_TOKEN = 'auth.access_token';
  static const String KEY_REFRESH_TOKEN = 'auth.refresh_token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Cache mémoire pour éviter un round-trip natif sur chaque requête HTTP.
  static String? _accessTokenCache;

  static Future<String?> getAccessToken() async {
    if (_accessTokenCache != null) return _accessTokenCache;
    _accessTokenCache = await _storage.read(key: KEY_ACCESS_TOKEN);
    return _accessTokenCache;
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: KEY_REFRESH_TOKEN);
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessTokenCache = accessToken;
    await _storage.write(key: KEY_ACCESS_TOKEN, value: accessToken);
    await _storage.write(key: KEY_REFRESH_TOKEN, value: refreshToken);
  }

  static Future<void> clear() async {
    _accessTokenCache = null;
    await _storage.delete(key: KEY_ACCESS_TOKEN);
    await _storage.delete(key: KEY_REFRESH_TOKEN);
  }

  @visibleForTesting
  static void resetCacheForTesting() {
    _accessTokenCache = null;
  }

  // Migration unique du token Hive existant vers le secure storage.
  // Les utilisateurs déjà connectés gardent leur access token actif jusqu'à
  // expiration : sans refresh token ils sont déconnectés au premier 401.
  static Future<void> migrateFromHive() async {
    try {
      final existing = await _storage.read(key: KEY_ACCESS_TOKEN);
      if (existing != null) return;

      final legacy = DB.getData(AppConstants.KEY_TOKEN);
      if (legacy is! String || legacy.isEmpty) return;

      await _storage.write(key: KEY_ACCESS_TOKEN, value: legacy);
      DB.saveData(AppConstants.KEY_TOKEN, null);
      OremusLogger.info('TokenStore: token Hive migré vers secure storage');
    } catch (e, st) {
      OremusLogger.error('TokenStore: échec de la migration: $e\n$st');
    }
  }
}
