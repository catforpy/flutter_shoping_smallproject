import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片加载器 UI 组件
///
/// 这是 core_ui 包的组件，提供带 UI 的图片加载器
/// 底层由 cached_network_image 提供支持
///
/// 设计理念：
/// - 提供合理的默认值
/// - 完全可配置的样式
/// - 预留扩展插槽
class AppImageLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  // ========== 可配置样式 ==========
  final Color? placeholderBackgroundColor;
  final Color? errorBackgroundColor;
  final BorderRadius? borderRadius;

  // ========== 扩展插槽 ==========
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget Function(BuildContext, String, Object?)? errorBuilder;
  final Widget Function(BuildContext, String)? placeholderBuilder;

  const AppImageLoader({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    // 可配置样式
    this.placeholderBackgroundColor,
    this.errorBackgroundColor,
    this.borderRadius,
    // 扩展插槽
    this.placeholder,
    this.errorWidget,
    this.errorBuilder,
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 如果提供了自定义 placeholder 构建器，使用它
      placeholder: placeholderBuilder != null
          ? (context, url) => placeholderBuilder!(context, url)
          : placeholder != null
              ? (context, url) => placeholder!
              : (context, url) => _DefaultPlaceholder(
                    width: width,
                    height: height,
                    backgroundColor: placeholderBackgroundColor,
                  ),
      // 如果提供了自定义 error 构建器，使用它
      errorWidget: errorBuilder != null
          ? (context, url, error) => errorBuilder!(context, url, error)
          : errorWidget != null
              ? (context, url, error) => errorWidget!
              : (context, url, error) => _DefaultErrorWidget(
                    width: width,
                    height: height,
                    backgroundColor: errorBackgroundColor,
                  ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

/// 默认占位组件
class _DefaultPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const _DefaultPlaceholder({
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// 默认错误组件
class _DefaultErrorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const _DefaultErrorWidget({
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[100],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text('图片加载失败', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

/// 圆形图片加载器
///
/// 提供圆形头像的便捷组件
class AppCircleImage extends StatelessWidget {
  final String? imageUrl;
  final double size;

  // ========== 可配置样式 ==========
  final Color? backgroundColor;
  final Widget? placeholder;

  // ========== 扩展插槽 ==========
  final Widget? errorWidget;
  final Widget Function(BuildContext)? customBuilder;

  const AppCircleImage({
    super.key,
    this.imageUrl,
    required this.size,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 如果提供了自定义构建器，使用它
    if (customBuilder != null) {
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: customBuilder!(context),
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null
            ? AppImageLoader(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: placeholder,
                errorWidget: errorWidget,
              )
            : Container(
                width: size,
                height: size,
                color: backgroundColor ?? Colors.grey[300],
                child: Center(
                  child: Icon(Icons.person, size: size * 0.5),
                ),
              ),
      ),
    );
  }
}
