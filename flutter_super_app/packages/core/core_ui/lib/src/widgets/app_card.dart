library;

import 'package:flutter/material.dart';

// ========== 枚举定义 ==========

/// 卡片样式枚举
///
/// 定义了3种常用的卡片样式：
/// - elevated: 凸起卡片（带阴影）
/// - outlined: 描边卡片（带边框）
/// - filled: 填充卡片（纯色背景）
enum AppCardStyle {
  elevated,  // 凸起卡片（带阴影）
  outlined,  // 描边卡片（带边框）
  filled,    // 填充卡片（纯色背景）
}

// ========== 主组件 ==========

/// 通用卡片组件
///
/// ## 设计理念
/// - 提供合理的默认值，开箱即用
/// - 完全可配置的样式（不硬编码颜色）
/// - 支持点击和长按交互
///
/// ## 使用示例
/// ```dart
/// // 凸起卡片（默认）
/// AppCard(
///   child: Text('Card Content'),
/// )
///
/// // 描边卡片
/// AppCard(
///   style: AppCardStyle.outlined,
///   child: Text('Outlined Card'),
/// )
///
/// // 可点击卡片
/// AppCard(
///   onTap: () => print('Card tapped'),
///   child: Text('Clickable Card'),
/// )
///
/// // 自定义样式
/// AppCard(
///   color: Colors.blue.shade50,
///   borderRadius: 16,
///   elevation: 4,
///   child: Text('Custom Card'),
/// )
/// ```
class AppCard extends StatelessWidget {
  // ========== 基础属性 ==========

  /// 卡片内容子组件
  final Widget child;

  /// 卡片样式（默认凸起卡片）
  final AppCardStyle style;

  // ========== 交互属性 ==========

  /// 点击回调事件
  final VoidCallback? onTap;

  /// 长按回调事件
  final VoidCallback? onLongPress;

  // ========== 样式配置属性 ==========

  /// 内边距（null则使用默认值 16px）
  final EdgeInsetsGeometry? padding;

  /// 外边距（null则使用 0）
  final EdgeInsetsGeometry? margin;

  /// 阴影高度（null则根据样式使用默认值）
  final double? elevation;

  /// 背景色（null则使用主题色）
  final Color? color;

