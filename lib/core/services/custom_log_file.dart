import 'dart:developer' as developer;

class CustomLogFile {
  static const String _name = 'EduPayVerify';

  static void info(String message) {
    developer.log(message, name: _name);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
