/// 文件缓存异常基类
class FileCacheException implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const FileCacheException({
    required this.message,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    if (originalException != null) {
      return 'FileCacheException: $message\n原异常: $originalException';
    }
    return 'FileCacheException: $message';
  }
}

/// 文件下载失败异常
class FileDownloadException extends FileCacheException {
  const FileDownloadException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 文件读取失败异常
class FileReadException extends FileCacheException {
  const FileReadException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 缓存清理失败异常
class CacheCleanupException extends FileCacheException {
  const CacheCleanupException({
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
