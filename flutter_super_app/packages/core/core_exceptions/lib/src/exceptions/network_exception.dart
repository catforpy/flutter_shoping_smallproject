import 'app_exception.dart' show AppException;

/// 网络异常基类
abstract base class NetworkException extends AppException {
  const NetworkException({
    required super.code,
    required super.message,
    super.originalException,
    super.stackTrace,
  });

  factory NetworkException.fromStatusCode(int statusCode, String? message) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message: message ?? '请求参数错误');
      case 401:
        return UnauthorizedException(message: message ?? '未授权，请先登录');
      case 403:
        return ForbiddenException(message: message ?? '无权访问');
      case 404:
        return NotFoundException(message: message ?? '请求的资源不存在');
      case 408:
        return const RequestTimeoutException();
      case 429:
        return TooManyRequestsException(message: message ?? '请求过于频繁');
      case 500:
        return ServerException(message: message ?? '服务器内部错误');
      case 502:
        return BadGatewayException(message: message ?? '网关错误');
      case 503:
        return ServiceUnavailableException(message: message ?? '服务暂时不可用');
      case 504:
        return GatewayTimeoutException(message: message ?? '网关超时');
      default:
        return HttpException(
          statusCode: statusCode,
          message: message ?? 'HTTP 错误: $statusCode',
        );
    }
  }
}

/// 通用 HTTP 异常
final class HttpException extends NetworkException {
  final int statusCode;

  const HttpException({
    required this.statusCode,
    String? message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'HTTP_ERROR',
          message: message ?? 'HTTP 请求失败',
          originalException: originalException,
          stackTrace: stackTrace,
        );

  @override
  String getUserMessage() {
    return '网络请求失败 (错误码: $statusCode)';
  }
}

/// 400 错误请求
final class BadRequestException extends NetworkException {
  const BadRequestException({
    String message = '请求参数错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'BAD_REQUEST',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 401 未授权
final class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    String message = '未授权，请先登录',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'UNAUTHORIZED',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 403 禁止访问
final class ForbiddenException extends NetworkException {
  const ForbiddenException({
    String message = '无权访问',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'FORBIDDEN',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 404 未找到
final class NotFoundException extends NetworkException {
  const NotFoundException({
    String message = '请求的资源不存在',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'NOT_FOUND',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 408 请求超时
final class RequestTimeoutException extends NetworkException {
  const RequestTimeoutException({
    String message = '请求超时',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'REQUEST_TIMEOUT',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 429 请求过多
final class TooManyRequestsException extends NetworkException {
  const TooManyRequestsException({
    String message = '请求过于频繁，请稍后再试',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'TOO_MANY_REQUESTS',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 500 服务器错误
final class ServerException extends NetworkException {
  const ServerException({
    String message = '服务器内部错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'SERVER_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 502 网关错误
final class BadGatewayException extends NetworkException {
  const BadGatewayException({
    String message = '网关错误',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'BAD_GATEWAY',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 503 服务不可用
final class ServiceUnavailableException extends NetworkException {
  const ServiceUnavailableException({
    String message = '服务暂时不可用',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'SERVICE_UNAVAILABLE',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 504 网关超时
final class GatewayTimeoutException extends NetworkException {
  const GatewayTimeoutException({
    String message = '网关超时',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'GATEWAY_TIMEOUT',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 网络连接失败
final class NetworkConnectException extends NetworkException {
  const NetworkConnectException({
    String message = '网络连接失败，请检查网络设置',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'NETWORK_CONNECT_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}

/// 网络解析错误
final class NetworkParseException extends NetworkException {
  const NetworkParseException({
    String message = '数据解析失败',
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
          code: 'NETWORK_PARSE_ERROR',
          message: message,
          originalException: originalException,
          stackTrace: stackTrace,
        );
}
