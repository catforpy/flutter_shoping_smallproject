library;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

// ========== 枚举定义 ==========

/// 标题对齐方式
///
/// 用于控制分组标题的对齐方式：
/// - [left] 左对齐（右侧预留 padding）
/// - [center] 居中对齐
/// - [right] 右对齐（左侧预留 padding）
enum GroupedListTitleAlign {
  left,
  center,
  right,
}

// ========== 配置类（函数式风格，支持链式调用）==========

/// 分割线配置
///
/// 采用不可变设计，所有字段 final，通过 copyWith 实现链式调用
class GroupedListDividerConfig {
  /// 分割线颜色
  final Color color;

  /// 分割线透明度（0.0 - 1.0）
  final double opacity;

  /// 分割线高度（厚度）
  final double height;

  /// 分割线左边距（null 表示延伸到左边缘）
  final double? indent;

  /// 分割线右边距（null 表示延伸到右边缘）
  final double? endIndent;

  const GroupedListDividerConfig({
    this.color = Colors.grey,
    this.opacity = 0.3,
    this.height = 1.0,
    this.indent,
    this.endIndent,
  });

  /// 链式调用：创建副本并修改部分属性
  ///
  /// 函数式编程的核心思想：数据不可变，每次修改返回新对象
  GroupedListDividerConfig copyWith({
    Color? color,
    double? opacity,
    double? height,
    double? indent,
    double? endIndent,
  }) {
    return GroupedListDividerConfig(
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      height: height ?? this.height,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }

  /// 获取有效的颜色（应用透明度）
  Color get effectiveColor => color.withValues(alpha: opacity);
}

/// 标题配置
///
/// 采用不可变设计，所有字段 final，通过 copyWith 实现链式调用
class GroupedListTitleConfig {
  /// 标题文字内容（空字符串表示不显示标题，仅保留 padding）
  final String title;

  /// 标题文字样式
  final TextStyle? textStyle;

  /// 标题区域内边距
  final EdgeInsetsGeometry padding;

  /// 标题对齐方式
  final GroupedListTitleAlign align;

  /// 标题背景颜色（null 表示透明）
  final Color? backgroundColor;

  /// 标题区域底部边框
  final Border? border;

  /// 标题区域圆角
  final BorderRadius? borderRadius;

  /// 标题高度（null 表示自适应）
  final double? height;

  const GroupedListTitleConfig({
    this.title = '',
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.align = GroupedListTitleAlign.left,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
  });

  /// 链式调用：创建副本并修改部分属性
  GroupedListTitleConfig copyWith({
    String? title,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    GroupedListTitleAlign? align,
    Color? backgroundColor,
    Border? border,
    BorderRadius? borderRadius,
    double? height,
  }) {
    return GroupedListTitleConfig(
      title: title ?? this.title,
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      align: align ?? this.align,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
    );
  }
}

/// Tile 配置
///
/// 每个 AppListTile 的配置，支持高度自定义
class GroupedListItemConfig {
  /// Tile 标题
  final String title;

  /// Tile 副标题
  final String? subtitle;

  /// Tile 前缀图标
  final Widget? leading;

  /// Tile 后缀组件
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// Tile 类型
  final AppListTileType type;

  /// Tile 背景颜色
  final Color? backgroundColor;

  /// Tile 是否禁用
  final bool enabled;

  /// 自定义 Tile（设置后将忽略其他参数）
  final Widget? customTile;

  const GroupedListItemConfig({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.type = AppListTileType.navigation,
    this.backgroundColor,
    this.enabled = true,
    this.customTile,
  });

  /// 链式调用：创建副本并修改部分属性
  GroupedListItemConfig copyWith({
    String? title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    AppListTileType? type,
    Color? backgroundColor,
    bool? enabled,
    Widget? customTile,
  }) {
    return GroupedListItemConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      onTap: onTap ?? this.onTap,
      type: type ?? this.type,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      enabled: enabled ?? this.enabled,
      customTile: customTile ?? this.customTile,
    );
  }
}

/// 分组配置（组合标题、分割线、Tile）
///
/// 采用不可变设计，通过 copyWith 实现链式调用
class GroupedListSectionConfig {
  /// 标题配置
  final GroupedListTitleConfig titleConfig;

  /// 分割线配置
  final GroupedListDividerConfig dividerConfig;

  /// 组之间的间距（底部间距）
  final EdgeInsetsGeometry sectionSpacing;

  /// Tile 列表
  final List<GroupedListItemConfig> items;

  /// 是否显示圆角卡片效果
  final bool showCardEffect;

  /// 卡片背景颜色
  final Color? cardBackgroundColor;

  /// 卡片圆角
  final BorderRadius? cardBorderRadius;

  /// 卡片内边距
  final EdgeInsetsGeometry cardPadding;

  /// 卡片外边距
  final EdgeInsetsGeometry cardMargin;

