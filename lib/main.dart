import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/custom_animation.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/lang/translation_service.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:overlay_support/overlay_support.dart';

var appUrl;
var flavor;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('fr_FR', null).then(
    (_) async {
      final settings = await _getFlavorSettings();
      appUrl = settings.apiBaseUrl;

      await DB.initDatabase();

      Jiffy.locale('fr');
      configOrientation();
      configLoading();
      if (GetPlatform.isAndroid) {
        AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
      }

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
        //defaultTransition: Transition.rightToLeftWithFade,
        initialRoute: Routes.SPLASHSCREEN,
        getPages: AppPages.pages,
        builder: EasyLoading.init(builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: child!,
          );
        }),
      ),
    );
  }
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

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 25.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.black.withOpacity(0.8)
    ..userInteractions = false
    ..dismissOnTap = false
    ..textStyle =
        const TextStyle(color: colorBlack, fontFamily: 'montserrat_regular')
    ..customAnimation = CustomAnimation();
}
