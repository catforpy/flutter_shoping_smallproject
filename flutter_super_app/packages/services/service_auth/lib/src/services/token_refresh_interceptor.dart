import 'dart:async';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import '../models/auth_token.dart';

/// Token 刷新拦截器
///
/// 自动检测 Token 过期并在需要时刷新
final class TokenRefreshInterceptor {
  final AuthToken? Function() _getCurrentToken;
  final Future<AuthToken?> Function(String refreshToken) _onRefreshToken;
  final void Function(AuthToken newToken) _onTokenUpdated;
  final Future<void> Function() _onRefreshFailed;

  bool _isRefreshing = false;

  TokenRefreshInterceptor({
    required AuthToken? Function() getCurrentToken,
    required Future<AuthToken?> Function(String refreshToken) onRefreshToken,
    required void Function(AuthToken newToken) onTokenUpdated,
    required Future<void> Function() onRefreshFailed,
  })  : _getCurrentToken = getCurrentToken,
        _onRefreshToken = onRefreshToken,
        _onTokenUpdated = onTokenUpdated,
        _onRefreshFailed = onRefreshFailed;

  /// 处理请求前的 Token 检查
  Future<RequestOptions> handleRequest(RequestOptions options) async {
    final token = _getCurrentToken();

    // 没有 Token 或游客模式，跳过
    if (token == null || token.isGuest) {
      return options;
    }

    // Token 即将过期，尝试刷新
    if (token.isAboutToExpire && token.canRefresh) {
      Log.i('Token 即将过期，准备刷新');
      await _refreshTokenIfNeeded();
    }

    // 如果正在刷新，等待刷新完成
    if (_isRefreshing) {
      await _waitForRefresh();
      // 重新获取最新的 Token
      final newToken = _getCurrentToken();
      if (newToken != null) {
        final updatedHeaders = Map<String, String>.from(options.headers ?? {});
        updatedHeaders['Authorization'] =
            '${newToken.tokenType} ${newToken.accessToken}';
        return options.copyWith(headers: updatedHeaders);
      }
    } else if (token.isExpired) {
      // Token 已过期且无法刷新，请求失败
      Log.w('Token 已过期且无法刷新');
      throw UnauthorizedException('Token 已过期，请重新登录');
    } else {
      // 添加 Token 到请求头
      final updatedHeaders = Map<String, String>.from(options.headers ?? {});
      updatedHeaders['Authorization'] = '${token.tokenType} ${token.accessToken}';
      return options.copyWith(headers: updatedHeaders);
    }

    return options;
  }

  /// 处理 401 响应
  Future<bool> handleResponseError(int statusCode) async {
    // 如果是 401 错误，尝试刷新 Token
    if (statusCode == 401) {
      Log.w('收到 401 响应，尝试刷新 Token');
      return await _refreshTokenIfNeeded();
    }
    return false;
  }

  /// 刷新 Token（如果需要）
  Future<bool> _refreshTokenIfNeeded() async {
    // 如果正在刷新，等待刷新完成
    if (_isRefreshing) {
      await _waitForRefresh();
      return true;
    }

    final token = _getCurrentToken();
    if (token == null || !token.canRefresh) {
      return false;
    }

    _isRefreshing = true;
    Log.i('开始刷新 Token');

    try {
      final newToken = await _onRefreshToken(token.refreshToken!);
      if (newToken != null) {
        _onTokenUpdated(newToken);
        Log.i('Token 刷新成功');
        return true;
      } else {
        Log.e('Token 刷新失败：返回的 Token 为空');
        await _onRefreshFailed();
        return false;
      }
    } catch (e) {
      Log.e('Token 刷新失败', error: e);
      await _onRefreshFailed();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 等待刷新完成
  Future<void> _waitForRefresh() async {
    int attempts = 0;
    const maxAttempts = 50; // 最多等待 5 秒

    while (_isRefreshing && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (_isRefreshing) {
      Log.w('等待 Token 刷新超时');
    }
  }

  /// 重置刷新状态
  void reset() {
    _isRefreshing = false;
  }
}

/// 未授权异常
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}
