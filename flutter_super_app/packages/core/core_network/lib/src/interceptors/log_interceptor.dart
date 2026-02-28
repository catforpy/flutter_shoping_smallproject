import 'dart:developer' as developer;

import '../models/request_options.dart' show RequestOptions;
import '../models/response.dart' show ApiResponse;
import 'interceptor.dart' show BaseInterceptor;

/// 日志拦截器
final class LogInterceptor extends BaseInterceptor {
  /// 是否打印请求头
  final bool logHeaders;

  /// 是否打印请求体
  final bool logBody;

  const LogInterceptor({
    this.logHeaders = false,
    this.logBody = true,
  });

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    _printLog('┌────────────── Request ──────────────');
    _printLog('│ Method: ${options.method.value}');
    _printLog('│ URL: ${options.buildUrl()}');

    if (logHeaders && options.headers != null) {
      _printLog('│ Headers:');
      options.headers!.forEach((key, value) {
        _printLog('│   $key: $value');
      });
    }

    if (logBody && options.body != null) {
      _printLog('│ Body: ${options.body}');
    }

    _printLog('└────────────────────────────────────');
    return options;
  }

  @override
  Future<ApiResponse<dynamic>> onResponse(ApiResponse<dynamic> response) async {
    _printLog('┌────────────── Response ─────────────');
    _printLog('│ Status: ${response.statusCode}');
    _printLog('│ Data: ${response.data}');
    _printLog('└────────────────────────────────────');
    return response;
  }

  @override
  Future<dynamic> onError(dynamic error) async {
    _printLog('┌────────────── Error ───────────────');
    _printLog('│ Error: $error');
    _printLog('└────────────────────────────────────');
    return error;
  }

  void _printLog(String message) {
    developer.log(message, name: 'Network');
    print(message);
  }
}
