import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(_getLogMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.i(_getLogMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.w(_getLogMessage(message), error: error, stackTrace: stackTrace);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      stackTrace ??= StackTrace.current;
      final trace = Chain.forTrace(stackTrace).terse;
      _logger.e(_getLogMessage(message), error: error, stackTrace: trace);
    }
  }

  static String _getLogMessage(String message) {
    final trace = Chain.current().terse;
    final frames = trace.toTrace().frames;

    if (frames.isEmpty) return message;

    final caller = frames[2];
    return '${caller.uri}:${caller.line} - $message';
  }
}
