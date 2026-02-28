import 'dart:async';
import '../models/request_options.dart' show RequestOptions;
import '../models/response.dart' show ApiResponse;

/// 拦截器接口
abstract base class Interceptor {
  const Interceptor();

  /// 请求拦截
  Future<RequestOptions> onRequest(RequestOptions options);

  /// 响应拦截
  Future<ApiResponse<dynamic>> onResponse(ApiResponse<dynamic> response);

  /// 错误拦截
  Future<dynamic> onError(dynamic error);
}

/// 基础拦截器实现
base class BaseInterceptor extends Interceptor {
  const BaseInterceptor();

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    return options;
  }

  @override
  Future<ApiResponse<dynamic>> onResponse(ApiResponse<dynamic> response) async {
    return response;
  }

  @override
  Future<dynamic> onError(dynamic error) async {
    return error;
  }
}
