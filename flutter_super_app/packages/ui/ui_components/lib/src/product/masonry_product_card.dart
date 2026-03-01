library;

import 'package:flutter/material.dart';

/// 错落商品卡片数据模型
///
/// 用于 MasonryProductCard 组件的数据结构
class MasonryProductCardData {
  // === 基础信息 ===
  final String title;
  final String? subtitle;
  final ImageProvider image;
  final double price;
  final double? originalPrice;

  // === 可选模块 ===
  final Widget? topBanner;
  final String? cornerBadge;
  final Color? cornerBadgeColor;
  final List<MasonryProductCardTag>? tags;
  final List<MasonryProductCardTag>? services;
  final Widget? actionButton;
  final Widget? floatingBadge;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  // === 样式控制 ===
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? priceStyle;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool showShadow;

  const MasonryProductCardData({
    required this.title,
    required this.image,
    required this.price,
    this.subtitle,
    this.originalPrice,
    this.topBanner,
    this.cornerBadge,
    this.cornerBadgeColor,
    this.tags,
    this.services,
    this.actionButton,
    this.floatingBadge,
    this.onTap,
    this.onActionTap,
    this.titleStyle,
    this.subtitleStyle,
    this.priceStyle,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
    this.showShadow = true,
  });
}

/// 错落商品卡片标签
class MasonryProductCardTag {
  final String text;
  final Color? bgColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final IconData? icon;

  const MasonryProductCardTag({
    required this.text,
    this.bgColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.icon,
  });
}

/// 错落商品卡片组件（专为瀑布流设计）
///
/// ## 核心特性
/// - 高度自适应：卡片高度由内容决定
/// - 模块化组装：每个区域都是可选/可替换的
/// - 数据驱动：所有显示内容通过 Model 传入
/// - 视觉统一：字体、间距、颜色、圆角保持一致
/// - 性能友好：避免过度嵌套
///
/// ## 卡片结构
/// ```
/// [顶部横幅区]       ← 可选
/// [主图区]           ← 必填：商品图片 + 可选角标
/// [标题区]           ← 必填：商品名称 + 可选副标题
/// [标签区]           ← 可选：多个小标签
/// [价格区]           ← 必填：补贴到手价 + 可选原价
/// [服务承诺区]       ← 可选：如"买贵双倍赔"、"包邮"
/// [行动按钮区]       ← 可选：如"+"加入购物车
/// [右下角浮标区]     ← 可选：如"补×百亿补贴"
/// ```
///
/// ## 示例用法
/// ### 基础用法
/// ```dart
/// MasonryProductCard(
///   data: MasonryProductCardData(
///     title: "苹果 iPhone 15 Pro",
///     image: NetworkImage("https://example.com/iphone.jpg"),
///     price: 8999,
///     originalPrice: 9999,
///     cornerBadge: "自营",
///   ),
/// )
/// ```
///
/// ### 完整配置
/// ```dart
/// MasonryProductCard(
///   data: MasonryProductCardData(
///     title: "苹果 iPhone 15 Pro 256GB",
///     subtitle: "银色",
///     image: NetworkImage("https://example.com/iphone.jpg"),
///     price: 8999,
///     originalPrice: 9999,
///     topBanner: _buildBanner(),
///     cornerBadge: "自营",
///     cornerBadgeColor: Colors.red,
///     tags: [
///       MasonryProductCardTag(
///         text: "7天无理由退货",
///         bgColor: Colors.green.shade50,
///         textColor: Colors.green.shade700,
///         borderColor: Colors.green.shade200,
///       ),
///     ],
///     services: [
///       MasonryProductCardTag(
///         text: "买贵双倍赔",
///         bgColor: Colors.orange.shade50,
///         textColor: Colors.orange.shade700,
///       ),
///     ],
///     actionButton: Icon(Icons.add_circle, color: Colors.red),
///     onTap: () => print("点击卡片"),
///   ),
/// )
/// ```
class MasonryProductCard extends StatelessWidget {
  final MasonryProductCardData data;

  const MasonryProductCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: data.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(data.borderRadius!),
          boxShadow: data.showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 顶部横幅（可选）
            if (data.topBanner != null) data.topBanner!,

            // 2. 主图区（含角标、浮标）
            _buildImageArea(),

            // 3. 内容区（带 padding）
            Padding(
              padding: data.padding!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  _buildTitle(),

                  // 副标题
                  if (data.subtitle != null) ...[
                    const SizedBox(height: 4),
                    _buildSubtitle(),
                  ],

                  // 标签区
                  if (data.tags != null && data.tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTags(),
                  ],

                  // 价格区
                  const SizedBox(height: 8),
                  _buildPriceArea(),

                  // 服务承诺区
                  if (data.services != null && data.services!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildServices(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主图区（含角标、浮标）
  Widget _buildImageArea() {
    return Stack(
      children: [
        // 主图
        AspectRatio(
          aspectRatio: 1,
          child: Image(
            image: data.image,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey),
                ),
              );
            },
          ),
        ),

        // 左下角角标
        if (data.cornerBadge != null)
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: data.cornerBadgeColor ?? Colors.red,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                data.cornerBadge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // 右下角浮标
        if (data.floatingBadge != null)
          Positioned(
            right: -8,
            bottom: -8,
            child: data.floatingBadge!,
          ),
      ],
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Text(
      data.title,
      style: data.titleStyle ??
          const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.3,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建副标题
  Widget _buildSubtitle() {
    return Text(
      data.subtitle!,
      style: data.subtitleStyle ??
          TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建标签区
  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: data.tags!.map((tag) => _buildTag(tag)).toList(),
    );
  }

  /// 构建单个标签
  Widget _buildTag(MasonryProductCardTag tag) {
    return Container(
      padding: tag.padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tag.bgColor ?? Colors.grey[200],
        borderRadius: tag.borderRadius ?? BorderRadius.circular(4),
        border: tag.borderColor != null
            ? Border.all(color: tag.borderColor!)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.icon != null) ...[
            Icon(tag.icon, size: tag.fontSize ?? 10, color: tag.textColor),
            const SizedBox(width: 2),
          ],
          Text(
            tag.text,
            style: TextStyle(
              fontSize: tag.fontSize ?? 10,
              color: tag.textColor ?? Colors.black87,
              fontWeight: tag.fontWeight ?? FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建价格区
  Widget _buildPriceArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // 现价
        Text(
          '¥${data.price.toStringAsFixed(0)}',
          style: data.priceStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                height: 1.0,
              ),
        ),

        // 原价
        if (data.originalPrice != null) ...[
          const SizedBox(width: 6),
          Text(
            '¥${data.originalPrice!.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.grey[600],
            ),
          ),
        ],

        const Spacer(),

        // 行动按钮
        if (data.actionButton != null)
          GestureDetector(
            onTap: data.onActionTap,
            child: data.actionButton!,
          )
        else
          _defaultActionButton(),
      ],
    );
  }

  /// 构建服务承诺区
  Widget _buildServices() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: data.services!.map((service) => _buildServiceTag(service)).toList(),
    );
  }

  /// 构建单个服务标签
  Widget _buildServiceTag(MasonryProductCardTag service) {
    return Container(
      padding:
          service.padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: service.bgColor ?? Colors.orange.shade50,
        borderRadius: service.borderRadius ?? BorderRadius.circular(4),
      ),
      child: Text(
        service.text,
        style: TextStyle(
          fontSize: service.fontSize ?? 10,
          color: service.textColor ?? Colors.orange.shade700,
        ),
      ),
    );
  }

  /// 默认行动按钮
  Widget _defaultActionButton() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, size: 16, color: Colors.red),
    );
  }
}
