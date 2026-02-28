import 'app_exception.dart' show AppException;

/// 验证异常
final class ValidationException extends AppException {
  /// 验证错误详情（字段名 -> 错误消息）
  final Map<String, String>? errors;

  const ValidationException({
    String message = '数据验证失败',
    this.errors,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'VALIDATION_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );

  /// 获取第一个错误消息
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    return errors!.values.first;
  }

  /// 获取指定字段的错误消息
  String? getErrorFor(String field) {
    return errors?[field];
  }

  @override
  String getUserMessage() {
    if (firstError != null) {
      return firstError!;
    }
    return message;
  }
}

/// 参数为空异常
final class NullParamException extends AppException {
  final String? paramName;

  const NullParamException({
    this.paramName,
    String message = '参数不能为空',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'NULL_PARAM',
          message: paramName != null ? '$paramName: $message' : message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 参数格式错误异常
final class InvalidParamException extends AppException {
  final String? paramName;

  const InvalidParamException({
    this.paramName,
    String message = '参数格式错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'INVALID_PARAM',
          message: paramName != null ? '$paramName: $message' : message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 参数范围错误异常
final class OutOfRangeException extends AppException {
  final String? paramName;

  const OutOfRangeException({
    this.paramName,
    String message = '参数超出范围',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'OUT_OF_RANGE',
          message: paramName != null ? '$paramName: $message' : message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 文件大小超出限制异常
final class FileSizeLimitException extends AppException {
  final int maxSize;
  final int actualSize;

  const FileSizeLimitException({
    required this.maxSize,
    required this.actualSize,
    String? message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'FILE_SIZE_LIMIT',
          message: message ?? '文件大小超出限制（最大 ${maxSize}MB）',
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 文件类型不支持异常
final class FileNotSupportedException extends AppException {
  final String? fileType;

  const FileNotSupportedException({
    this.fileType,
    String message = '不支持的文件类型',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'FILE_NOT_SUPPORTED',
          message: fileType != null ? '$fileType: $message' : message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
