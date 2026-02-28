/// 存储键常量
///
/// 用于本地存储的键名
final class StorageKeys {
  const StorageKeys._();

  // ==================== 用户相关 ====================
  /// 当前用户信息
  static const String currentUser = 'current_user';

  /// 用户 Token
  static const String accessToken = 'access_token';

  /// 刷新 Token
  static const String refreshToken = 'refresh_token';

  /// Token 过期时间
  static const String tokenExpireTime = 'token_expire_time';

  // ==================== 设置相关 ====================
  /// 语言设置
  static const String language = 'language';

  /// 主题设置
  static const String theme = 'theme';

  /// 是否开启通知
  static const String notificationEnabled = 'notification_enabled';

  // ==================== 缓存相关 ====================
  /// 首页数据缓存
  static const String homeCache = 'home_cache';

  /// 用户列表缓存
  static const String userListCache = 'user_list_cache';

  // ==================== 其他 ====================
  /// 是否首次启动
  static const String isFirstLaunch = 'is_first_launch';

  /// 最后登录时间
  static const String lastLoginTime = 'last_login_time';

  /// 设备 ID
  static const String deviceId = 'device_id';

  /// 隐私协议已同意
  static const String privacyAgreed = 'privacy_agreed';
}
