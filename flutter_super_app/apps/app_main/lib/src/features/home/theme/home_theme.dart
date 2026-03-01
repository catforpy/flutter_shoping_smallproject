library;

import 'package:flutter/material.dart';

/// 首页主题配置
///
/// 集中管理首页的样式常量，避免硬编码
class HomeTheme {
  // ==================== 颜色配置 ====================

  /// 背景色
  static const Color backgroundColor = Colors.white;

  /// 浅灰色背景（用于分隔）
  static const Color lightGreyBackground = Color(0xFFFAFAFA);

  /// 主色调（红色）
  static const Color primaryColor = Colors.red;

  /// 次要文字颜色
  static const Color secondaryTextColor = Colors.grey;

  /// 主文字颜色
  static const Color primaryTextColor = Colors.black87;

  // ==================== 搜索框配置 ====================

  /// 搜索框背景色
  static const Color searchBackgroundColor = Colors.white;

  /// 搜索框边框色
  static const Color searchBorderColor = Color(0xFFE0E0E0);

  /// 搜索框圆角
  static const double searchBorderRadius = 20;

  /// 搜索框内边距
  static const EdgeInsets searchPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  /// 搜索框图标颜色
  static const Color searchIconColor = Colors.grey;

  // ==================== 按钮配置 ====================

  /// 搜索按钮背景色
  static const Color searchButtonColor = Colors.red;

  /// 搜索按钮文字颜色
  static const Color searchButtonTextColor = Colors.white;

  /// 搜索按钮圆角
  static const double buttonBorderRadius = 20;

  /// 搜索按钮内边距
  static const EdgeInsets buttonPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  // ==================== 标签栏配置 ====================

  /// 横向标签栏高度
  static const double horizontalTabsHeight = 40;

  /// 横向标签栏间距
  static const double horizontalTabsSpacing = 12;

  /// 横向标签栏内边距
  static const EdgeInsets horizontalTabsPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  /// 横向标签栏圆角
  static const double horizontalTabsBorderRadius = 20;

  /// 标签选中文字颜色
  static const Color tabSelectedColor = Colors.black;

  /// 标签未选中文字颜色
  static const Color tabUnselectedColor = Colors.grey;

  /// 标签选中背景色
  static const Color tabSelectedBackgroundColor = Color(0xFFE0E0E0);

  // ==================== 分类网格配置 ====================

  /// 网格顶部内边距
  static const double gridTopPadding = 0.0;

  /// 网格底部内边距
  static const double gridBottomPadding = 8.0;

  /// 网格间距
  static const double gridSpacing = 8.0;

  /// 网格行间距
  static const double gridRunSpacing = 16.0;

  /// 网格列数
  static const int gridCrossAxisCount = 5;

  /// 第一页行数
  static const int gridFirstPageRows = 1;

  /// 第二页行数
  static const int gridSecondPageRows = 3;

  /// 分类图标大小
  static const double categoryIconSize = 28.0;

  /// 分类文字大小
  static const double categoryFontSize = 12.0;

  /// 分类图标与文字间距
  static const double categoryIconTextSpacing = 6.0;

  // ==================== 商品列表配置 ====================

  /// 商品列表垂直内边距
  static const double productListVerticalPadding = 8.0;

  /// 商品卡片间距
  static const double productCardSpacing = 8.0;

  /// 商品卡片图片高度
  static const double productImageHeight = 100.0;

  /// 商品卡片主价格颜色
  static const Color productPriceColor = Colors.red;

  /// 商品卡片原价颜色
  static const Color productOriginalPriceColor = Colors.grey;

  /// 商品行动按钮颜色
  static const Color productActionButtonColor = Colors.red;

  // ==================== 间距配置 ====================

  /// 超小间距
  static const double spacing4 = 4.0;

  /// 小间距
  static const double spacing8 = 8.0;

  /// 中间距
  static const double spacing12 = 12.0;

  /// 大间距
  static const double spacing16 = 16.0;

  /// 超大间距
  static const double spacing24 = 24.0;
}
