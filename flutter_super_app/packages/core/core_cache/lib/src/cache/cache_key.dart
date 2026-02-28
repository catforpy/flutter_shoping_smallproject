/// 缓存键类
///
/// 提供类型安全的缓存键管理
final class CacheKey<T> {
  /// 键名
  final String key;

  /// 默认值
  final T? defaultValue;

  const CacheKey(this.key, {this.defaultValue});
}

/// 缓存键常量
final class CacheKeys {
  // 用户相关
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userInfo = 'user_info';

  // 设置相关
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String isFirstLaunch = 'is_first_launch';

  // 缓存相关
  static const String cacheVersion = 'cache_version';
  static const String lastUpdateTime = 'last_update_time';

  CacheKeys._();
}
