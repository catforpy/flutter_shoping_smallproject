library;

import 'package:flutter/material.dart';

/// 商品图片标签类型
///
/// 用于图片左上角的标签，标识商品状态
enum ProductImageBadgeType {
  /// 新课（绿色）
  new_,

  /// 升级（蓝色）
  upgrade,

  /// 热门（橙色）
  hot,

  /// 限时（紫色）
  limited,

  /// 推荐（红色）
  recommend,

  /// 完成（灰色）
  completed,
}

/// 商品图片标签组件
///
/// 用于 ProductImage 的左上角标签
/// 小巧的标签，适合放在图片角落
///
/// ## 示例
/// ```dart
/// ProductImageBadge(
///   type: ProductImageBadgeType.new_,
///   text: '新课',
/// )
///
/// ProductImageBadge(
///   type: ProductImageBadgeType.upgrade,
///   text: '升级',
/// )
/// ```
class ProductImageBadge extends StatelessWidget {
  /// 标签类型
  final ProductImageBadgeType type;

  /// 标签文字
  final String text;

  /// 是否紧凑模式（更小的内边距）
  final bool isCompact;

  const ProductImageBadge({
    super.key,
    required this.type,
    required this.text,
    this.isCompact = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig(type);

    return Container(
      padding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: config.gradient,
        color: config.gradient == null ? config.color : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: (config.color ?? Colors.black).withValues(alpha: 0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: config.textColor,
          fontSize: isCompact ? 9 : 10,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }

  /// 根据标签类型获取配置
  _ProductImageBadgeConfig _getBadgeConfig(ProductImageBadgeType type) {
    switch (type) {
      case ProductImageBadgeType.new_:
        return _ProductImageBadgeConfig(
          color: const Color(0xFF00C853),
          textColor: Colors.white,
        );

      case ProductImageBadgeType.upgrade:
        return _ProductImageBadgeConfig(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          textColor: Colors.white,
        );

      case ProductImageBadgeType.hot:
        return _ProductImageBadgeConfig(
          color: const Color(0xFFFF9800),
          textColor: Colors.white,
        );

      case ProductImageBadgeType.limited:
        return _ProductImageBadgeConfig(
          color: const Color(0xFF9C27B0),
          textColor: Colors.white,
        );

      case ProductImageBadgeType.recommend:
        return _ProductImageBadgeConfig(
          color: const Color(0xFFFF5252),
          textColor: Colors.white,
        );

      case ProductImageBadgeType.completed:
        return _ProductImageBadgeConfig(
          color: const Color(0xFF9E9E9E),
          textColor: Colors.white,
        );
    }
  }
}

/// 标签配置类
class _ProductImageBadgeConfig {
  /// 纯色背景
  final Color? color;

  /// 渐变背景
  final Gradient? gradient;

  /// 文字颜色
  final Color textColor;

  const _ProductImageBadgeConfig({
    this.color,
    this.gradient,
    required this.textColor,
  });
}
