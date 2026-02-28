import 'package:service_user/service_user.dart';

/// 认证结果
final class AuthResult {
  /// 是否成功
  final bool isSuccess;

  /// 用户信息（游客模式为 null）
  final User? user;

  /// Token
  final String? token;

  /// 错误消息
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.token,
    this.errorMessage,
  });

  /// 创建成功结果
  factory AuthResult.success({
    required User? user,
    required String token,
  }) {
    return AuthResult(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  /// 创建失败结果
  factory AuthResult.failure(String message) {
    return AuthResult(
      isSuccess: false,
      errorMessage: message,
    );
  }

  /// 是否为游客模式
  bool get isGuest => user == null;

  @override
  String toString() =>
      'AuthResult(isSuccess: $isSuccess, user: $user, error: $errorMessage)';
}
