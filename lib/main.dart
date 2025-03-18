import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jiffy/jiffy.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:oremusapp/app/commons/components/custom_animation.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/lang/translation_service.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_theme.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/services/interaction_zone_service.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main_app_wrapper.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';

var appUrl;
//var byPassAuth;
var isUserConnected = false.obs;
var requestMassWithoutWorship = false.obs;
var donationWithoutWorship = false.obs;
var flavor;
var versionName;
var versionCode;
var phoneId;
var shareAppLink;
var canCheckConectivity;
var oneSignalAppID;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser le service de lecture en arrière-plan
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.oremusapp.audio',
    androidNotificationChannelName: 'Oremus Rosaire',
    androidNotificationChannelDescription: 'Lecture audio du Rosaire',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
    androidStopForegroundOnPause: true,
    notificationColor: colorGreen,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );

  initializeDateFormatting('fr_FR', null).then(
    (_) async {
      final settings = await _getFlavorSettings();
      appUrl = settings.oremusFlavor.apiBaseUrl.toString() + settings.oremusFlavor.endpoint.toString();
      shareAppLink = settings.oremusFlavor.shareAppLink;
      canCheckConectivity = settings.oremusFlavor.canCheckConectivity;
      oneSignalAppID = settings.oremusFlavor.oneSignalAppID;
      //byPassAuth = settings.oremusFlavor.byPassAuth;

      await DB.initDatabase();
      await getDeviceInfos();
      getAppVersion();

      Jiffy.setLocale('fr');
      configOrientation();
      configLoading();

      await Firebase.initializeApp();
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Initialiser le service audio player
      final audioService = Get.put(AudioPlayerService(), permanent: true);
      final zoneService = Get.put(InteractionZoneService(), permanent: true);
      Future.delayed(Duration.zero, () {
        // La première route peut être différente de celle attendue initialement
        zoneService.currentRoute.value = Get.currentRoute;
        zoneService.updatePositionForCurrentRoute();
      });

      runApp(const MyApp());
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
        theme: appThemeData,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'EN'), // English
          Locale('fr', 'FR'), // French
        ],
        initialRoute: Routes.SPLASHSCREEN,
        getPages: AppPages.pages,
        builder: EasyLoading.init(builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
            child: MainAppWrapper(child: child!),
          );
        }),
      ),
    );
  }
}

Future<void> getDeviceInfos() async {
  log('====== getDeviceInfos ======');
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      phoneId = iosInfo.identifierForVendor ?? '';
      log('getUniqueDeviceId => $phoneId');
    } else if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      phoneId = androidInfo.id;
      log('getUniqueDeviceId => $phoneId');
    }
  } catch (ex) {
    log('getDeviceInfos => ${ex.toString()}');
  }
}

getAppVersion() {
  log('====== getAppVersion ======');
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    versionName = packageInfo.version;
    versionCode = packageInfo.buildNumber;
  });
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
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 25.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.black.withValues(alpha: 0.8)
    ..userInteractions = false
    ..dismissOnTap = false
    ..textStyle =
        const TextStyle(color: colorBlack, fontFamily: 'montserrat_regular')
    ..customAnimation = CustomAnimation();
}
