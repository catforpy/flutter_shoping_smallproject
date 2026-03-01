library;

import '../models/product.dart';

/// Product 扩展方法
///
/// 提供价格转换、数据格式化等常用功能
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
