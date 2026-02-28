library;

import 'package:flutter/material.dart';
import 'product_image.dart';
import 'product_image_badge.dart';
import 'product_tag.dart';

/// 商品卡片组件
///
/// 基础商品卡片，展示课程商品信息，包含图片、标题、价格、学习人数等
///
/// ## 功能特性
/// - 左侧商品图片，支持左上角标签和底部剩余时间显示
/// - 右侧商品信息，包含标题、副标题、价格行
/// - 价格行包含：优惠标签、现价、原价（划线）、学习人数
/// - 支持点击事件，带水波纹动画
///
/// ## 布局结构
/// ```
/// ┌────────────────────────────────────────┐
/// │ [图片]  标题                  学习人数 │
/// │          副标题                          │
/// │          [标签] 价格 (原价)            │
/// └────────────────────────────────────────┘
/// ```
///
/// ## 示例用法
/// ### 基础用法
/// ```dart
/// ProductCard(
///   imageUrl: 'https://example.com/product.jpg',
///   title: 'Flutter 完整开发指南',
///   subtitle: '从入门到精通',
///   price: 19900,  // 单位：分
///   originalPrice: 29900,
///   studyCount: 12345,
/// )
/// ```
///
/// ### 带图片标签和剩余时间
/// ```dart
/// ProductCard(
///   imageUrl: 'https://example.com/product.jpg',
///   title: 'Flutter 完整开发指南',
///   imageBadgeType: ProductImageBadgeType.new_,
///   imageBadgeText: '新课',
///   remainingText: '剩余：3天',
///   price: 19900,
/// )
/// ```
///
/// ### 带优惠标签
/// ```dart
/// ProductCard(
///   imageUrl: 'https://example.com/product.jpg',
///   title: 'Flutter 完整开发指南',
///   tag: ProductTag(
///     type: ProductTagType.discount,
///     text: '上新优惠',
///   ),
///   price: 19900,
/// )
/// ```
class ProductCard extends StatelessWidget {
  /// 商品图片URL
  final String imageUrl;

  /// 商品标题
  final String title;

  /// 商品副标题（描述）
  final String? subtitle;

  /// 优惠标签（显示在价格行）
  final Widget? tag;

  /// 现价（单位：分，会自动转换为元显示）
  final int price;

  /// 原价（单位：分，会自动转换为元显示，带划线）
  final int? originalPrice;

  /// 学习人数
  final int? studyCount;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  /// 卡片背景色
  final Color? backgroundColor;

  /// 卡片圆角
  final double? borderRadius;

  /// 卡片阴影
  final List<BoxShadow>? boxShadow;

  /// 图片宽度
  final double? imageWidth;

  /// 图片高度
  final double? imageHeight;

  /// 图片圆角
  final BorderRadius? imageBorderRadius;

  /// 是否显示边框
  final bool showBorder;

  /// 图片左上角标签类型
  final ProductImageBadgeType? imageBadgeType;

  /// 图片左上角标签文字
  final String? imageBadgeText;

  /// 图片底部剩余时间文字（如："剩余：2天"）
  final String? remainingText;

