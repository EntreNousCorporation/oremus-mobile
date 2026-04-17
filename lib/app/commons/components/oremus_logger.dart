import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class OremusLogger {
  static late final Talker _instance;

  static final Map<String, AnsiPen> logColors = {
    LogLevel.info.name: AnsiPen()..rgb(r: 0.13, g: 0.59, b: 0.95),
    LogLevel.warning.name: AnsiPen()..rgb(r: 1, g: 0.6, b: 0),
    LogLevel.error.name: AnsiPen()..red(),
    LogLevel.debug.name: AnsiPen()..rgb(r: 0.6, g: 0.15, b: 0.69),
  };

  static void setTalkerInstance(Talker talker) {
    _instance = talker;
  }

  static String _getCallerInfo() {
    final stackTrace = StackTrace.current;
    final frames = stackTrace.toString().split('\n');

    // Cherche la première frame qui n'est pas dans pans_logger.dart
    for (final frame in frames) {
      if (!frame.contains('oremus_logger.dart')) {
        final regExp = RegExp(r'(?:#\d+\s+)?(.+) \((.+?):(\d+)(?::\d+)?\)');
        final match = regExp.firstMatch(frame.trim());

        if (match != null) {
          final file = match.group(2); // Nom du fichier
          final line = match.group(3); // Numéro de ligne
          return '$file:$line';
        }
      }
    }

    return 'Unknown location';
  }

  static void _logWithTrace(String message, LogLevel level, {String? title}) {
    final callerInfo = _getCallerInfo();
    final logMessage = TalkerLog(
      '$message\nAt: $callerInfo',
      title: title ?? level.name.toUpperCase(),
      logLevel: level,
    );
    _instance.logCustom(logMessage);
  }

  static void info(String message, {String? title}) =>
      _logWithTrace(message, LogLevel.info, title: title);

  static void warning(String message, {String? title}) =>
      _logWithTrace(message, LogLevel.warning, title: title);

  static void error(String message, {String? title}) =>
      _logWithTrace(message, LogLevel.error, title: title);

  static void debug(String message, {String? title}) =>
      _logWithTrace(message, LogLevel.debug, title: title);

  static void critical(String message,
      {String? title, Object? error, StackTrace? stackTrace}) {
    final callerInfo = _getCallerInfo();
    _instance.critical(
      '$message\nAt: $callerInfo',
      error,
      stackTrace ?? StackTrace.current,
    );
  }

  static Widget createLogScreen({
    required String appName,
  }) {
    return TalkerScreen(
      talker: _instance,
      appBarTitle: '$appName Logs',
      theme: const TalkerScreenTheme(
        cardColor: Colors.white,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        logColors: {
          TalkerKey.httpResponse: Colors.green,
          TalkerKey.error: Colors.redAccent,
          TalkerKey.info: Color.fromRGBO(33, 150, 242, 1),
          TalkerKey.warning: Color.fromRGBO(255, 153, 0, 1),
          TalkerKey.debug: Color.fromRGBO(153, 38, 176, 1),
        },
      ),
    );
  }
}
