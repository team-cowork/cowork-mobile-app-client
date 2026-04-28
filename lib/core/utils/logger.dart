import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 앱 로거
class Logger {
  Logger._();

  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      developer.log(message, name: tag ?? 'DEBUG');
    }
  }

  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? 'ERROR',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
