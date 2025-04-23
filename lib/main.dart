import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:oremusapp/app/commons/components/network_status_overlay.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/lang/translation_service.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/configs/flavor_settings.dart';
import 'package:oremusapp/app/modules/initial/initial_binding.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_file_manager_service.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/routes/app_pages.dart';
import 'package:oremusapp/main_app_wrapper.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';

var appUrl;
var isUserConnected = false.obs;
var requestMassWithoutWorship = false.obs;
var donationWithoutWorship = false.obs;
var flavor;
var versionName;
var versionCode;
var phoneId;
var shareAppLink;
var canCheckConnectivity;
var oneSignalAppID;
var connectivityStatus = ConnectivityResult.none.obs;

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

  initializeDateFormatting('fr_FR', null).then((_) async {
    final settings = await _getFlavorSettings();
    appUrl = settings.oremusFlavor.apiBaseUrl.toString() +
        settings.oremusFlavor.endpoint.toString();
    shareAppLink = settings.oremusFlavor.shareAppLink;
    canCheckConnectivity = settings.oremusFlavor.canCheckConectivity;
    oneSignalAppID = settings.oremusFlavor.oneSignalAppID;
    //byPassAuth = settings.oremusFlavor.byPassAuth;

    // Initialiser la base de données avec gestion d'erreur
    bool dbInitSuccess = await DB.initDatabase();
    if (!dbInitSuccess) {
      log('AVERTISSEMENT: Échec de l\'initialisation de la base de données, l\'application fonctionnera sans persistance');
    }
    await getDeviceInfos();
    getAppVersion();

    // Initialiser la surveillance de la connectivité
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty) {
        connectivityStatus.value = result.first;
        log('Changement de connectivité: ${result.first.toString()}');
      }
    });

    // Obtenir l'état initial de la connectivité
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.isNotEmpty) {
      connectivityStatus.value = connectivityResult.first;
    }

    Jiffy.setLocale('fr');
    configOrientation();
    configLoading();
    prepareArtworkFile();

    await Firebase.initializeApp();
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Enregistrer les services utilisés par l'application
    Get.put(AudioFileManagerService(), permanent: true);
    Get.put(AudioPlayerService(), permanent: true);

    runApp(OremusApp());
  });
}

class OremusApp extends StatelessWidget {
  OremusApp({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: NetworkStatusOverlay(
        navigatorKey: navigatorKey,
        config: NetworkOverlayConfig(
          backgroundColor: colorRed,
          noConnectionMessage:
              'Connexion à Internet limitée\nVeuillez vérifiez votre réseau.',
          onShow: () => log('Overlay shown'),
          onHide: () => log('Overlay hidden'),
        ),
        child: GetMaterialApp(
          navigatorKey: navigatorKey,
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
          initialBinding: InitialBinding(),
          initialRoute: Routes.SPLASHSCREEN,
          getPages: AppPages.pages,
          builder: EasyLoading.init(builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1)),
              child: MainAppWrapper(child: child!),
            );
          }),
        ),
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