  const GroupedListSectionConfig({
    GroupedListTitleConfig? titleConfig,
    GroupedListDividerConfig? dividerConfig,
    this.sectionSpacing = const EdgeInsets.only(bottom: 24),
    this.items = const [],
    this.showCardEffect = false,
    this.cardBackgroundColor,
    this.cardBorderRadius,
    this.cardPadding = EdgeInsets.zero,
    this.cardMargin = EdgeInsets.zero,
  })  : titleConfig = titleConfig ?? const GroupedListTitleConfig(),
        dividerConfig = dividerConfig ?? const GroupedListDividerConfig();

  /// 链式调用：创建副本并修改部分属性
  GroupedListSectionConfig copyWith({
    GroupedListTitleConfig? titleConfig,
    GroupedListDividerConfig? dividerConfig,
    EdgeInsetsGeometry? sectionSpacing,
    List<GroupedListItemConfig>? items,
    bool? showCardEffect,
    Color? cardBackgroundColor,
    BorderRadius? cardBorderRadius,
    EdgeInsetsGeometry? cardPadding,
    EdgeInsetsGeometry? cardMargin,
  }) {
    return GroupedListSectionConfig(
      titleConfig: titleConfig ?? this.titleConfig,
      dividerConfig: dividerConfig ?? this.dividerConfig,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      items: items ?? this.items,
      showCardEffect: showCardEffect ?? this.showCardEffect,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardPadding: cardPadding ?? this.cardPadding,
      cardMargin: cardMargin ?? this.cardMargin,
    );
  }

  /// 函数式：添加单个 item
  GroupedListSectionConfig addItem(GroupedListItemConfig item) {
    return GroupedListSectionConfig(
      titleConfig: titleConfig,
      dividerConfig: dividerConfig,
      sectionSpacing: sectionSpacing,
      items: [...items, item],
      showCardEffect: showCardEffect,
      cardBackgroundColor: cardBackgroundColor,
      cardBorderRadius: cardBorderRadius,
      cardPadding: cardPadding,
      cardMargin: cardMargin,
    );
  }

  /// 函数式：添加多个 items
  GroupedListSectionConfig addItems(List<GroupedListItemConfig> newItems) {
    return GroupedListSectionConfig(
      titleConfig: titleConfig,
      dividerConfig: dividerConfig,
      sectionSpacing: sectionSpacing,
      items: [...items, ...newItems],
      showCardEffect: showCardEffect,
      cardBackgroundColor: cardBackgroundColor,
      cardBorderRadius: cardBorderRadius,
      cardPadding: cardPadding,
      cardMargin: cardMargin,
    );
  }

  /// 函数式：更新标题
  GroupedListSectionConfig withTitle(GroupedListTitleConfig newTitleConfig) {
    return GroupedListSectionConfig(
      titleConfig: newTitleConfig,
      dividerConfig: dividerConfig,
      sectionSpacing: sectionSpacing,
      items: items,
      showCardEffect: showCardEffect,
      cardBackgroundColor: cardBackgroundColor,
      cardBorderRadius: cardBorderRadius,
      cardPadding: cardPadding,
      cardMargin: cardMargin,
    );
  }

  /// 函数式：更新分割线
  GroupedListSectionConfig withDivider(GroupedListDividerConfig newDividerConfig) {
    return GroupedListSectionConfig(
      titleConfig: titleConfig,
      dividerConfig: newDividerConfig,
      sectionSpacing: sectionSpacing,
      items: items,
      showCardEffect: showCardEffect,
      cardBackgroundColor: cardBackgroundColor,
      cardBorderRadius: cardBorderRadius,
      cardPadding: cardPadding,
      cardMargin: cardMargin,
    );
  }

  /// 函数式：启用卡片效果
  GroupedListSectionConfig withCardEffect({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return GroupedListSectionConfig(
      titleConfig: titleConfig,
      dividerConfig: dividerConfig,
      sectionSpacing: sectionSpacing,
      items: items,
      showCardEffect: true,
      cardBackgroundColor: backgroundColor ?? cardBackgroundColor,
      cardBorderRadius: borderRadius ?? cardBorderRadius,
      cardPadding: padding ?? cardPadding,
      cardMargin: margin ?? cardMargin,
    );
  }
}

// ========== 主组件 ==========

/// 分组列表组件
///
/// ## 设计理念
/// - **函数式风格**：配置类不可变，通过 copyWith 和函数式方法实现链式调用
/// - **高度灵活**：所有样式均可外部配置，避免硬编码
/// - **组合式设计**：基于 AppListTile 组合而成，而非重写
/// - **可扩展性**：支持自定义 Tile，支持卡片效果
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// GroupedListSection(
///   config: GroupedListSectionConfig()
///       .withTitle(GroupedListTitleConfig(title: '我的企业'))
///       .addItem(GroupedListItemConfig(title: '联系人A'))
///       .addItem(GroupedListItemConfig(title: '联系人B')),
/// )
///
/// // 函数式链式调用
/// GroupedListSection(
///   config: GroupedListSectionConfig()
///       .withTitle(
///         GroupedListTitleConfig(
///           title: '我的企业',
///           backgroundColor: Colors.grey[100],
///         ),
///       )
///       .withDivider(
///         GroupedListDividerConfig(
///           color: Colors.blue,
///           opacity: 0.5,
///         ),
///       )
///       .addItem(GroupedListItemConfig(title: '联系人A'))
///       .addItem(GroupedListItemConfig(title: '联系人B'))
///       .withCardEffect(
///         backgroundColor: Colors.white,
///         borderRadius: BorderRadius.circular(12),
///       ),
/// )
///
/// // 多个分组
/// Column(
///   children: [
///     GroupedListSection(config: section1),
///     GroupedListSection(config: section2),
///   ],
/// )
/// ```
class GroupedListSection extends StatelessWidget {
  /// 分组配置（函数式风格，支持链式调用）
  final GroupedListSectionConfig config;

