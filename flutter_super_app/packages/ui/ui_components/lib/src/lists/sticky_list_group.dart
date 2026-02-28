library;

import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

// ========== 枚举定义 ==========

/// 标题对齐方式
enum StickyListTitleAlign {
  left,
  center,
  right,
}

// ========== 配置类 ==========

/// 吸顶标题配置
class StickyHeaderConfig {
  /// 标题内容（支持任意 Widget，为空则不显示标题）
  final Widget? title;

  /// 标题区域内边距
  final EdgeInsetsGeometry padding;

  /// 标题对齐方式
  final StickyListTitleAlign align;

  /// 标题背景颜色
  final Color? backgroundColor;

  /// 标题区域底部边框
  final Border? border;

  /// 标题区域圆角
  final BorderRadius? borderRadius;

  /// 标题高度（null 表示自适应）
  final double? height;

  /// 标题阴影
  final List<BoxShadow>? boxShadow;

  const StickyHeaderConfig({
    this.title,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.align = StickyListTitleAlign.left,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.boxShadow,
  });

  /// 链式调用：创建副本并修改部分属性
  StickyHeaderConfig copyWith({
    Widget? title,
    EdgeInsetsGeometry? padding,
    StickyListTitleAlign? align,
    Color? backgroundColor,
    Border? border,
    BorderRadius? borderRadius,
    double? height,
    List<BoxShadow>? boxShadow,
  }) {
    return StickyHeaderConfig(
      title: title ?? this.title,
      padding: padding ?? this.padding,
      align: align ?? this.align,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}

/// 分割线配置
class StickyListDividerConfig {
  /// 分割线 Widget（为 null 则使用默认分割线）
  final Widget? divider;

  /// 分割线颜色（当 divider 为 null 时使用）
  final Color? color;

  /// 分割线透明度（0.0 - 1.0）
  final double? opacity;

  /// 分割线高度（厚度）
  final double? height;

  /// 分割线左边距
  final double? indent;

  /// 分割线右边距
  final double? endIndent;

  /// 缩进区域背景色（用于 indent 区域的背景色，默认为白色）
  final Color? indentBackgroundColor;

  const StickyListDividerConfig({
    this.divider,
    this.color,
    this.opacity,
    this.height,
    this.indent,
    this.endIndent,
    this.indentBackgroundColor = Colors.white,
  });

  /// 链式调用：创建副本并修改部分属性
  StickyListDividerConfig copyWith({
    Widget? divider,
    Color? color,
    double? opacity,
    double? height,
    double? indent,
    double? endIndent,
    Color? indentBackgroundColor,
  }) {
    return StickyListDividerConfig(
      divider: divider ?? this.divider,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      height: height ?? this.height,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
      indentBackgroundColor: indentBackgroundColor ?? this.indentBackgroundColor,
    );
  }

  /// 获取有效的颜色（应用透明度）
  Color? get effectiveColor {
    if (color == null || opacity == null) return null;
    return color!.withValues(alpha: opacity!);
  }
}

/// 列表项配置
class StickyListItemConfig {
  /// 列表项内容（支持任意 Widget）
  final Widget child;

  /// 列表项高度（null 表示自适应）
  final double? height;

  const StickyListItemConfig({
    required this.child,
    this.height,
  });

  /// 链式调用：创建副本并修改部分属性
  StickyListItemConfig copyWith({
    Widget? child,
    double? height,
  }) {
    return StickyListItemConfig(
      child: child ?? this.child,
      height: height ?? this.height,
    );
  }

  /// 从 AppListTile 快速创建配置
  factory StickyListItemConfig.fromListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    AppListTileType type = AppListTileType.basic,
    Color? backgroundColor,
    bool hasDivider = true,
    Color? titleColor,
    Color? subtitleColor,
    TextStyle? titleStyle,
  }) {
    return StickyListItemConfig(
      child: AppListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        type: type,
        backgroundColor: backgroundColor,
        hasDivider: false, // 分割线由组件统一管理
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        titleStyle: titleStyle,
      ),
    );
  }
}

/// 吸顶分组配置
class StickyListGroupConfig {
  /// 吸顶标题配置
  final StickyHeaderConfig headerConfig;

  /// 列表项配置列表
  final List<StickyListItemConfig> items;

  /// 分割线配置
  final StickyListDividerConfig? dividerConfig;

  /// 组之间的间距（底部间距）
  final EdgeInsetsGeometry sectionSpacing;

  /// 是否显示分割线（null 表示自动判断）
  final bool? showDivider;

