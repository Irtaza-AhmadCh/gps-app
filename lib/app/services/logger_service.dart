import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// Custom log printer with enhanced formatting, colors, and timestamps.
class CustomPrinter extends LogPrinter {
  final PrettyPrinter _prettyPrinter;

  CustomPrinter()
      : _prettyPrinter = PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          excludeBox: const {},
          noBoxingByDefault: false,
          excludePaths: const [],
          levelColors: {
            Level.trace: AnsiColor.fg(93), // Electric Purple 💜
            Level.debug: AnsiColor.fg(200), // Neon Cyan 🌀
            Level.info: AnsiColor.fg(200), // Bright Cyan 🩵
            Level.warning: AnsiColor.fg(214), // Vivid Orange ⚠️
            Level.error: AnsiColor.fg(197), // Bright Crimson ⛔
            Level.wtf: AnsiColor.fg(200), // Hot Pink 🔥
          },
          levelEmojis: {
            Level.trace: '💜 ',
            Level.debug: '🌀 ',
            Level.info: '🩵 ',
            Level.warning: '⚡ ',
            Level.error: '⛔ ',
            Level.wtf: '🔥 ',
          },
        );

  @override
  List<String> log(LogEvent event) {
    final output = _prettyPrinter.log(event);
    final dateTime = DateTime.now();
    final formattedTime = DateFormat('dd-MM-yyyy hh:mm:ss a').format(dateTime);
    final levelName = event.level.name.toUpperCase();
    return output
        .map((line) => '[📅 $formattedTime] [$levelName] $line')
        .toList();
  }
}

/// Singleton service for logging with custom formatting.
class LoggerService {
  LoggerService._();

  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: CustomPrinter(),
    level: kDebugMode ? Level.trace : Level.warning,
  );

  /// Returns the singleton logger instance.
  static Logger get instance => _logger;

  /// Logs a debug message (only in debug mode).
  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an info message (only in debug mode).
  static void logInfo(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }
 /// Logs an info message (only in debug mode).
  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.i(message, error: error, stackTrace: stackTrace);
  }
  /// Logs a warning message (only in debug mode).
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message (only in debug mode).
  static void logError(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

   static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Logs a verbose message (only in debug mode).
  static void v(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.v(message, error: error, stackTrace: stackTrace);
  }
  
  


  /// Logs a WTF message (only in debug mode).
  static void wtf(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) _logger.wtf(message, error: error, stackTrace: stackTrace);
  }
}