  const GroupedListSection({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // 如果没有 items，返回空组件
    if (config.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // 构建整个分组区域
    final sectionContent = _buildSectionContent();

    // 应用卡片效果
    if (config.showCardEffect) {
      return _buildCard(sectionContent);
    }

    // 应用组间距
    return Padding(
      padding: config.sectionSpacing,
      child: sectionContent,
    );
  }

  /// 构建分组内容（标题 + Tile 列表）
  Widget _buildSectionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题区域
        if (config.titleConfig.title.isNotEmpty || _hasTitlePadding())
          _buildTitle(),
        // Tile 列表
        _buildTilesList(),
      ],
    );
  }

  /// 判断是否有标题 padding
  bool _hasTitlePadding() {
    final padding = config.titleConfig.padding as EdgeInsets;
    return padding.top > 0 || padding.bottom > 0;
  }

  /// 构建标题区域
  Widget _buildTitle() {
    final titleConfig = config.titleConfig;

    // 标题文字组件
    Widget titleWidget = Text(
      titleConfig.title,
      style: titleConfig.textStyle,
    );

    // 根据对齐方式包装
    switch (titleConfig.align) {
      case GroupedListTitleAlign.left:
        titleWidget = Align(
          alignment: Alignment.centerLeft,
          child: titleWidget,
        );
        break;
      case GroupedListTitleAlign.center:
        titleWidget = Center(child: titleWidget);
        break;
      case GroupedListTitleAlign.right:
        titleWidget = Align(
          alignment: Alignment.centerRight,
          child: titleWidget,
        );
        break;
    }

    // 构建 Container
    return Container(
      padding: titleConfig.padding,
      height: titleConfig.height,
      decoration: BoxDecoration(
        color: titleConfig.backgroundColor,
        border: titleConfig.border,
        borderRadius: titleConfig.borderRadius,
      ),
      child: titleWidget,
    );
  }

  /// 构建 Tile 列表
  Widget _buildTilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: _buildTilesWithDividers(),
    );
  }

  /// 构建 Tile + 分割线的列表（函数式方式生成）
  List<Widget> _buildTilesWithDividers() {
    final tiles = <Widget>[];

    for (int i = 0; i < config.items.length; i++) {
      final itemConfig = config.items[i];

      // 添加 Tile
      tiles.add(_buildSingleTile(itemConfig));

      // 添加分割线（最后一个 Tile 不添加）
      if (i < config.items.length - 1) {
        tiles.add(_buildDivider());
      }
    }

    return tiles;
  }

  /// 构建单个 Tile
  Widget _buildSingleTile(GroupedListItemConfig itemConfig) {
    // 如果有自定义 Tile，使用自定义
    if (itemConfig.customTile != null) {
      return itemConfig.customTile!;
    }

    // 否则使用 AppListTile
    return AppListTile(
      title: itemConfig.title,
      subtitle: itemConfig.subtitle,
      leading: itemConfig.leading,
      trailing: itemConfig.trailing,
      onTap: itemConfig.onTap,
      type: itemConfig.type,
      backgroundColor: itemConfig.backgroundColor,
      enabled: itemConfig.enabled,
      // 分割线由组件统一管理，这里禁用 Tile 自带的分割线
      hasDivider: false,
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    final dividerConfig = config.dividerConfig;

    return Container(
      height: dividerConfig.height,
      margin: EdgeInsets.only(
        left: dividerConfig.indent ?? 0,
        right: dividerConfig.endIndent ?? 0,
      ),
      color: dividerConfig.effectiveColor,
    );
  }

  /// 构建卡片效果
  Widget _buildCard(Widget content) {
    return Container(
      margin: config.cardMargin,
      padding: config.cardPadding,
      decoration: BoxDecoration(
        color: config.cardBackgroundColor,
        borderRadius: config.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: config.sectionSpacing,
        child: content,
      ),
    );
  }
}

// ========== 便捷构造函数 ==========

/// 分组列表视图（包含多个分组）
///
/// 用于一次性渲染多个 GroupedListSection
class GroupedListView extends StatelessWidget {
  /// 分组配置列表
  final List<GroupedListSectionConfig> sections;

  /// 整体内边距
  final EdgeInsetsGeometry padding;

  /// 背景颜色
  final Color? backgroundColor;

  const GroupedListView({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: sections
            .map((config) => GroupedListSection(config: config))
            .toList(),
      ),
    );
  }
}