  const StickyListGroupConfig({
    required this.headerConfig,
    this.items = const [],
    StickyListDividerConfig? dividerConfig,
    this.sectionSpacing = EdgeInsets.zero,
    this.showDivider,
  }) : dividerConfig = dividerConfig;

  /// 链式调用：创建副本并修改部分属性
  StickyListGroupConfig copyWith({
    StickyHeaderConfig? headerConfig,
    List<StickyListItemConfig>? items,
    StickyListDividerConfig? dividerConfig,
    EdgeInsetsGeometry? sectionSpacing,
    bool? showDivider,
  }) {
    return StickyListGroupConfig(
      headerConfig: headerConfig ?? this.headerConfig,
      items: items ?? this.items,
      dividerConfig: dividerConfig ?? this.dividerConfig,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      showDivider: showDivider ?? this.showDivider,
    );
  }

  /// 函数式：添加单个 item
  StickyListGroupConfig addItem(StickyListItemConfig item) {
    return StickyListGroupConfig(
      headerConfig: headerConfig,
      items: [...items, item],
      dividerConfig: dividerConfig,
      sectionSpacing: sectionSpacing,
      showDivider: showDivider,
    );
  }

  /// 函数式：添加多个 items
  StickyListGroupConfig addItems(List<StickyListItemConfig> newItems) {
    return StickyListGroupConfig(
      headerConfig: headerConfig,
      items: [...items, ...newItems],
      dividerConfig: dividerConfig,
      sectionSpacing: sectionSpacing,
      showDivider: showDivider,
    );
  }
}

// ========== 主组件 ==========

/// 吸顶分组列表组件（Sliver）
///
/// ## 设计理念
/// - **支持吸顶效果**：标题滚动到顶部时会固定
/// - **高度灵活**：标题和列表项均支持任意 Widget
/// - **函数式风格**：配置类不可变，通过 copyWith 实现链式调用
/// - **统一分割线**：分割线样式统一管理，可自定义
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// CustomScrollView(
///   slivers: [
///     StickyListGroup(
///       config: StickyListGroupConfig(
///         headerConfig: StickyHeaderConfig(
///           title: Text('第1章 标题'),
///           backgroundColor: Colors.white,
///         ),
///         items: [
///           StickyListItemConfig(
///             child: AppListTile(title: '课时1'),
///           ),
///           StickyListItemConfig(
///             child: AppListTile(title: '课时2'),
///           ),
///         ],
///       ),
///     ),
///   ],
/// )
///
/// // 使用便捷构造函数
/// StickyListGroup(
///   config: StickyListGroupConfig(
///     headerConfig: StickyHeaderConfig(
///       title: Text('第1章 标题'),
///       backgroundColor: Colors.white,
///     ),
///   ).addItem(
///     StickyListItemConfig.fromListTile(title: '课时1'),
///   ).addItem(
///     StickyListItemConfig.fromListTile(title: '课时2'),
///   ),
/// )
///
/// // 自定义列表项
/// StickyListGroup(
///   config: StickyListGroupConfig(
///     headerConfig: StickyHeaderConfig(
///       title: Row(...), // 复杂标题
///     ),
///     items: [
///       StickyListItemConfig(
///         child: Container(...), // 任意 Widget
///       ),
///     ],
///   ),
/// )
/// ```
class StickyListGroup extends StatelessWidget {
  /// 分组配置
  final StickyListGroupConfig config;

