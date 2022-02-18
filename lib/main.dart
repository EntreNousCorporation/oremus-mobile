import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

var appUrl;
var flavor;
var encryptedBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR', null).then(
        (_) async {

      final settings = await _getFlavorSettings();
      appUrl = settings.apiBaseUrl;

      await Hive.initFlutter().then((value) => log('==== HIVE INIT SUCCESS===='));
      await configureEncryptedHive();

      Jiffy.locale('fr');
      configOrientation();

      runApp(const MyApp());

    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: (flavor == AppConstants.ENV_DEV) ? true : false,
      defaultTransition: Transition.rightToLeftWithFade,
      initialRoute: Routes.SPLASHSCREEN,
      getPages: AppPages.pages,
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: child!);
      },
    );
  }
}


configureEncryptedHive() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  var containsEncryptionKey = await secureStorage.containsKey(key: AppConstants.STORAGE_KEY);
  if (containsEncryptionKey == false) {
    var key = Hive.generateSecureKey();
    log('key $key');
    await secureStorage.write(key: AppConstants.STORAGE_KEY, value: base64UrlEncode(key));
  }
  log('containsEncryptionKey $containsEncryptionKey');
  var encryptionKey = base64Url.decode(await secureStorage.read(key: AppConstants.STORAGE_KEY) ?? '');
  log('encryptionKey $encryptionKey');
  encryptedBox = await Hive.openBox(AppConstants.BOX_NAME, encryptionCipher: HiveAesCipher(encryptionKey));
}

Future<FlavorSettings> _getFlavorSettings() async {
  flavor = await const MethodChannel('flavor').invokeMethod<String>('getFlavor');

  log('STARTED WITH FLAVOR $flavor');

  if (flavor == AppConstants.ENV_DEV) {
    return FlavorSettings.dev();
  } else if (flavor == AppConstants.ENV_PROD) {
    return FlavorSettings.prod();
  } else {
    throw Exception("Unknown flavor: $flavor");
  }
}

configOrientation() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}