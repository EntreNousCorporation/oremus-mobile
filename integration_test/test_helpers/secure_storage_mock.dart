import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock du channel `flutter_secure_storage` avec une Map en mémoire.
/// À appeler dans `setUpAll` ; rendu via le binding test.
class SecureStorageMock {
  static const _channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String> store = <String, String>{};

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      switch (call.method) {
        case 'read':
          return store[call.arguments['key'] as String];
        case 'write':
          store[call.arguments['key'] as String] =
              call.arguments['value'] as String;
          return null;
        case 'delete':
          store.remove(call.arguments['key'] as String);
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'deleteAll':
          store.clear();
          return null;
        case 'containsKey':
          return store.containsKey(call.arguments['key'] as String);
        default:
          return null;
      }
    });
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}
