import 'auth_type.dart';

/// 认证 Token
final class AuthToken {
  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String? refreshToken;

  /// Token 类型
  final String tokenType;

  /// 过期时间（秒）
  final int? expiresIn;

  /// 获取 Token 的时间
  final DateTime acquiredAt;

  /// 认证类型
  final AuthType authType;

  /// 设备唯一标识（游客模式使用）
  final String? deviceId;

  AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    DateTime? acquiredAt,
    this.authType = AuthType.phone,
    this.deviceId,
  }) : acquiredAt = acquiredAt ?? DateTime.now();

  /// 是否已过期
  bool get isExpired {
    if (expiresIn == null) return false;
    final expiryTime = acquiredAt.add(Duration(seconds: expiresIn!));
    return DateTime.now().isAfter(expiryTime);
  }

  /// 是否即将过期（剩余时间少于5分钟）
  bool get isAboutToExpire {
    final remaining = remainingSeconds;
    if (remaining == null) return false;
    return remaining < 300; // 5分钟
  }

  /// 获取过期时间
  DateTime? get expiryTime {
    if (expiresIn == null) return null;
    return acquiredAt.add(Duration(seconds: expiresIn!));
  }

  /// 剩余有效时间（秒）
  int? get remainingSeconds {
    final expiry = expiryTime;
    if (expiry == null) return null;
    final remaining = expiry.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// 是否为游客模式
  bool get isGuest => authType == AuthType.guest;

  /// 是否可以刷新 Token
  bool get canRefresh => refreshToken != null && !isGuest;

  /// 从 JSON 创建
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as int?,
      acquiredAt: json['acquiredAt'] != null
          ? DateTime.parse(json['acquiredAt'] as String)
          : null,
      authType: json['authType'] != null
          ? AuthType.values.firstWhere(
              (e) => e.name == json['authType'],
              orElse: () => AuthType.phone,
            )
          : AuthType.phone,
      deviceId: json['deviceId'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'acquiredAt': acquiredAt.toIso8601String(),
      'authType': authType.name,
      'deviceId': deviceId,
    };
  }

  /// 创建副本
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    DateTime? acquiredAt,
    AuthType? authType,
    String? deviceId,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      authType: authType ?? this.authType,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  String toString() =>
      'AuthToken(tokenType: $tokenType, expiresIn: $expiresIn, isExpired: $isExpired)';
}
