library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../models/product.dart';

/// Product 扩展方法
///
/// 提供价格转换、数据格式化、卡片数据生成等常用功能
extension ProductExtension on Product {
  /// 价格转换：分 -> 元
  ///
  /// 示例：
  /// ```dart
  /// final product = Product(price: 9999); // 99.99元
  /// print(product.priceInYuan); // 输出: 99.99
  /// ```
  double get priceInYuan => price / 100;

  /// 原价转换：分 -> 元
  ///
  /// 如果原价为 null，则返回 null
  ///
  /// 示例：
  /// ```dart
  /// final product = Product(originalPrice: 12999); // 129.99元
  /// print(product.originalPriceInYuan); // 输出: 129.99
  /// ```
  double? get originalPriceInYuan => originalPrice?.let((it) => it / 100);

  /// 格式化评价数
  ///
  /// 格式规则：
  /// - <= 0：返回 null
  /// - >= 1000：显示 "X.Xk+条评论"
  /// - < 1000：显示 "X+条评论"
  ///
  /// 示例：
  /// ```dart
  /// Product(commentCount: 5000).formattedReviewCount  // "5.0k+条评论"
  /// Product(commentCount: 500).formattedReviewCount   // "500+条评论"
  /// Product(commentCount: 0).formattedReviewCount     // null
  /// ```
  String? get formattedReviewCount {
    if (commentCount <= 0) return null;
    if (commentCount >= 1000) {
      return '${(commentCount / 1000).toStringAsFixed(1)}k+条评论';
    }
    return '$commentCount+条评论';
  }

  /// 格式化销量
  ///
  /// 格式规则：
  /// - <= 0：返回 null
  /// - >= 10000：显示 "已售X.X万+"
  /// - < 10000：显示 "已售X+"
  ///
  /// 示例：
  /// ```dart
  /// Product(soldCount: 50000).formattedSalesCount  // "已售5.0万+"
  /// Product(soldCount: 5000).formattedSalesCount   // "已售5000+"
  /// Product(soldCount: 0).formattedSalesCount      // null
  /// ```
  String? get formattedSalesCount {
    if (soldCount <= 0) return null;
    if (soldCount >= 10000) {
      return '已售${(soldCount / 10000).toStringAsFixed(1)}万+';
    }
    return '已售$soldCount+';
  }

  /// 检查是否有评价
  bool get hasReviews => commentCount > 0;

  /// 检查是否有销量
  bool get hasSales => soldCount > 0;

  /// 检查是否有原价
  bool get hasOriginalPrice => originalPrice != null && originalPrice! > 0;

  /// 转换为错落商品卡片数据（用于瀑布流）
  ///
  /// 将 Product 模型转换为 MasonryProductCardData，
  /// 自动填充基础信息，可选区域可根据需要自定义。
  ///
  /// 示例：
  /// ```dart
  /// final cardData = product.toMasonryCardData(
  ///   cornerBadge: '自营',
  ///   tags: ['7天无理由退货'],
  /// );
  /// ```
  MasonryProductCardData toMasonryCardData({
    /// 顶部横幅
    Widget? topBanner,

    /// 左下角角标（默认根据 sellerName 判断）
    String? cornerBadge,

    /// 角标颜色
    Color? cornerBadgeColor,

    /// 标签列表
    List<MasonryProductCardTag>? tags,

    /// 服务承诺列表
    List<MasonryProductCardTag>? services,

    /// 行动按钮
    Widget? actionButton,

    /// 右下角浮标
    Widget? floatingBadge,

    /// 点击回调
    VoidCallback? onTap,

    /// 行动按钮点击回调
    VoidCallback? onActionTap,

    /// 自定义标题样式
    TextStyle? titleStyle,

    /// 自定义副标题样式
    TextStyle? subtitleStyle,

    /// 自定义价格样式
    TextStyle? priceStyle,

    /// 卡片圆角
    double? borderRadius,

    /// 卡片内边距
    EdgeInsetsGeometry? padding,

    /// 背景色
    Color? backgroundColor,

    /// 是否显示阴影
    bool showShadow = true,
  }) {
    return MasonryProductCardData(
      // 基础信息
      title: name,
      subtitle: _getSubtitleFromSpecs(),
      image: coverImage != null
          ? NetworkImage(coverImage!)
          : const AssetImage('assets/images/placeholder.png'),
      price: priceInYuan,
      originalPrice: originalPriceInYuan,

      // 可选模块
      topBanner: topBanner,
      cornerBadge: cornerBadge ?? (sellerName?.contains('自营') == true ? '自营' : null),
      cornerBadgeColor: cornerBadgeColor,
      tags: tags,
      services: services,
      actionButton: actionButton,
      floatingBadge: floatingBadge,
      onTap: onTap,
      onActionTap: onActionTap,

      // 样式控制
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      priceStyle: priceStyle,
      borderRadius: borderRadius,
      padding: padding,
      backgroundColor: backgroundColor,
      showShadow: showShadow,
    );
  }

  /// 从规格信息中提取副标题（如颜色、尺寸）
  String? _getSubtitleFromSpecs() {
    if (specifications == null || specifications!.isEmpty) return null;

    // 取第一个规格的第一个值作为副标题
    final firstSpec = specifications!.entries.first;
    if (firstSpec.value.isNotEmpty) {
      return firstSpec.value.first;
    }

    return null;
  }
}

/// Dart 的 let 方法（类似 Kotlin 的 let）
///
/// 用于对可能为 null 的值进行操作
extension LetExtension<T> on T? {
  R let<R>(R Function(T value) operation) {
    if (this == null) {
      throw ArgumentError('Cannot call let on null value');
    }
    return operation(this as T);
  }
}
