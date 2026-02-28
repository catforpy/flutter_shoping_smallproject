import 'dart:developer' as developer;

import '../models/log_level.dart' show LogLevel;

/// 应用日志记录器
final class AppLogger {
  /// 日志标签
  final String tag;

  /// 最小日志级别
  LogLevel minLevel;

  AppLogger(
    this.tag, {
    this.minLevel = LogLevel.info,
  });

  /// 创建根日志记录器
  factory AppLogger.root({LogLevel minLevel = LogLevel.info}) {
    return AppLogger('App', minLevel: minLevel);
  }

  /// 记录调试日志
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  /// 记录信息日志
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  /// 记录警告日志
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  /// 记录错误日志
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  /// 记录致命错误日志
  void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);
  }

  /// 记录日志
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!level.shouldLog(minLevel)) return;

    final timestamp = DateTime.now();
    final logMessage = '[$timestamp] [$level] [$tag] $message';

    if (level == LogLevel.error || level == LogLevel.fatal) {
      developer.log(
        logMessage,
        name: tag,
        level: level.value,
        error: error,
        stackTrace: stackTrace,
        time: timestamp,
      );
      // 同时打印到控制台
      if (error != null) {
        print('$logMessage\n$error');
        if (stackTrace != null) {
          print(stackTrace);
        }
      } else {
        print(logMessage);
      }
    } else {
      developer.log(
        logMessage,
        name: tag,
        level: level.value,
        time: timestamp,
      );
      print(logMessage);
    }
  }
}

/// 全局日志记录器实例
final class Log {
  Log._();

  static AppLogger? _rootLogger;

  /// 初始化日志系统
  static void init({LogLevel minLevel = LogLevel.info}) {
    _rootLogger = AppLogger.root(minLevel: minLevel);
  }

  /// 获取根日志记录器
  static AppLogger get root {
    _rootLogger ??= AppLogger.root();
    return _rootLogger!;
  }

  /// 创建指定标签的日志记录器
  static AppLogger create(String tag) {
    return AppLogger(tag, minLevel: root.minLevel);
  }

  /// 快捷方法：记录调试日志
  static void d(String message, {Object? error, StackTrace? stackTrace}) {
    root.debug(message, error: error, stackTrace: stackTrace);
  }

  /// 快捷方法：记录信息日志
  static void i(String message, {Object? error, StackTrace? stackTrace}) {
    root.info(message, error: error, stackTrace: stackTrace);
  }

  /// 快捷方法：记录警告日志
  static void w(String message, {Object? error, StackTrace? stackTrace}) {
    root.warning(message, error: error, stackTrace: stackTrace);
  }

  /// 快捷方法：记录错误日志
  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    root.error(message, error: error, stackTrace: stackTrace);
  }

  /// 快捷方法：记录致命错误日志
  static void f(String message, {Object? error, StackTrace? stackTrace}) {
    root.fatal(message, error: error, stackTrace: stackTrace);
  }
}
