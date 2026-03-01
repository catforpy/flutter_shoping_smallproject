library;

import 'package:flutter/material.dart';

/// 通用电商商品卡片组件 - 左图右文布局
///
/// ## 功能特性
/// - 支持顶部标签区（多个标签横向排列）
/// - 支持主图 + 角标（左下角）
/// - 支持标题（多行截断）
/// - 支持价格信息区（主价格、原价、促销标签、服务标签）
/// - 支持评价/销量信息
/// - 支持行动按钮（下单、加入购物车等）
/// - 高度可配置，支持自定义样式和回调
///
/// ## 示例用法
/// ### 基础用法
/// ```dart
/// UniversalProductCard(
///   image: NetworkImage('https://example.com/product.jpg'),
///   title: 'Apple iPhone 15 Pro Max 256GB',
///   price: 9999.00,
///   originalPrice: 10999.00,
/// )
/// ```
///
/// ### 完整配置
/// ```dart
/// UniversalProductCard(
///   image: NetworkImage('https://example.com/product.jpg'),
///   title: 'Apple iPhone 15 Pro Max 256GB',
///   price: 9999.00,
///   originalPrice: 10999.00,
///   cornerBadgeText: '京喜自营 包邮',
///   topTags: [
///     ProductCardTag(text: '自营', bgColor: Colors.red, textColor: Colors.white),
///     ProductCardTag(text: '包邮', bgColor: Colors.orange, textColor: Colors.white),
///   ],
///   promoTags: [
///     ProductCardTag(text: '30天最低价', bgColor: Colors.red[50]!, textColor: Colors.red),
///   ],
///   serviceTags: [
///     ProductCardTag(text: '先用后付', bgColor: Colors.green[50]!, textColor: Colors.green),
///   ],
///   reviewCount: '500+条评论',
///   salesCount: '已售10万+',
///   actionButtonText: '下单',
///   onActionTap: () => print('下单'),
///   onTap: () => print('跳转详情'),
/// )
/// ```
class UniversalProductCard extends StatelessWidget {
  /// 主图
  final ImageProvider image;

  /// 商品标题
  final String title;

  /// 主价格（必填）
  final double price;

  /// 原价/划线价（可选）
  final double? originalPrice;

  /// 货币符号（默认"¥"）
  final String currencySymbol;

  // ============ 顶部标签区 ============

  /// 顶部标签列表（如"自营"、"包邮"等）
  final List<Widget>? topTags;

  // ============ 主图区 ============

  /// 主图左下角角标文字（如"京喜自营 包邮"）
  final String? cornerBadgeText;

  /// 角标背景色（默认红色）
  final Color? cornerBadgeBgColor;

  /// 角标文字颜色（默认白色）
  final Color? cornerBadgeTextColor;

  /// 主图左上角徽章（如"新品"）
  final Widget? topLeftBadge;

  /// 主图右上角徽章（如"视频"、"直播"）
  final Widget? topRightBadge;

  // ============ 标题区 ============

  /// 标题最大行数（默认2行）
  final int maxTitleLines;

  /// 标题样式
  final TextStyle? titleStyle;

  // ============ 价格信息区 ============

  /// 主价格样式
  final TextStyle? priceStyle;

  /// 原价样式
  final TextStyle? originalPriceStyle;

  /// 促销标签列表（如"30天最低价"、"焕新补贴"等）
  final List<Widget>? promoTags;

  /// 新人专享价格
  final double? newUserPrice;

  /// 新人价标签文字（如"新人价"）
  final String? newUserLabel;

  /// 新人价指示器（如箭头+气泡）
  final Widget? specialPriceIndicator;

  /// 服务标签列表（如"先用后付"、"包邮"等）
  final List<Widget>? serviceTags;

  // ============ 评价/销量区 ============

  /// 评价数量（如"500+条评论"）
  final String? reviewCount;

  /// 销量（如"已售10万+"）
  final String? salesCount;

  /// 评价/销量文字样式
  final TextStyle? statsStyle;

  // ============ 行动按钮区 ============

  /// 行动按钮文字（如"下单"）
  final String? actionButtonText;

  /// 行动按钮背景色
  final Color? actionButtonColor;

  /// 行动按钮文字颜色
  final Color? actionButtonTextColor;

  /// 行动按钮点击回调
  final VoidCallback? onActionTap;

  /// 自定义行动按钮（完全自定义）
  final Widget? customActionButton;

  // ============ 其他配置 ============

  /// 整个卡片点击回调
  final VoidCallback? onTap;

  /// 卡片背景色
  final Color? backgroundColor;

  /// 卡片圆角
  final BorderRadius? borderRadius;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  /// 卡片外边距
  final EdgeInsetsGeometry? margin;

  /// 是否显示阴影
  final bool showShadow;

  /// 主图宽度比例（默认2，右侧内容3）
  final int imageFlex;

  /// 内容宽度比例（默认3，左侧主图2）
  final int contentFlex;

