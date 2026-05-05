import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/services/token_store.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> fakeStorage;
  late Directory tempDir;

  setUpAll(() async {
    OremusLogger.setTalkerInstance(Talker());
    tempDir = await Directory.systemTemp.createTemp('oremus_token_store_test');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    TokenStore.resetCacheForTesting();
    fakeStorage = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'read':
          return fakeStorage[call.arguments['key'] as String];
        case 'write':
          fakeStorage[call.arguments['key'] as String] =
              call.arguments['value'] as String;
          return null;
        case 'delete':
          fakeStorage.remove(call.arguments['key'] as String);
          return null;
        case 'readAll':
          return Map<String, String>.from(fakeStorage);
        case 'deleteAll':
          fakeStorage.clear();
          return null;
        case 'containsKey':
          return fakeStorage.containsKey(call.arguments['key'] as String);
        default:
          return null;
      }
    });

    DB.encryptedBox = await Hive.openBox(
      'test_box_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await DB.encryptedBox?.deleteFromDisk();
    DB.encryptedBox = null;
  });

  group('TokenStore lecture/écriture/clear', () {
    test('saveTokens écrit les deux tokens en secure storage', () async {
      await TokenStore.saveTokens(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
      );
      expect(fakeStorage['auth.access_token'], 'access-1');
      expect(fakeStorage['auth.refresh_token'], 'refresh-1');
    });

    test('getAccessToken lit depuis le storage', () async {
      fakeStorage['auth.access_token'] = 'access-2';
      // saveTokens met aussi à jour le cache mémoire ; ici on teste un cold read.
      // Le cache est privé donc on laisse le code y arriver via le storage.
      expect(await TokenStore.getAccessToken(), 'access-2');
    });

    test('getRefreshToken lit depuis le storage', () async {
      fakeStorage['auth.refresh_token'] = 'refresh-2';
      expect(await TokenStore.getRefreshToken(), 'refresh-2');
    });

    test('clear supprime les deux tokens', () async {
      fakeStorage['auth.access_token'] = 'a';
      fakeStorage['auth.refresh_token'] = 'r';
      await TokenStore.clear();
      expect(fakeStorage.containsKey('auth.access_token'), false);
      expect(fakeStorage.containsKey('auth.refresh_token'), false);
    });
  });

  group('TokenStore.migrateFromHive', () {
    test('Hive vide et secure storage vide → no-op', () async {
      await TokenStore.migrateFromHive();
      expect(fakeStorage, isEmpty);
    });

    test('legacy token Hive présent → migré et Hive vidé', () async {
      DB.saveData(AppConstants.KEY_TOKEN, 'legacy-token');

      await TokenStore.migrateFromHive();

      expect(fakeStorage['auth.access_token'], 'legacy-token');
      expect(DB.getData(AppConstants.KEY_TOKEN), isNull);
    });

    test('secure storage déjà rempli → migration ignorée', () async {
      // Cas d'un user déjà passé par la nouvelle version : on ne doit pas
      // écraser le token courant avec un fossile resté dans Hive.
      fakeStorage['auth.access_token'] = 'fresh-token';
      DB.saveData(AppConstants.KEY_TOKEN, 'stale-legacy-token');

      await TokenStore.migrateFromHive();

      expect(fakeStorage['auth.access_token'], 'fresh-token');
      // Hive n'est pas nettoyé non plus ; pas critique mais on vérifie.
      expect(DB.getData(AppConstants.KEY_TOKEN), 'stale-legacy-token');
    });

    test('legacy token vide est ignoré', () async {
      DB.saveData(AppConstants.KEY_TOKEN, '');

      await TokenStore.migrateFromHive();

      expect(fakeStorage.containsKey('auth.access_token'), false);
    });

    test('legacy token non-String est ignoré sans crash', () async {
      // Au cas où une version antérieure aurait écrit une valeur exotique.
      DB.encryptedBox?.put(AppConstants.KEY_TOKEN, 42);

      await TokenStore.migrateFromHive();

      expect(fakeStorage.containsKey('auth.access_token'), false);
    });
  });
}