  /// 圆角半径（null则使用 12px）
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,                    // 必填：子组件
    this.style = AppCardStyle.elevated,     // 默认：凸起卡片
    this.onTap,                             // 可选：点击回调
    this.onLongPress,                       // 可选：长按回调
    this.padding,                           // 可选：内边距
    this.margin,                            // 可选：外边距
    this.elevation,                         // 可选：阴影高度
    this.color,                             // 可选：背景色
    this.borderRadius,                      // 可选：圆角半径
  });

  @override
  Widget build(BuildContext context) {
    // 构建带内边距的内容
    final content = _buildPaddedContent();

    // 构建卡片容器
    return _buildCardContainer(context, content);
  }

  // ========== 内容构建函数 ==========

  /// 构建带内边距的内容
  Widget _buildPaddedContent() {
    // 获取有效的内边距
    final effectivePadding = _getEffectivePadding();

    // 为内容添加内边距
    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }

  // ========== 容器构建函数 ==========

  /// 构建卡片容器（处理外边距、手势、卡片样式）
  Widget _buildCardContainer(BuildContext context, Widget content) {
    // 获取有效的外边距
    final effectiveMargin = _getEffectiveMargin();

    // 添加手势交互（有点击或长按回调时）
    final wrappedContent = _wrapWithGesture(content);

    // 构建最终卡片
    return _buildFinalCard(context, wrappedContent, effectiveMargin);
  }

  /// 包装手势交互
  Widget _wrapWithGesture(Widget content) {
    // 判断是否需要添加手势
    if (!_hasGesture()) {
      return content;
    }

    // 获取有效的圆角半径
    final effectiveBorderRadius = _getEffectiveBorderRadius();

    // 添加 InkWell 水波纹效果
    return InkWell(
      onTap: onTap,                          // 点击回调
      onLongPress: onLongPress,              // 长按回调
      borderRadius: BorderRadius.circular(effectiveBorderRadius),  // 圆角
      child: content,
    );
  }

  /// 构建最终卡片（添加外边距和卡片样式）
  Widget _buildFinalCard(BuildContext context, Widget content, EdgeInsetsGeometry margin) {
    // 为卡片添加外边距
    return Container(
      margin: margin,
      child: _buildCardByStyle(context, content),
    );
  }

  /// 根据样式构建卡片
  Widget _buildCardByStyle(BuildContext context, Widget child) {
    // 获取有效的圆角半径
    final effectiveBorderRadius = _getEffectiveBorderRadius();

    // 使用 switch 表达式根据样式选择对应的卡片
    return switch (style) {
      // 凸起卡片：带阴影的 Card
      AppCardStyle.elevated => _buildElevatedCard(child, effectiveBorderRadius),

      // 描边卡片：带边框的 Card
      AppCardStyle.outlined => _buildOutlinedCard(context, child, effectiveBorderRadius),

      // 填充卡片：纯色背景的 Container
      AppCardStyle.filled => _buildFilledCard(child, effectiveBorderRadius),
    };
  }

  /// 构建凸起卡片（带阴影）
  Widget _buildElevatedCard(Widget child, double borderRadius) {
    return Card(
      elevation: _getEffectiveElevation(),   // 阴影高度
      color: color,                          // 背景色
      shape: RoundedRectangleBorder(          // 圆角形状
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }

  /// 构建描边卡片（带边框）
  Widget _buildOutlinedCard(BuildContext context, Widget child, double borderRadius) {
    return Card(
      elevation: 0,                          // 无阴影
      color: color,                          // 背景色
      shape: RoundedRectangleBorder(          // 圆角形状
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(                    // 边框样式
          color: _getDividerColor(context),  // 边框颜色
          width: 1,                          // 边框宽度
        ),
      ),
      child: child,
    );
  }

  /// 构建填充卡片（纯色背景）
  Widget _buildFilledCard(Widget child, double borderRadius) {
    return Container(
      decoration: BoxDecoration(
        color: color,                        // 背景色
        borderRadius: BorderRadius.circular(borderRadius),  // 圆角
      ),
      child: child,
    );
  }

  // ========== 状态判断函数 ==========

  /// 判断是否有手势交互
  bool _hasGesture() {
    return onTap != null || onLongPress != null;
  }

  // ========== 样式获取函数 ==========

  /// 获取有效的内边距（自定义或默认值 16px）
  EdgeInsetsGeometry _getEffectivePadding() {
    return padding ?? const EdgeInsets.all(16);
  }

  /// 获取有效的外边距（自定义或 0）
  EdgeInsetsGeometry _getEffectiveMargin() {
    return margin ?? EdgeInsets.zero;
  }

  /// 获取有效的圆角半径（自定义或默认值 12px）
  double _getEffectiveBorderRadius() {
    return borderRadius ?? 12.0;
  }

  /// 获取有效的阴影高度（自定义或根据样式的默认值）
  double _getEffectiveElevation() {
    return elevation ?? 2.0;
  }

  /// 获取边框颜色（用于 outlined 样式）
  Color _getDividerColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }
}

// ========== 列表卡片项组件 ==========

/// 列表卡片项组件
///
/// ## 设计理念
/// - 提供合理的默认值，开箱即用
/// - 完全可配置的布局和样式
/// - 预留扩展插槽，支持自定义内容
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// AppCardListTile(
///   leading: Icon(Icons.person),
///   title: Text('John Doe'),
///   subtitle: Text('Software Engineer'),
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => print('Tapped'),
/// )
///
/// // 自定义样式
/// AppCardListTile(
///   spacing: 16,
///   contentPadding: EdgeInsets.all(20),
///   crossAxisAlignment: CrossAxisAlignment.start,
///   title: Text('Custom Tile'),
/// )
///
/// // 完全自定义内容
/// AppCardListTile(
///   customContent: Row(
///     children: [
///       Icon(Icons.star),
///       SizedBox(width: 8),
///       Text('Custom Content'),
///     ],
///   ),
/// )
/// ```
class AppCardListTile extends StatelessWidget {
  // ========== 内容属性 ==========

  /// 前缀组件（显示在左侧）
  final Widget? leading;

  /// 标题组件
  final Widget? title;

  /// 副标题组件
  final Widget? subtitle;

  /// 后缀组件（显示在右侧）
  final Widget? trailing;

  // ========== 交互属性 ==========

  /// 点击回调事件
  final VoidCallback? onTap;

  /// 长按回调事件
  final VoidCallback? onLongPress;

  /// 是否为三行文本（true 时高度增加）
  final bool isThreeLine;

  // ========== 样式配置属性 ==========

