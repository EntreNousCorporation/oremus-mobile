import 'dart:convert';
import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DB {
  static Box? encryptedBox;
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
    return encryptedBox?.get(key) ;
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
}