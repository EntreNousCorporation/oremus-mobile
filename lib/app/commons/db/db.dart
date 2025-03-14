import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
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

  static initDatabase() async {
    Hive.initFlutter();

    final sharePrefs = await SharedPreferences.getInstance();
    var containsEncryption = sharePrefs.getString(AppConstants.STORAGE_KEY);

    if (containsEncryption == null) {
      var key = Hive.generateSecureKey();
      log('key $key');
      await sharePrefs.setString(AppConstants.STORAGE_KEY, base64UrlEncode(key));
    }
    log('containsEncryption $containsEncryption');
    var encryptionKey = base64Url.decode(sharePrefs.getString(AppConstants.STORAGE_KEY) ?? '');
    log('encryptionKey $encryptionKey');
    encryptedBox = await Hive.openBox(AppConstants.BOX_NAME, encryptionCipher: HiveAesCipher(encryptionKey));
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