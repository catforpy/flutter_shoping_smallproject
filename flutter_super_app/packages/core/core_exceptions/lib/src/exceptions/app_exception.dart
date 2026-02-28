/// 应用异常基类
///
/// 所有自定义异常都应该继承这个类
abstract base class AppException implements Exception {
  /// 错误代码
  final String code;

  /// 错误消息
  final String message;

  /// 原始异常
  final dynamic originalException;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  const AppException({
    required this.code,
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('AppException: [$code] $message');

    if (originalException != null) {
      buffer.write('\nCaused by: $originalException');
    }

    if (stackTrace != null) {
      buffer.write('\nStack trace:\n$stackTrace');
    }

    return buffer.toString();
  }

  /// 获取用户友好的错误消息
  String getUserMessage() => message;
}

/// 未知异常
final class UnknownException extends AppException {
  const UnknownException({
    String message = '未知错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'UNKNOWN_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 未实现异常
final class NotImplementedException extends AppException {
  const NotImplementedException({
    String message = '功能未实现',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'NOT_IMPLEMENTED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 不支持的异常
final class UnsupportedException extends AppException {
  const UnsupportedException({
    String message = '不支持的操作',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'UNSUPPORTED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 超时异常
final class TimeoutException extends AppException {
  const TimeoutException({
    String message = '操作超时',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'TIMEOUT',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 取消异常
final class CancelledException extends AppException {
  const CancelledException({
    String message = '操作已取消',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CANCELLED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