  /// 内容内边距
  final EdgeInsetsGeometry? contentPadding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 子元素间距
  final double? spacing;

  /// 交叉轴对齐方式
  final CrossAxisAlignment? crossAxisAlignment;

  // ========== 扩展插槽属性 ==========

  /// 完全自定义内容（设置后忽略 leading、title、subtitle、trailing）
  final Widget? customContent;

  const AppCardListTile({
    super.key,
    this.leading,                           // 可选：前缀组件
    this.title,                             // 可选：标题
    this.subtitle,                          // 可选：副标题
    this.trailing,                          // 可选：后缀组件
    this.onTap,                             // 可选：点击回调
    this.onLongPress,                       // 可选：长按回调
    this.isThreeLine = false,               // 默认：非三行文本
    // 样式配置
    this.contentPadding,                    // 可选：内容内边距
    this.margin,                            // 可选：外边距
    this.spacing,                           // 可选：子元素间距
    this.crossAxisAlignment,                // 可选：交叉轴对齐
    // 扩展插槽
    this.customContent,                     // 可选：自定义内容
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.outlined,          // 使用描边样式
      padding: _getEffectiveContentPadding(),
      margin: _getEffectiveMargin(),
      onTap: onTap,
      onLongPress: onLongPress,
      child: _buildTileContent(context),
    );
  }

  // ========== 内容构建函数 ==========

  /// 构建列表项内容
  Widget _buildTileContent(BuildContext context) {
    // 如果有自定义内容，使用自定义内容
    if (customContent != null) {
      return customContent!;
    }

    // 否则使用默认的行布局
    return _buildDefaultRow(context);
  }

  /// 构建默认行布局
  Widget _buildDefaultRow(BuildContext context) {
    return Row(
      crossAxisAlignment: _getEffectiveCrossAxisAlignment(),
      children: _buildRowChildren(context),
    );
  }

  /// 构建行子元素列表
  List<Widget> _buildRowChildren(BuildContext context) {
    final children = <Widget>[];

    // 添加前缀组件
    if (leading != null) {
      children.addAll([
        leading!,
        SizedBox(width: _getEffectiveSpacing()),
      ]);
    }

    // 添加扩展的标题区域
    children.add(_buildExpandedTitleArea(context));

    // 添加后缀组件
    if (trailing != null) {
      children.addAll([
        SizedBox(width: _getEffectiveSpacing()),
        trailing!,
      ]);
    }

    return children;
  }

  /// 构建扩展的标题区域
  Widget _buildExpandedTitleArea(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: _buildTitleColumnChildren(context),
      ),
    );
  }

  /// 构建标题列的子元素
  List<Widget> _buildTitleColumnChildren(BuildContext context) {
    final children = <Widget>[];

    // 添加标题
    if (title != null) {
      children.add(_buildTitleWidget(context));
    }

    // 添加副标题
    if (subtitle != null) {
      children.addAll([
        const SizedBox(height: 4),
        _buildSubtitleWidget(context),
      ]);
    }

    return children;
  }

  /// 构建标题组件（带默认文本样式）
  Widget _buildTitleWidget(BuildContext context) {
    return DefaultTextStyle(
      style: _getTitleStyle(context),
      child: title!,
    );
  }

  /// 构建副标题组件（带默认文本样式）
  Widget _buildSubtitleWidget(BuildContext context) {
    return DefaultTextStyle(
      style: _getSubtitleStyle(context),
      child: subtitle!,
    );
  }

  // ========== 样式获取函数 ==========

  /// 获取标题文本样式
  TextStyle _getTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium ?? const TextStyle();
  }

  /// 获取副标题文本样式
  TextStyle _getSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).disabledColor,
    ) ?? const TextStyle();
  }

  /// 获取有效的内容内边距（自定义或默认值）
  EdgeInsetsGeometry _getEffectiveContentPadding() {
    return contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  /// 获取有效的外边距（自定义或默认值）
  EdgeInsetsGeometry _getEffectiveMargin() {
    return margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4);
  }

  /// 获取有效的子元素间距（自定义或默认值 12px）
  double _getEffectiveSpacing() {
    return spacing ?? 12.0;
  }

  /// 获取有效的交叉轴对齐方式（自定义或默认值 center）
  CrossAxisAlignment _getEffectiveCrossAxisAlignment() {
    return crossAxisAlignment ?? CrossAxisAlignment.center;
  }
}