  /// 主图高度（默认null，自适应）
  final double? imageHeight;

  const UniversalProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    this.originalPrice,
    this.currencySymbol = '¥',
    this.topTags,
    this.cornerBadgeText,
    this.cornerBadgeBgColor,
    this.cornerBadgeTextColor,
    this.topLeftBadge,
    this.topRightBadge,
    this.maxTitleLines = 2,
    this.titleStyle,
    this.priceStyle,
    this.originalPriceStyle,
    this.promoTags,
    this.newUserPrice,
    this.newUserLabel,
    this.specialPriceIndicator,
    this.serviceTags,
    this.reviewCount,
    this.salesCount,
    this.statsStyle,
    this.actionButtonText,
    this.actionButtonColor,
    this.actionButtonTextColor,
    this.onActionTap,
    this.customActionButton,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showShadow = true,
    this.imageFlex = 2,
    this.contentFlex = 3,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = BorderRadius.circular(8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: borderRadius ?? defaultBorderRadius,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧：主图区
              Expanded(
                flex: imageFlex,
                child: _buildImageSection(),
              ),

              const SizedBox(width: 12),

              // 右侧：内容区
              Expanded(
                flex: contentFlex,
                child: _buildContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建主图区
  Widget _buildImageSection() {
    return SizedBox(
      height: imageHeight,
      child: Stack(
        children: [
          // 主图
          Image(
            image: image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              );
            },
          ),

          // 左上角徽章
          if (topLeftBadge != null)
            Positioned(
              top: 0,
              left: 0,
              child: topLeftBadge!,
            ),

          // 右上角徽章
          if (topRightBadge != null)
            Positioned(
              top: 0,
              right: 0,
              child: topRightBadge!,
            ),

          // 左下角角标
          if (cornerBadgeText != null)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: cornerBadgeBgColor ?? Colors.red,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  cornerBadgeText!,
                  style: TextStyle(
                    color: cornerBadgeTextColor ?? Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建内容区
  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 顶部标签区
        if (topTags != null && topTags!.isNotEmpty)
          _buildTopTags(),

        // 标题区
        _buildTitle(),

        const SizedBox(height: 8),

        // 价格信息区
        _buildPriceSection(),

        // 促销标签区
        if (promoTags != null && promoTags!.isNotEmpty)
          _buildPromoTags(),

        // 服务标签区
        if (serviceTags != null && serviceTags!.isNotEmpty)
          _buildServiceTags(),

        const SizedBox(height: 8),

        // 评价/销量区
        if (reviewCount != null || salesCount != null)
          _buildStatsSection(),

        // 行动按钮区
        if (customActionButton != null ||
            (actionButtonText != null && actionButtonText!.isNotEmpty))
          _buildActionButton(),
      ],
    );
  }

  /// 构建顶部标签区
  Widget _buildTopTags() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: topTags!,
      ),
    );
  }

  /// 构建标题区
  Widget _buildTitle() {
    return Text(
      title,
      maxLines: maxTitleLines,
      overflow: TextOverflow.ellipsis,
      style: titleStyle ??
          const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            height: 1.3,
          ),
    );
  }

  /// 构建价格信息区
  Widget _buildPriceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 主价格
        Text(
          '$currencySymbol${price.toStringAsFixed(2)}',
          style: priceStyle ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                height: 1.0,
              ),
        ),

        const SizedBox(width: 8),

        // 原价
        if (originalPrice != null)
          Text(
            '$currencySymbol${originalPrice!.toStringAsFixed(2)}',
            style: originalPriceStyle ??
                TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Colors.grey[600],
                ),
          ),

        // 新人价
        if (newUserPrice != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.orange, width: 1),
            ),
            child: Text(
              '$currencySymbol${newUserPrice!.toStringAsFixed(2)} ${newUserLabel ?? '新人价'}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 构建促销标签区
  Widget _buildPromoTags() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: promoTags!,
      ),
    );
  }

  /// 构建服务标签区
  Widget _buildServiceTags() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: serviceTags!,
      ),
    );
  }

  /// 构建评价/销量区
  Widget _buildStatsSection() {
    return Text(
      '${reviewCount ?? ''}${reviewCount != null && salesCount != null ? ' | ' : ''}${salesCount ?? ''}',
      style: statsStyle ??
          TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
    );
  }

  /// 构建行动按钮区
  Widget _buildActionButton() {
    if (customActionButton != null) {
      return customActionButton!;
    }

    return GestureDetector(
      onTap: onActionTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: actionButtonColor ?? Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          actionButtonText!,
          style: TextStyle(
            color: actionButtonTextColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// 简单标签组件（用于顶部标签、促销标签、服务标签）
class ProductCardTag extends StatelessWidget {
  final String text;
  final Color? bgColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const ProductCardTag({
    super.key,
    required this.text,
    this.bgColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize ?? 12, color: textColor ?? Colors.black87),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              color: textColor ?? Colors.black87,
              fontWeight: fontWeight ?? FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
