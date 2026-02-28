import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:core_logging/core_logging.dart';
import 'config/file_cache_config.dart';
import 'exceptions/file_cache_exceptions.dart';

/// 文件缓存管理器
///
/// 功能特性：
/// - 下载并缓存网络文件（图片、视频、音频等）
/// - 自动从缓存读取已下载的文件
/// - 支持缓存过期策略
/// - 支持磁盘空间管理
/// - 支持下载进度回调
///
/// 使用示例：
/// ```dart
/// // 获取文件（自动缓存）
/// final file = await FileCacheManager.get(url);
///
/// // 带进度回调
/// final file = await FileCacheManager.get(
///   url,
///   onProgress: (received, total) => print('${(received/total*100).toInt()}%'),
/// );
///
/// // 预加载文件
/// await FileCacheManager.preload([url1, url2, url3]);
///
/// // 清除指定文件缓存
/// await FileCacheManager.remove(url);
///
/// // 清除所有缓存
/// await FileCacheManager.clearAll();
/// ```
final class FileCacheManager {
  factory FileCacheManager() => _instance;

  static final FileCacheManager _instance = FileCacheManager._internal();

  FileCacheManager._internal();

  /// Dio 实例
  Dio? _dioInstance;

  /// 获取 Dio 实例
  Dio get _dio => _dioInstance ??= Dio();

  /// 不同文件类型的缓存管理器
  final Map<FileType, CacheManager> _cacheManagers = {};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化缓存管理器
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      Log.i('🚀 FileCacheManager 初始化');

      // 初始化不同类型的缓存管理器
      _cacheManagers[FileType.image] = _createCacheManager('image_cache');
      _cacheManagers[FileType.video] = _createCacheManager('video_cache');
      _cacheManagers[FileType.audio] = _createCacheManager('audio_cache');
      _cacheManagers[FileType.document] = _createCacheManager('document_cache');
      _cacheManagers[FileType.other] = _createCacheManager('other_cache');

      _isInitialized = true;
      Log.i('✅ FileCacheManager 初始化成功');
    } catch (e, stackTrace) {
      Log.e('❌ FileCacheManager 初始化失败', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 创建缓存管理器
  CacheManager _createCacheManager(String key) {
    return CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 100,
        fileService: HttpFileService(),
      ),
    );
  }

  /// 确保已初始化
  Future<void> _ensureInit() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// 获取文件（自动缓存）
  ///
  /// 参数：
  /// - url: 文件URL
  /// - type: 文件类型
  /// - config: 缓存配置
  /// - onProgress: 下载进度回调
  ///
  /// 返回：缓存文件
  static Future<File> get(
    String url, {
    FileType type = FileType.other,
    FileCacheConfig? config,
    void Function(int received, int total)? onProgress,
  }) async {
    final instance = FileCacheManager();
    await instance._ensureInit();

    return instance._getFile(url, type: type, config: config, onProgress: onProgress);
  }

  /// 内部获取文件方法
  Future<File> _getFile(
    String url, {
    required FileType type,
    FileCacheConfig? config,
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      Log.i('📥 获取文件: $url, type=$type');

      final cacheManager = _cacheManagers[type]!;

      // 检查文件是否已缓存
      final fileInfo = await cacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        Log.i('✅ 文件命中缓存: $url');
        return fileInfo.file;
      }

      Log.i('⬇️ 开始下载文件: $url');

      // 下载文件
      final downloadedFile = await _downloadFile(
        url,
        cacheManager,
        onProgress: onProgress,
      );

      Log.i('✅ 文件下载完成: $url');
      return downloadedFile;
    } catch (e, stackTrace) {
      Log.e('❌ 获取文件失败: $url', error: e, stackTrace: stackTrace);
      throw FileDownloadException(
        message: '下载文件失败: $url',
        originalException: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 下载文件
  Future<File> _downloadFile(
    String url,
    CacheManager cacheManager, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      // 创建临时目录
      final tempDir = await getTemporaryDirectory();
      final fileName = url.hashCode.toString();
      final tempFile = File('${tempDir.path}/$fileName');

      // 下载文件
      final response = await _dio.download(
        url,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            Log.d('下载进度: ${((received / total) * 100).toStringAsFixed(1)}%');
            onProgress?.call(received.toInt(), total.toInt());
          }
        },
      );

      if (response.statusCode == 200) {
        // 读取文件内容为字节数组
        final fileBytes = await tempFile.readAsBytes();
        // 保存到缓存
        final file = await cacheManager.putFile(url, fileBytes);
        // 删除临时文件
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        return file;
      } else {
        throw FileDownloadException(
          message: 'HTTP ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } catch (e) {
      throw FileDownloadException(
        message: '下载文件失败',
        originalException: e,
      );
    }
  }

  /// 预加载多个文件
  ///
  /// 参数：
  /// - urls: 文件URL列表
  /// - type: 文件类型
  ///
  /// 返回：成功缓存的文件数量
  static Future<int> preload(
    List<String> urls, {
    FileType type = FileType.other,
  }) async {
    final instance = FileCacheManager();
    await instance._ensureInit();

    Log.i('📦 预加载 ${urls.length} 个文件');

    int successCount = 0;
    for (final url in urls) {
      try {
        await instance._getFile(url, type: type);
        successCount++;
      } catch (e) {
        Log.w('预加载失败: $url, error: $e');
      }
    }

    Log.i('✅ 预加载完成: $successCount/${urls.length} 成功');
    return successCount;
  }

  /// 移除指定文件的缓存
  static Future<void> remove(String url) async {
    final instance = FileCacheManager();
    await instance._ensureInit();

    try {
      // 尝试从所有缓存管理器中删除
      for (final cacheManager in instance._cacheManagers.values) {
        await cacheManager.removeFile(url);
      }
      Log.i('🗑️ 移除缓存: $url');
    } catch (e) {
      Log.e('❌ 移除缓存失败: $url', error: e);
    }
  }

  /// 清除所有缓存
  static Future<void> clearAll() async {
    try {
      Log.i('🗑️ 清除所有文件缓存');

      // 清空所有缓存管理器
      final instance = FileCacheManager();
      if (instance._isInitialized) {
        for (final cacheManager in instance._cacheManagers.values) {
          await cacheManager.emptyCache();
        }
      }

      // 清空临时目录
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      Log.i('✅ 所有缓存已清除');
    } catch (e) {
      Log.e('❌ 清除缓存失败', error: e);
      throw CacheCleanupException(
        message: '清除缓存失败',
        originalException: e,
      );
    }
  }

  /// 获取缓存大小（字节）
  static Future<int> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;

      final entities = tempDir.listSync(recursive: true, followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      Log.e('❌ 获取缓存大小失败', error: e);
      return 0;
    }
  }

  /// 格式化缓存大小显示
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
