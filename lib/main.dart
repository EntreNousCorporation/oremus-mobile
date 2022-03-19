import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/custom_animation.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/lang/translation_service.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:overlay_support/overlay_support.dart';

var appUrl;
var flavor;
var encryptedBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR', null).then(
    (_) async {
      final settings = await _getFlavorSettings();
      appUrl = settings.apiBaseUrl;

      await Hive.initFlutter()
          .then((value) => log('==== HIVE INIT SUCCESS===='));
      await configureEncryptedHive();

      Jiffy.locale('fr');
      configOrientation();
      configLoading();

      //runApp(const MyApp());
      runZonedGuarded<Future<void>>(() async {
        await Firebase.initializeApp();
        FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

        runApp(const MyApp());
      },
          (error, stack) =>
              FirebaseCrashlytics.instance.recordError(error, stack));
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
        debugShowCheckedModeBanner:
            (flavor == AppConstants.ENV_DEV) ? true : false,
        locale: TranslationService.locale,
        fallbackLocale: TranslationService.fallbackLocale,
        translations: TranslationService(),
        translationsKeys: TranslationService().keys,
        defaultTransition: Transition.rightToLeftWithFade,
        initialRoute: Routes.SIGNIN,
        getPages: AppPages.pages,
        builder: EasyLoading.init(builder: (context, child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
              child: child!);
        }),
      ),
    );
  }
}

configureEncryptedHive() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  var containsEncryption =
      await secureStorage.read(key: AppConstants.STORAGE_KEY);
  if (containsEncryption == null) {
    var key = Hive.generateSecureKey();
    log('key $key');
    await secureStorage.write(
        key: AppConstants.STORAGE_KEY, value: base64UrlEncode(key));
  }
  log('containsEncryption $containsEncryption');
  var encryptionKey = base64Url
      .decode(await secureStorage.read(key: AppConstants.STORAGE_KEY) ?? '');
  log('encryptionKey $encryptionKey');
  encryptedBox = await Hive.openBox(AppConstants.BOX_NAME,
      encryptionCipher: HiveAesCipher(encryptionKey));
}

Future<FlavorSettings> _getFlavorSettings() async {
  flavor =
      await const MethodChannel('flavor').invokeMethod<String>('getFlavor');

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

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 25.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false
    ..textStyle = const TextStyle(color: colorWhite, fontFamily: 'montserrat_regular')
    ..customAnimation = CustomAnimation();
}