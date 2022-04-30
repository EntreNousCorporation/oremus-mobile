import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oremusapp/app/commons/constants.dart';

class DB {
  static var encryptedBox;
  static initDatabase() async {
    Hive.initFlutter().then((value) => log('==== HIVE INIT SUCCESS===='));

    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    var containsEncryption = await secureStorage.read(key: AppConstants.STORAGE_KEY);
    if (containsEncryption == null) {
      var key = Hive.generateSecureKey();
      log('key $key');
      await secureStorage.write(key: AppConstants.STORAGE_KEY, value: base64UrlEncode(key));
    }
    log('containsEncryption $containsEncryption');
    var encryptionKey = base64Url.decode(await secureStorage.read(key: AppConstants.STORAGE_KEY) ?? '');
    log('encryptionKey $encryptionKey');
    encryptedBox = await Hive.openBox(AppConstants.BOX_NAME, encryptionCipher: HiveAesCipher(encryptionKey));
  }

  static _save(String key, String? value) {
    encryptedBox.put(key, value);
  }

  static getData(String key) {
    return encryptedBox.get(key) ;
  }

  static void saveData(String key, String? value) {
    _save(key, value);
  }
}