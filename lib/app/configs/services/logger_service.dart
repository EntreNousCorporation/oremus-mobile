import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/components/crashlytics_talker_observer.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

class LoggerService {
  static late final Talker talker;

  static Future<void> initialize({required bool showAppLogs}) async {
    final crashlyticsTalkerObserver = CrashlyticsTalkerObserver();
    talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: showAppLogs,
        colors: OremusLogger.logColors,
      ),
      observer: crashlyticsTalkerObserver,
    );

    OremusLogger.setTalkerInstance(talker);
    OremusLogger.info('Application Logger startup initialized');
    FlutterError.onError = (details) {
      talker.handle(details.exception, details.stack);
    };
  }
}
