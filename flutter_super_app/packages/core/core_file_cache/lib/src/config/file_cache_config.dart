/// 文件类型枚举
enum FileType {
  image,
  video,
  audio,
  document,
  other,
}

/// 缓存配置
class FileCacheConfig {
  /// 单个文件最大缓存大小（字节）
  final int maxFileSize;

  /// 总缓存大小限制（字节）
  final int maxCacheSize;

  /// 缓存过期时间（默认7天）
  final Duration cacheExpiry;

  /// 是否使用自定义文件名
  final bool useCustomFileName;

  /// 是否显示下载进度日志
  final bool verboseLogging;

  const FileCacheConfig({
    this.maxFileSize = 100 * 1024 * 1024, // 100MB
    this.maxCacheSize = 1024 * 1024 * 1024, // 1GB
    this.cacheExpiry = const Duration(days: 7),
    this.useCustomFileName = false,
    this.verboseLogging = false,
  });

  /// 图片缓存配置（工厂方法）
  static FileCacheConfig image() {
    return const FileCacheConfig(
      maxFileSize: 10 * 1024 * 1024, // 10MB
      cacheExpiry: Duration(days: 30),
    );
  }

  /// 视频缓存配置（工厂方法）
  static FileCacheConfig video() {
    return const FileCacheConfig(
      maxFileSize: 500 * 1024 * 1024, // 500MB
      cacheExpiry: Duration(days: 7),
    );
  }

  /// 音频缓存配置（工厂方法）
  static FileCacheConfig audio() {
    return const FileCacheConfig(
      maxFileSize: 50 * 1024 * 1024, // 50MB
      cacheExpiry: Duration(days: 30),
    );
  }
}
