import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DB {
  static Box? encryptedBox;
  // Clés pour la gestion des favoris synchronisés
  static const String KEY_LAST_SYNC_USER_ID = 'last_sync_user_id';
  static const String KEY_UNSYNCHRONIZED_FAVORITES = 'unsynchronized_favorites';
  static const String KEY_SYNCED_FAVORITES = 'synced_favorites';

  static bool _isInitializing = false;
  static bool _isInitialized = false;

  static Future<bool> initDatabase() async {
    // Éviter les initialisations multiples simultanées
    if (_isInitialized) return true;
    if (_isInitializing) {
      // Attendre que l'initialisation en cours se termine
      int attempts = 0;
      while (_isInitializing && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      return _isInitialized;
    }

    _isInitializing = true;
    try {
      OremusLogger.info('Initialisation de Hive...');
      await Hive.initFlutter();
      OremusLogger.info('Hive initialisé, obtention des SharedPreferences...');

      final sharePrefs = await SharedPreferences.getInstance();
      var containsEncryption = sharePrefs.getString(AppConstants.STORAGE_KEY);

      if (containsEncryption == null) {
        var key = Hive.generateSecureKey();
        OremusLogger.info('Nouvelle clé générée');
        await sharePrefs.setString(AppConstants.STORAGE_KEY, base64UrlEncode(key));
        containsEncryption = sharePrefs.getString(AppConstants.STORAGE_KEY);
      }

      OremusLogger.debug('containsEncryption $containsEncryption');
      var encryptionKey = base64Url.decode(sharePrefs.getString(AppConstants.STORAGE_KEY) ?? '');
      OremusLogger.info('encryptionKey obtenue, ouverture de la box...');

      encryptedBox = await Hive.openBox(
          AppConstants.BOX_NAME,
          encryptionCipher: HiveAesCipher(encryptionKey)
      );

      OremusLogger.info('Box Hive ouverte avec succès');
      _isInitialized = true;
      return true;
    } catch (e) {
      OremusLogger.error('Erreur lors de l\'initialisation de la base de données: $e');
      _isInitialized = false;
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  static _save(String key, String? value) {
    encryptedBox?.put(key, value);
  }

  static getData(String key) {
    return encryptedBox?.get(key);
  }

  static void saveData(String key, String? value) {
    _save(key, value);
  }

  static getBoolData(String key) {
    return encryptedBox?.get(key);
  }

  static void saveBoolData(String key, bool? value) {
    encryptedBox?.put(key, value);
  }

  static String getCurrentLanguage() {
    return getData(AppConstants.KEY_LANGUAGE) ?? '';
  }

  static setCurrentLanguage(String code) {
    saveData(AppConstants.KEY_LANGUAGE, code);
  }

  static void saveUserSigninInfo(Signin? signin) {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, jsonEncode(signin?.toJson()));
  }

  static Signin? getUserSigninInfo() {
    var userInfo = DB.getData(AppConstants.KEY_USER_LOG_INFOS);
    if (userInfo != null) {
      return Signin.fromJson(json.decode(userInfo));
    }
    return null;
  }

  // Vérifie si des favoris non synchronisés existent
  static bool hasUnsynchronizedFavorites() {
    String? data = getData(KEY_UNSYNCHRONIZED_FAVORITES);
    return data != null && data.isNotEmpty;
  }

// Récupère la liste des favoris non synchronisés
  static List<ContentPlace> getUnsynchronizedFavorites() {
    String? data = getData(KEY_UNSYNCHRONIZED_FAVORITES);
    if (data != null && data.isNotEmpty) {
      Iterable l = json.decode(data);
      return l.map((model) => ContentPlace.fromJson(model)).toList();
    }
    return [];
  }

// Sauvegarde la liste des favoris non synchronisés
  static void saveUnsynchronizedFavorites(List<ContentPlace> favorites) {
    saveData(KEY_UNSYNCHRONIZED_FAVORITES, jsonEncode(favorites).toString());
  }

// Efface la liste des favoris non synchronisés
  static void clearUnsynchronizedFavorites() {
    saveData(KEY_UNSYNCHRONIZED_FAVORITES, '');
  }

// Récupère l'ID du dernier utilisateur qui a synchronisé des favoris
  static String? getLastSyncUserId() {
    return getData(KEY_LAST_SYNC_USER_ID);
  }

// Enregistre l'ID du dernier utilisateur qui a synchronisé des favoris
  static void setLastSyncUserId(String userId) {
    saveData(KEY_LAST_SYNC_USER_ID, userId);
  }

// Efface l'ID du dernier utilisateur qui a synchronisé des favoris
  static void clearLastSyncUserId() {
    saveData(KEY_LAST_SYNC_USER_ID, '');
  }

  // Génère une clé de stockage spécifique à l'utilisateur
  static String userSpecificKey(String baseKey) {
    String? userId = getUserSigninInfo()?.id;
    return userId != null && userId.isNotEmpty
        ? "${baseKey}_$userId"
        : baseKey;
  }

// Méthodes améliorées pour les favoris synchronisés avec le serveur
  static List<ContentPlace> getSyncedFavorites() {
    String key = userSpecificKey(KEY_SYNCED_FAVORITES);
    String? data = getData(key);
    if (data != null && data.isNotEmpty) {
      Iterable l = json.decode(data);
      return l.map((model) => ContentPlace.fromJson(model)).toList();
    }
    return [];
  }

  static void saveSyncedFavorites(List<ContentPlace> favorites) {
    String key = userSpecificKey(KEY_SYNCED_FAVORITES);
    saveData(key, jsonEncode(favorites).toString());
  }

  static void clearSyncedFavorites() {
    String key = userSpecificKey(KEY_SYNCED_FAVORITES);
    saveData(key, '');
  }

// Méthode pour effacer tous les favoris synchronisés quand l'utilisateur se déconnecte
  static void clearAllUserSpecificData() {
    String? userId = getUserSigninInfo()?.id;
    if (userId != null && userId.isNotEmpty) {
      clearSyncedFavorites();

      // Vous pouvez ajouter d'autres données spécifiques à l'utilisateur à effacer ici
    }
  }
}