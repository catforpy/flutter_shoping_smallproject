/// API 响应
final class ApiResponse<T> {
  /// 状态码
  final int statusCode;

  /// 响应数据
  final T? data;

  /// 响应头
  final Map<String, String>? headers;

  /// 响应消息
  final String? statusMessage;

  const ApiResponse({
    required this.statusCode,
    this.data,
    this.headers,
    this.statusMessage,
  });

  /// 是否成功（状态码 200-299）
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// 是否客户端错误（400-499）
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// 是否服务端错误（500-599）
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// 转换数据类型
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    return ApiResponse<R>(
      statusCode: statusCode,
      data: data != null ? mapper(data as T) : null,
      headers: headers,
      statusMessage: statusMessage,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, data: $data)';
  }
}

/// 统一的 API 响应格式
final class ApiDataResponse<T> {
  /// 业务状态码
  final int code;

  /// 业务消息
  final String? message;

  /// 业务数据
  final T? data;

  /// 是否成功
  final bool success;

  const ApiDataResponse({
    required this.code,
    this.message,
    this.data,
    required this.success,
  });

  /// 从 JSON 创建
  factory ApiDataResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataParser,
  }) {
    return ApiDataResponse<T>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String?,
      data: dataParser != null && json['data'] != null
          ? dataParser(json['data'])
          : json['data'] as T?,
      success: json['success'] as bool? ?? json['code'] == 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data,
      'success': success,
    };
  }

  @override
  String toString() {
    return 'ApiDataResponse(code: $code, message: $message, success: $success)';
  }
}
