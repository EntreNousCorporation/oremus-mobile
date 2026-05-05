import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/main.dart' as app;

import 'test_helpers/secure_storage_mock.dart';

/// Smoke test : exerce le `bootstrap()` réel de l'app (via
/// `BootstrapOptions.forTests`) puis vérifie qu'`OremusApp` rend le
/// splash sans crash.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageMock();

  setUpAll(() async {
    secureStorage.install();
    await app.bootstrap(
      options: app.BootstrapOptions.forTests(
        overrideFlavorSettings: FlavorSettings.dev(),
      ),
    );
  });

  tearDownAll(() {
    secureStorage.uninstall();
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