  const StickyListGroup({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        // 吸顶标题
        if (config.headerConfig.title != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              config: config.headerConfig,
            ),
          ),
        // 列表内容
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final itemConfig = config.items[index];
              return _buildListItem(itemConfig, index);
            },
            childCount: config.items.length,
          ),
        ),
        // 组间距
        if (config.sectionSpacing != EdgeInsets.zero)
          SliverToBoxAdapter(
            child: Padding(
              padding: config.sectionSpacing,
            ),
          ),
      ],
    );
  }

  /// 构建列表项
  Widget _buildListItem(StickyListItemConfig itemConfig, int index) {
    // print('_buildListItem: index=$index, total=${config.items.length}');
    // print('_buildListItem: itemConfig.child 类型=${itemConfig.child.runtimeType}');
    Widget child = itemConfig.child;

    // 固定高度
    if (itemConfig.height != null) {
      // print('_buildListItem: 设置固定高度 ${itemConfig.height}');
      child = SizedBox(
        height: itemConfig.height,
        child: child,
      );
    }

    // 添加分割线（最后一项不添加）
    if (index < config.items.length - 1) {
      // print('_buildListItem: 不是最后一项，调用 _buildDivider()');
      final divider = _buildDivider();
      // print('_buildListItem: divider 类型=${divider.runtimeType}');
      // 如果分割线不是空组件，才添加到 Column 中
      if (divider != const SizedBox.shrink()) {
        // print('_buildListItem: 创建 Column，添加分割线');
        child = Column(
          children: [
            child,
            divider,
          ],
        );
      } else {
        // print('_buildListItem: divider 是 SizedBox.shrink()，不创建 Column');
      }
    } else {
      // print('_buildListItem: 是最后一项，不添加分割线');
    }

    // print('_buildListItem: 最终返回的 child 类型=${child.runtimeType}');
    return child;
  }

  /// 构建分割线
  Widget _buildDivider() {
    // print('_buildDivider: 开始构建分割线');

    // 如果没有配置分割线，返回空组件
    if (config.dividerConfig == null) {
      // print('_buildDivider: dividerConfig == null，返回空组件');
      return const SizedBox.shrink();
    }

    // print('_buildDivider: dividerConfig 不为 null');

    // 如果有自定义分割线 widget，使用自定义的
    if (config.dividerConfig!.divider != null) {
      // print('_buildDivider: 使用自定义 divider widget');
      return config.dividerConfig!.divider!;
    }

    // print('_buildDivider: 没有自定义 divider widget，使用配置参数');

    // 使用配置参数构建分割线
    final dividerConfig = config.dividerConfig!;
    // print('_buildDivider: color=${dividerConfig.color}, opacity=${dividerConfig.opacity}, height=${dividerConfig.height}, indent=${dividerConfig.indent}');

    // 如果缺少必要配置，返回空组件
    if (dividerConfig.color == null ||
        dividerConfig.opacity == null ||
        dividerConfig.height == null) {
      // print('_buildDivider: 缺少必要配置，返回空组件');
      return const SizedBox.shrink();
    }

    // print('_buildDivider: 配置完整，构建分割线 - effectiveColor=${dividerConfig.effectiveColor}');
    return Container(
      color: dividerConfig.indentBackgroundColor, // 缩进区域背景色（从外部传入）
      child: Row(
        children: [
          SizedBox(width: dividerConfig.indent ?? 0),
          Expanded(
            child: Container(
              height: dividerConfig.height!,
              color: dividerConfig.effectiveColor,
            ),
          ),
          SizedBox(width: dividerConfig.endIndent ?? 0),
        ],
      ),
    );
  }
}

// ========== 内部组件 ==========

/// 吸顶标题代理
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final StickyHeaderConfig config;

  _StickyHeaderDelegate({required this.config});

  @override
  double get minExtent => config.height ?? _calculateHeight();

  @override
  double get maxExtent => config.height ?? _calculateHeight();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Widget titleWidget = config.title ?? const SizedBox.shrink();

    // 根据对齐方式包装
    switch (config.align) {
      case StickyListTitleAlign.left:
        titleWidget = Align(
          alignment: Alignment.centerLeft,
          child: titleWidget,
        );
        break;
      case StickyListTitleAlign.center:
        titleWidget = Center(child: titleWidget);
        break;
      case StickyListTitleAlign.right:
        titleWidget = Align(
          alignment: Alignment.centerRight,
          child: titleWidget,
        );
        break;
    }

    return Container(
      padding: config.padding,
      height: config.height,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: config.border,
        borderRadius: config.borderRadius,
        boxShadow: config.boxShadow,
      ),
      child: titleWidget,
    );
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return config != oldDelegate.config;
  }

  /// 计算标题高度（padding + 估算的内容高度）
  double _calculateHeight() {
    // 如果没有明确指定高度，使用默认值
    // 实际项目中可以通过 LayoutBuilder 测量，但这里简化为固定值
    return 48.0;
  }
}

// ========== 便捷构造组件 ==========

/// 吸顶分组列表视图（包含多个分组）
///
/// 用于一次性渲染多个 StickyListGroup
class StickyListView extends StatelessWidget {
  /// 分组配置列表
  final List<StickyListGroupConfig> sections;

  /// 整体内边距
  final EdgeInsetsGeometry padding;

  /// 背景颜色
  final Color? backgroundColor;

  const StickyListView({
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
      child: CustomScrollView(
        slivers: sections
            .map((config) => StickyListGroup(config: config))
            .toList(),
      ),
    );
  }
}