  /// 点击事件回调
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.tag,
    required this.price,
    this.originalPrice,
    this.studyCount,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.imageWidth = 80,
    this.imageHeight = 100,
    this.imageBorderRadius,
    this.showBorder = false,
    this.imageBadgeType,
    this.imageBadgeText,
    this.remainingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: _buildCardDecoration(),
        child: _buildCardRow(),
      ),
    );
  }

  /// 构建卡片装饰（背景、圆角、边框、阴影）
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      border: showBorder
          ? Border.all(color: Colors.grey.withValues(alpha: 0.2))
          : null,
      boxShadow: boxShadow ?? _defaultCardShadow,
    );
  }

  /// 默认卡片阴影
  List<BoxShadow> get _defaultCardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// 构建卡片行布局（图片 + 信息区域）
  Row _buildCardRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage().expanded(flex: 0),
        const SizedBox(width: 12),
        _buildProductInfo().expanded(),
      ],
    );
  }

  /// 构建商品图片
  Widget _buildImage() {
    return ProductImage(
      imageUrl: imageUrl,
      width: imageWidth,
      height: imageHeight,
      borderRadius: imageBorderRadius ?? BorderRadius.circular(8),
      // 左上角标签（新课、升级等）
      topLeftBadge: _buildImageBadge(),
      // 底部剩余时间（用于活动倒计时）
      remainingText: remainingText,
      remainingBackgroundColor: Colors.black.withValues(alpha: 0.5),
      remainingTextColor: Colors.white,
    );
  }

  /// 构建图片左上角标签（如果配置了）
  Widget? _buildImageBadge() {
    if (imageBadgeType == null || imageBadgeText == null) {
      return null;
    }

    return ProductImageBadge(
      type: imageBadgeType!,
      text: imageBadgeText!,
    );
  }

  /// 构建商品信息区域（标题、副标题、价格行）
  Widget _buildProductInfo() {
    return SizedBox(
      height: imageHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitle(),
          const SizedBox(height: 4),
          if (subtitle != null) _buildSubtitle(),
          const Spacer(),
          _buildPriceRow(),
        ],
      ),
    );
  }

  /// 构建商品标题
  Text _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建商品副标题
  Text _buildSubtitle() {
    return Text(
      subtitle!,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建价格行（标签 + 现价 + 原价 + 学习人数）
  Widget _buildPriceRow() {
    return Row(
      children: [
        // 优惠标签
        if (tag != null) ...[
          tag!,
          const SizedBox(width: 6),
        ],
        // 现价
        _buildCurrentPrice(),
        // 原价（如果有）
        if (_hasOriginalPrice) ...[
          const SizedBox(width: 4),
          _buildOriginalPrice().flexible(),
          const SizedBox(width: 8),
        ] else ...[
          const SizedBox(width: 6),
        ],
        // 弹性空间，将学习人数推到右侧
        const Spacer(),
        // 学习人数
        if (studyCount != null) _buildStudyCount(),
      ],
    );
  }

  /// 构建现价文本
  Text _buildCurrentPrice() {
    return Text(
      _formatPrice(price),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFF4757),
      ),
    );
  }

  /// 构建原价文本（带划线）
  Widget _buildOriginalPrice() {
    return Text(
      _formatPrice(originalPrice!),
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[400],
        decoration: TextDecoration.lineThrough,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 是否有原价
  bool get _hasOriginalPrice =>
      originalPrice != null && originalPrice! > price;

  /// 构建学习人数文本（固定宽度，右对齐）
  Widget _buildStudyCount() {
    return SizedBox(
      width: 80, // 固定宽度，确保所有卡片的学习人数对齐
      child: Text(
        _formatStudyCount(studyCount!),
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[500],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      ),
    );
  }

  /// 格式化价格（分 → 元）
  ///
  /// 例如：19900 → "199.00"
  String _formatPrice(int priceInCents) {
    return (priceInCents / 100).toStringAsFixed(2);
  }

  /// 格式化学习人数
  ///
  /// - 大于等于10000：显示 "X.X万人学习"
  /// - 大于等于1000：显示 "X.X千人学习"
  /// - 小于1000：显示 "XXX人学习"
  ///
  /// 例如：
  /// - 12345 → "1.2万人学习"
  /// - 5678 → "5.7千人学习"
  /// - 2345 → "2345人学习"
  String _formatStudyCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万人学习';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}千人学习';
    }
    return '$count人学习';
  }
}

/// Widget 扩展方法，支持链式调用
extension WidgetExtension on Widget {
  /// 将 widget 包装在 Expanded 中
  Widget expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  /// 将 widget 包装在 Flexible 中
  Widget flexible({FlexFit fit = FlexFit.loose, int flex = 1}) {
    return Flexible(
      fit: fit,
      flex: flex,
      child: this,
    );
  }
}
