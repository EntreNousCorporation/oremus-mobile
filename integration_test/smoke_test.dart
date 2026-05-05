import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/main.dart' as app;

/// Smoke test : exerce le `bootstrap()` réel de l'app (via
/// `BootstrapOptions.forTests`) puis vérifie qu'`OremusApp` rend le
/// splash sans crash.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final fakeSecureStorage = <String, String>{};

  setUpAll(() async {
    // Mock secure_storage en mémoire (pour TokenStore.getAccessToken etc.)
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

    // Boot avec settings dev injectés (skip Firebase / OneSignal /
    // JustAudioBackground / connectivity / device info / audio services).
    await app.bootstrap(
      options: app.BootstrapOptions.forTests(
        overrideFlavorSettings: FlavorSettings.dev(),
      ),
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  testWidgets('OremusApp se construit sans crash et affiche le splash',
      (tester) async {
    await tester.pumpWidget(app.OremusApp());
    // Premier frame seulement, on n'attend pas pumpAndSettle car le splash
    // a un timer de 3s qui déclenche une nav.
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
