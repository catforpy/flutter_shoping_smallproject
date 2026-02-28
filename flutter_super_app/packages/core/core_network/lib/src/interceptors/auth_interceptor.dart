import '../models/request_options.dart' show RequestOptions;
import '../models/response.dart' show ApiResponse;
import 'interceptor.dart' show BaseInterceptor;

/// 认证拦截器
///
/// 自动添加 Token 到请求头
final class AuthInterceptor extends BaseInterceptor {
  /// Token 获取函数
  final String? Function() tokenGetter;

  /// Token 刷新函数
  final Future<String?> Function()? tokenRefresher;

  /// Token 失效处理
  final void Function()? onTokenExpired;

  const AuthInterceptor({
    required this.tokenGetter,
    this.tokenRefresher,
    this.onTokenExpired,
  });

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    // 如果不需要认证，直接返回
    if (!options.requireAuth) {
      return options;
    }

    // 获取 Token
    final token = tokenGetter();
    if (token == null || token.isEmpty) {
      return options;
    }

    // 添加 Authorization 头
    final headers = Map<String, String>.from(options.headers ?? {});
    headers['Authorization'] = 'Bearer $token';

    return options.copyWith(headers: headers);
  }

  @override
  Future<ApiResponse<dynamic>> onResponse(ApiResponse<dynamic> response) async {
    // 处理 401 未授权错误
    if (response.statusCode == 401) {
      // 尝试刷新 Token
      if (tokenRefresher != null) {
        final newToken = await tokenRefresher!();
        if (newToken != null) {
          // TODO: 重试请求
        }
      }

      // Token 失效回调
      onTokenExpired?.call();
    }

    return response;
  }
}
