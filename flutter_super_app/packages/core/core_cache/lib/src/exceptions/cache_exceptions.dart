import 'package:core_exceptions/core_exceptions.dart' show DataException;

/// 缓存读取异常
final class CacheReadException extends DataException {
  const CacheReadException({
    String message = '缓存读取失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CACHE_READ_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 缓存写入异常
final class CacheWriteException extends DataException {
  const CacheWriteException({
    String message = '缓存写入失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CACHE_WRITE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 缓存删除异常
final class CacheDeleteException extends DataException {
  const CacheDeleteException({
    String message = '缓存删除失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CACHE_DELETE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 缓存已过期异常
final class CacheExpiredException extends DataException {
  const CacheExpiredException({
    String message = '缓存已过期',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CACHE_EXPIRED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 缓存不存在异常
final class CacheNotFoundException extends DataException {
  const CacheNotFoundException({
    String message = '缓存不存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CACHE_NOT_FOUND',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
