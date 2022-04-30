import 'package:oremusapp/app/commons/db/db.dart';

class StorageRequest {
  static _save(String key, String? value) {
    DB.encryptedBox.put(key, value);
  }

  static  getData(String key) {
    return DB.encryptedBox.get(key) ;
  }

  static void saveData(String key, String? value) {
    _save(key, value);
  }
}
