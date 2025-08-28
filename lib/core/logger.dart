import 'package:l/l.dart';

/// Thin adapter over `package:l` to keep existing call sites.
class Log {
  static void i(String message) => l.i(message);
  static void d(String message) => l.d(message);
  static void w(String message) => l.w(message);
  static void e(String message, [Object? error]) =>
      error == null ? l.e(message) : l.e('$message -> $error');
}
