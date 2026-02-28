library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 商品图片组件
///
/// 独立的商品图片组件，支持：
/// - 网络图片加载
/// - 圆角设置
/// - 左上角悬浮层（可选）
/// - 底部悬浮层（透明灰色，显示剩余时间）
/// - 点击水波纹动画
/// - 占位符和错误处理
///
/// ## 示例
/// ```dart
/// // 基础用法
/// ProductImage(
///   imageUrl: 'https://example.com/product.jpg',
///   width: 100,
///   height: 100,
///   borderRadius: BorderRadius.circular(8),
/// )
///
/// // 带左上角标签
/// ProductImage(
///   imageUrl: 'https://example.com/product.jpg',
///   topLeftBadge: Container(
///     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
///     decoration: BoxDecoration(
///       color: Colors.red,
///       borderRadius: BorderRadius.only(
///         topLeft: Radius.circular(8),
///         bottomRight: Radius.circular(8),
///       ),
///     ),
///     child: Text('VIP', style: TextStyle(color: Colors.white, fontSize: 10)),
///   ),
/// )
///
/// // 带底部剩余时间
/// ProductImage(
///   imageUrl: 'https://example.com/product.jpg',
///   remainingText: '剩余：2天',
///   remainingTextColor: Colors.white,
/// )
///
/// // 带点击事件
/// ProductImage(
///   imageUrl: 'https://example.com/product.jpg',
///   onTap: () {
///     print('图片被点击');
///   },
/// )
/// ```
class ProductImage extends StatelessWidget {
  /// 图片URL
  final String imageUrl;

  /// 图片宽度
  final double? width;

  /// 图片高度
  final double? height;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 适应方式
  final BoxFit fit;

  /// 占位符组件
  final Widget? placeholder;

  /// 错误组件
  final Widget? errorWidget;

  /// 是否显示加载指示器
  final bool showLoadingIndicator;

  /// 背景颜色
  final Color? backgroundColor;

  /// 边框
  final BoxBorder? border;

  /// 左上角悬浮层（可选）
  /// 例如：VIP标签、优惠标签等
  final Widget? topLeftBadge;

  /// 底部剩余时间文字（可选）
  /// 例如："剩余：2天"
  final String? remainingText;

  /// 底部悬浮层背景色（默认透明灰色）
  final Color? remainingBackgroundColor;

  /// 底部剩余时间文字颜色（默认白色）
  final Color? remainingTextColor;

  /// 底部剩余时间文字大小
  final double? remainingTextFontSize;

  /// 点击事件
  final VoidCallback? onTap;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.showLoadingIndicator = true,
    this.backgroundColor,
    this.border,
    this.topLeftBadge,
    this.remainingText,
    this.remainingBackgroundColor,
    this.remainingTextColor,
    this.remainingTextFontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageContent = _buildImageContent();

    // 如果有点击事件，包装在 InkWell 中
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: imageContent,
      );
    }

    return imageContent;
  }

  /// 构建图片内容
  Widget _buildImageContent() {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // 图片
          _buildCachedImage(),

          // 左上角悬浮层
          if (topLeftBadge != null) _buildTopLeftBadge(),

          // 底部悬浮层
          if (remainingText != null) _buildRemainingBadge(),
        ],
      ),
    );
  }

  /// 构建缓存图片
  Widget _buildCachedImage() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder != null
            ? null
            : (context, url) => _buildPlaceholder(),
        errorWidget: errorWidget != null
            ? null
            : (context, url, error) => _buildError(),
        imageBuilder: placeholder != null || errorWidget != null
            ? null
            : (context, imageProvider) => _buildImage(imageProvider),
      ),
    );
  }

  /// 构建图片
  Widget _buildImage(ImageProvider imageProvider) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
      ),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: showLoadingIndicator
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[400],
                ),
              )
            : Icon(Icons.image, size: 32, color: Colors.grey[300]),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 32, color: Colors.grey[400]),
            if (width != null && width! > 60) const SizedBox(height: 4),
            if (width != null && width! > 60)
              Text(
                '加载失败',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建左上角悬浮层
  Widget _buildTopLeftBadge() {
    return Positioned(
      top: 0,
      left: 0,
      child: topLeftBadge!,
    );
  }

  /// 构建底部剩余时间悬浮层
  Widget _buildRemainingBadge() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: remainingBackgroundColor ?? Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.only(
            bottomLeft: (borderRadius ?? BorderRadius.zero).bottomLeft,
            bottomRight: (borderRadius ?? BorderRadius.zero).bottomRight,
          ),
        ),
        child: Text(
          remainingText!,
          style: TextStyle(
            color: remainingTextColor ?? Colors.white,
            fontSize: remainingTextFontSize ?? 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
