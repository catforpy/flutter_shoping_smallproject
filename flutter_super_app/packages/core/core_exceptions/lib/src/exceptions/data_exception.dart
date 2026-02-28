import 'app_exception.dart' show AppException;

/// 数据异常基类
abstract base class DataException extends AppException {
  const DataException({
    required super.code,
    required super.message,
    super.originalException,
    super.stackTrace,
  });
}

/// 数据不存在
final class DataNotFoundException extends DataException {
  const DataNotFoundException({
    String message = '数据不存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_NOT_FOUND',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据已存在
final class DataAlreadyExistsException extends DataException {
  const DataAlreadyExistsException({
    String message = '数据已存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_ALREADY_EXISTS',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据保存失败
final class DataSaveException extends DataException {
  const DataSaveException({
    String message = '数据保存失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_SAVE_FAILED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据删除失败
final class DataDeleteException extends DataException {
  const DataDeleteException({
    String message = '数据删除失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_DELETE_FAILED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据更新失败
final class DataUpdateException extends DataException {
  const DataUpdateException({
    String message = '数据更新失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_UPDATE_FAILED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据解析失败
final class DataParseException extends DataException {
  const DataParseException({
    String message = '数据解析失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_PARSE_FAILED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据格式错误
final class DataFormatException extends DataException {
  const DataFormatException({
    String message = '数据格式错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_FORMAT_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据冲突
final class DataConflictException extends DataException {
  const DataConflictException({
    String message = '数据冲突',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATA_CONFLICT',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据库异常
final class DatabaseException extends DataException {
  const DatabaseException({
    String message = '数据库操作失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATABASE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 缓存异常
final class CacheException extends DataException {
  const CacheException({
    String message = '缓存操作失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'CACHE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
