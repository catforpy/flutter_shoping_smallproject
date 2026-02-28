import 'app_exception.dart' show AppException;

/// 认证异常基类
abstract base class AuthException extends AppException {
  const AuthException({
    required super.code,
    required super.message,
    super.originalException,
    super.stackTrace,
  });
}

/// Token 失效
final class TokenExpiredException extends AuthException {
  const TokenExpiredException({
    String message = '登录已过期，请重新登录',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'TOKEN_EXPIRED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// Token 无效
final class TokenInvalidException extends AuthException {
  const TokenInvalidException({
    String message = '登录信息无效，请重新登录',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'TOKEN_INVALID',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 用户未登录
final class NotLoginException extends AuthException {
  const NotLoginException({
    String message = '您还未登录',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'NOT_LOGIN',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 用户名或密码错误
final class UsernamePasswordException extends AuthException {
  const UsernamePasswordException({
    String message = '用户名或密码错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'USERNAME_PASSWORD_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 验证码错误
final class VerificationCodeException extends AuthException {
  const VerificationCodeException({
    String message = '验证码错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'VERIFICATION_CODE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 验证码已过期
final class VerificationCodeExpiredException extends AuthException {
  const VerificationCodeExpiredException({
    String message = '验证码已过期',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'VERIFICATION_CODE_EXPIRED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 账号已被禁用
final class AccountDisabledException extends AuthException {
  const AccountDisabledException({
    String message = '账号已被禁用',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'ACCOUNT_DISABLED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 账号已存在
final class AccountAlreadyExistsException extends AuthException {
  const AccountAlreadyExistsException({
    String message = '账号已存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'ACCOUNT_ALREADY_EXISTS',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 账号不存在
final class AccountNotExistsException extends AuthException {
  const AccountNotExistsException({
    String message = '账号不存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'ACCOUNT_NOT_EXISTS',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 权限不足
final class PermissionDeniedException extends AuthException {
  const PermissionDeniedException({
    String message = '权限不足',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'PERMISSION_DENIED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
