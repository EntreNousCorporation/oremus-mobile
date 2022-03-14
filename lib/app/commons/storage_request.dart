import 'package:oremusapp/main.dart';

class StorageRequest {
  static _save(String key, String? value) {
    encryptedBox.put(key, value);
  }

  static  getData(String key) {
    return encryptedBox.get(key) ;
  }

  static void saveData(String key, String? value) {
    _save(key, value);
  }
}
