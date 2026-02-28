import 'package:core_exceptions/core_exceptions.dart' show NetworkException;

import '../models/response.dart' show ApiResponse;
import 'interceptor.dart' show BaseInterceptor;

/// 错误拦截器
///
/// 统一处理网络错误
final class ErrorInterceptor extends BaseInterceptor {
  @override
  Future<ApiResponse<dynamic>> onResponse(ApiResponse<dynamic> response) async {
    // 如果是错误状态码，抛出异常
    if (!response.isSuccess) {
      throw NetworkException.fromStatusCode(
        response.statusCode,
        response.statusMessage,
      );
    }
    return response;
  }
}
