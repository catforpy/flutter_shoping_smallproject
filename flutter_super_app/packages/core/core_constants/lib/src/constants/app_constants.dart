/// 应用常量
final class AppConstants {
  const AppConstants._();

  /// 应用名称
  static const String appName = 'Flutter Super App';

  /// 应用包名
  static const String appPackage = 'com.example.flutter_super_app';

  /// 应用版本
  static const String appVersion = '1.0.0';

  /// 应用版本号
  static const int appBuildNumber = 1;

  /// 默认语言
  static const String defaultLanguage = 'zh-CN';

  /// 默认时区
  static const String defaultTimeZone = 'Asia/Shanghai';

  /// 默认每页数量
  static const int defaultPageSize = 20;

  /// 最大每页数量
  static const int maxPageSize = 100;

  /// 最小每页数量
  static const int minPageSize = 10;

  /// 默认超时时间（秒）
  static const int defaultTimeoutSeconds = 30;

  /// 图片最大大小（MB）
  static const int maxImageSizeMB = 10;

  /// 视频最大大小（MB）
  static const int maxVideoSizeMB = 100;

  /// 文件最大大小（MB）
  static const int maxFileSizeMB = 50;

  /// 默认图片质量
  static const int defaultImageQuality = 85;

  /// 缓存过期时间（天）
  static const int cacheExpireDays = 7;

  /// 最大重试次数
  static const int maxRetryCount = 3;

  /// 用户名最小长度
  static const int usernameMinLength = 4;

  /// 用户名最大长度
  static const int usernameMaxLength = 20;

  /// 密码最小长度
  static const int passwordMinLength = 8;

  /// 密码最大长度
  static const int passwordMaxLength = 20;

  /// 验证码长度
  static const int verificationCodeLength = 6;

  /// 验证码过期时间（秒）
  static const int verificationCodeExpireSeconds = 300;
}
