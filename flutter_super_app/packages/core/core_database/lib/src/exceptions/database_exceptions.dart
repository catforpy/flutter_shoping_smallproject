import 'package:core_exceptions/core_exceptions.dart' show DataException;

/// 数据库初始化异常
final class DatabaseInitException extends DataException {
  const DatabaseInitException({
    String message = '数据库初始化失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATABASE_INIT_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据库查询异常
final class DatabaseQueryException extends DataException {
  const DatabaseQueryException({
    String message = '数据库查询失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATABASE_QUERY_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据库写入异常
final class DatabaseWriteException extends DataException {
  const DatabaseWriteException({
    String message = '数据库写入失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATABASE_WRITE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 数据库事务异常
final class DatabaseTransactionException extends DataException {
  const DatabaseTransactionException({
    String message = '数据库事务失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'DATABASE_TRANSACTION_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 表不存在异常
final class TableNotFoundException extends DataException {
  const TableNotFoundException({
    String message = '表不存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'TABLE_NOT_FOUND',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
