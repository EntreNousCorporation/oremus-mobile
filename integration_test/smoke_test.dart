import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/services/token_store.dart';
import 'package:oremusapp/app/configs/services/logger_service.dart';
import 'package:oremusapp/main.dart' as app;

/// Smoke test "boot l'app" : exerce l'init minimale puis vérifie que
/// le SplashScreen rend sans crash.
///
/// On évite d'appeler `app.main()` directement car il fait :
///  - JustAudioBackground.init (channel natif)
///  - Firebase.initializeApp
///  - FirebaseCrashlytics
///  - Connectivity().checkConnectivity (channel natif)
///  - OneSignal init (via CustomHomeController plus tard)
///
/// On reproduit ici un sous-ensemble suffisant pour faire vivre OremusApp.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const flavorChannel = MethodChannel('flavor');
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Directory hiveTempDir;

  setUpAll(() async {
    // 1. Mock du MethodChannel `flavor` (sinon `_getFlavorSettings` throw).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(flavorChannel, (call) async {
      if (call.method == 'getFlavor') return 'dev';
      return null;
    });

    // 2. Mock secure storage en mémoire.
    final fakeSecureStorage = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      switch (call.method) {
        case 'read':
          return fakeSecureStorage[call.arguments['key'] as String];
        case 'write':
          fakeSecureStorage[call.arguments['key'] as String] =
              call.arguments['value'] as String;
          return null;
        case 'delete':
          fakeSecureStorage.remove(call.arguments['key'] as String);
          return null;
        case 'readAll':
          return Map<String, String>.from(fakeSecureStorage);
        case 'deleteAll':
          fakeSecureStorage.clear();
          return null;
        case 'containsKey':
          return fakeSecureStorage
              .containsKey(call.arguments['key'] as String);
        default:
          return null;
      }
    });

    // 3. Hive sur disque temp + box assignée à DB.encryptedBox.
    hiveTempDir = await Directory.systemTemp.createTemp('oremus_smoke_test');
    Hive.init(hiveTempDir.path);
    DB.encryptedBox = await Hive.openBox('smoke_test_box');

    // 4. LoggerService (set OremusLogger._instance + LoggerService.talker).
    await LoggerService.initialize(showAppLogs: false);

    // 5. Globals normalement set par _getFlavorSettings dans main().
    app.flavor = 'dev';
    app.appUrl = 'https://api-test.local';
    app.customBaseUrl = 'https://report-test.local';
    app.canCheckConnectivity = false;
    app.bypassCert = true;
    app.showAppLogs = false;
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(flavorChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
    await DB.encryptedBox?.close();
    DB.encryptedBox = null;
    TokenStore.resetCacheForTesting();
    await Hive.close();
    await hiveTempDir.delete(recursive: true);
  });

  testWidgets('OremusApp se construit sans crash et affiche le splash',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    // Premier frame seulement, on n'attend pas pumpAndSettle car le splash
    // a un timer de 3s qui déclenche une nav.
    await tester.pump();

    // Le splash doit être visible. Sa structure exacte est détaillée dans
    // splashscreen_screen.dart ; on vérifie au minimum un MaterialApp et
    // qu'il n'y a pas de crash.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
