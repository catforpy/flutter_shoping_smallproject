library;

import 'package:flutter/material.dart';

/// 商品标签类型
///
/// 支持多种标签样式，每种类型有不同的背景和颜色
enum ProductTagType {
  /// 优惠标签（红色背景）
  discount,

  /// VIP标签（金色渐变背景）
  vip,

  /// 新品标签（蓝色背景）
  new_,

  /// 热销标签（橙色背景）
  hot,

  /// 限时标签（紫色背景）
  limited,

  /// 秒杀标签（渐变红背景）
  flashSale,
}

/// 商品标签组件
///
/// 通用的标签组件，支持多种类型和样式
///
/// ## 示例
/// ```dart
/// // 优惠标签
/// ProductTag(
///   type: ProductTagType.discount,
///   text: '上新优惠',
/// )
///
/// // VIP标签
/// ProductTag(
///   type: ProductTagType.vip,
///   text: 'VIP专享',
/// )
///
/// // 新品标签
/// ProductTag(
///   type: ProductTagType.new_,
///   text: '新品',
/// )
/// ```
class ProductTag extends StatelessWidget {
  /// 标签类型
  final ProductTagType type;

  /// 标签文字
  final String text;

  /// 标签内边距
  final EdgeInsetsGeometry? padding;

  /// 标签文字大小
  final double? fontSize;

  /// 标签圆角
  final double? borderRadius;

  /// 是否紧凑模式（更小的内边距和字体）
  final bool isCompact;

  const ProductTag({
    super.key,
    required this.type,
    required this.text,
    this.padding,
    this.fontSize,
    this.borderRadius,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTagConfig(type);

    return Container(
      padding: padding ?? (isCompact ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      decoration: BoxDecoration(
        gradient: config.gradient,
        color: config.gradient == null ? config.color : null,
        borderRadius: BorderRadius.circular(borderRadius ?? (isCompact ? 4 : 8)),
        boxShadow: config.hasShadow
            ? [
                BoxShadow(
                  color: (config.color ?? Colors.black).withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: config.textColor,
          fontSize: fontSize ?? (isCompact ? 10 : 12),
          fontWeight: config.fontWeight,
        ),
      ),
    );
  }

  /// 根据标签类型获取配置
  _ProductTagConfig _getTagConfig(ProductTagType type) {
    switch (type) {
      case ProductTagType.discount:
        return _ProductTagConfig(
          color: const Color(0xFFFF4757),
          textColor: Colors.white,
          fontWeight: FontWeight.w500,
          hasShadow: false,
        );

      case ProductTagType.vip:
        return _ProductTagConfig(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          textColor: Colors.white,
          fontWeight: FontWeight.bold,
          hasShadow: true,
        );

      case ProductTagType.new_:
        return _ProductTagConfig(
          color: const Color(0xFF3742FA),
          textColor: Colors.white,
          fontWeight: FontWeight.w500,
          hasShadow: false,
        );

      case ProductTagType.hot:
        return _ProductTagConfig(
          color: const Color(0xFFFF6348),
          textColor: Colors.white,
          fontWeight: FontWeight.w500,
          hasShadow: false,
        );

      case ProductTagType.limited:
        return _ProductTagConfig(
          color: const Color(0xFF9B59B6),
          textColor: Colors.white,
          fontWeight: FontWeight.w500,
          hasShadow: false,
        );

      case ProductTagType.flashSale:
        return _ProductTagConfig(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: Colors.white,
          fontWeight: FontWeight.bold,
          hasShadow: true,
        );
    }
  }
}

/// 标签配置类
class _ProductTagConfig {
  /// 纯色背景
  final Color? color;

  /// 渐变背景
  final Gradient? gradient;

  /// 文字颜色
  final Color textColor;

  /// 字重
  final FontWeight fontWeight;

  /// 是否有阴影
  final bool hasShadow;

  const _ProductTagConfig({
    this.color,
    this.gradient,
    required this.textColor,
    required this.fontWeight,
    required this.hasShadow,
  });
}
