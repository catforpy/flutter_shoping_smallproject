import 'dart:async';
import 'package:flutter/painting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 图片加载控制器封装
///
/// 这是 core_image 的底层封装，只提供图片加载的核心能力
/// 不包含任何 UI 组件
class ImageLoaderController {
  /// 预加载网络图片到缓存
  Future<void> precacheImage(String imageUrl) async {
    final imageProvider = CachedNetworkImageProvider(imageUrl);
    final completer = Completer<void>();

    // 预加载图片到缓存
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception, stackTrace);
          }
        },
      ),
    );

    return completer.future;
  }

  /// 清除指定图片的缓存
  Future<void> clearImageCache(String imageUrl) async {
    await CachedNetworkImage.evictFromCache(imageUrl);
  }

  /// 清除所有图片缓存
  Future<void> clearAllCache() async {
    // 使用静态实例方法
    final cacheManager = DefaultCacheManager();
    await cacheManager.emptyCache();
  }
}
