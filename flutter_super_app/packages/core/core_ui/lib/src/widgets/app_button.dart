library;

import 'package:flutter/material.dart';

// ========== 枚举定义 ==========

/// 按钮类型枚举
///
/// 定义了5种常用的按钮样式：
/// - primary: 主要按钮（蓝色背景，白色文字）
/// - secondary: 次要按钮（灰色背景，蓝色文字）
/// - outline: 描边按钮（透明背景，蓝色边框）
/// - text: 文本按钮（透明背景，蓝色文字）
/// - danger: 危险按钮（红色背景，白色文字）
enum AppButtonType {
  primary,    // 主要按钮
  secondary,  // 次要按钮
  outline,    // 描边按钮
  text,       // 文本按钮
  danger,     // 危险按钮
}

/// 按钮尺寸枚举
///
/// 定义了3种按钮尺寸：
/// - small: 小号（高度32px，适合紧凑布局）
/// - medium: 中号（高度44px，默认尺寸）
/// - large: 大号（高度52px，适合强调操作）
enum AppButtonSize {
  small,   // 小号按钮
  medium,  // 中号按钮（默认）
  large,   // 大号按钮
}

// ========== 主组件 ==========

/// 通用按钮组件
///
/// ## 设计理念
/// - 提供合理的默认值，开箱即用
/// - 完全可配置的样式（不硬编码颜色）
/// - 预留扩展插槽，支持自定义
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// AppButton(text: "点击我", onPressed: () {})
///
/// // 不同类型
/// AppButton(text: "删除", type: AppButtonType.danger, onPressed: () {})
///
/// // 不同尺寸
/// AppButton(text: "确定", size: AppButtonSize.large, onPressed: () {})
///
/// // 加载状态
/// AppButton(text: "提交中", isLoading: true, onPressed: () {})
///
/// // 带图标
/// AppButton(text: "分享", icon: Icon(Icons.share), onPressed: () {})
///
/// // 全宽按钮
/// AppButton(text: "登录", isFullWidth: true, onPressed: () {})
///
/// // 自定义颜色
/// AppButton(
///   text: "自定义",
///   backgroundColor: Colors.orange,
///   foregroundColor: Colors.white,
///   onPressed: () {},
/// )
/// ```
class AppButton extends StatelessWidget {
  // ========== 基础属性 ==========

  /// 按钮文字内容
  final String text;

  /// 点击回调事件（为null时按钮禁用）
  final VoidCallback? onPressed;

  /// 按钮类型（默认主要按钮）
  final AppButtonType type;

  /// 按钮尺寸（默认中号）
  final AppButtonSize size;

  /// 是否显示加载状态（显示时按钮禁用）
  final bool isLoading;

  /// 是否为全宽按钮（true时宽度占满父容器）
  final bool isFullWidth;

  /// 按钮图标（显示在文字前面）
  final Widget? icon;

  /// 按钮主轴尺寸（默认最小尺寸，可设为 max 填满父容器）
  final MainAxisSize mainAxisSize;

  // ========== 样式配置属性 ==========

  /// 背景色（null则使用类型对应的默认色）
  final Color? backgroundColor;

  /// 前景色（文字和图标颜色，null则使用类型对应的默认色）
  final Color? foregroundColor;

  /// 禁用状态背景色（null则使用类型对应的默认色）
  final Color? disabledBackgroundColor;

  /// 禁用状态前景色（null则使用灰色）
  final Color? disabledForegroundColor;

  /// 边框颜色（仅outline类型有效，null则使用蓝色）
  final Color? borderColor;

  /// 圆角半径（null则使用8px）
  final double? borderRadius;

  /// 内边距（null则根据尺寸使用默认值）
  final EdgeInsetsGeometry? padding;

  /// 最小尺寸（null则根据尺寸使用默认值）
  final Size? minimumSize;

  /// 图标与文字的间距（null则根据尺寸使用默认值）
  final double? iconSpacing;

  /// 文字样式（null则使用默认样式）
  final TextStyle? textStyle;

  // ========== 扩展插槽属性 ==========

  /// 自定义加载指示器（null则使用默认的圆形进度条）
  final Widget? loadingWidget;

  /// 自定义按钮内容（设置后完全忽略text、icon等默认内容）
  final Widget? childBuilder;

  /// 按钮前缀插槽（显示在图标/文字前面）
  final Widget? prefix;

  /// 按钮后缀插槽（显示在文字后面）
  final Widget? suffix;

  const AppButton({
    super.key,
    required this.text,           // 必填：按钮文字
    this.onPressed,               // 可选：点击回调
    this.type = AppButtonType.primary,  // 默认主要按钮
    this.size = AppButtonSize.medium,  // 默认中号
    this.isLoading = false,       // 默认非加载状态
    this.isFullWidth = false,     // 默认非全宽
    this.icon,                    // 可选：图标
    this.mainAxisSize = MainAxisSize.min,  // 默认最小尺寸
    // 样式配置
    this.backgroundColor,         // 背景色
    this.foregroundColor,         // 前景色
    this.disabledBackgroundColor, // 禁用背景色
    this.disabledForegroundColor, // 禁用前景色
    this.borderColor,            // 边框色
    this.borderRadius,           // 圆角半径
    this.padding,                // 内边距
    this.minimumSize,            // 最小尺寸
    this.iconSpacing,            // 图标间距
    this.textStyle,              // 文字样式
    // 扩展插槽
    this.loadingWidget,          // 加载指示器
    this.childBuilder,           // 自定义内容
    this.prefix,                 // 前缀插槽
    this.suffix,                 // 后缀插槽
  });

  @override
  Widget build(BuildContext context) {
    // 构建按钮内容（优先使用自定义内容，否则使用默认内容）
    final buttonChild = _buildButtonChild();

    // 构建外层容器（处理全宽）
    return _buildButtonWrapper(buttonChild);
  }

  // ========== 状态判断函数 ==========

  /// 判断按钮是否禁用
  bool _isButtonDisabled() {
    return onPressed == null || isLoading;
  }

  // ========== 内容构建函数 ==========

  /// 构建按钮内容
  Widget _buildButtonChild() {
    // 如果有自定义内容构建器，使用自定义内容
    if (childBuilder != null) {
      return childBuilder!;
    }

    // 如果正在加载且有自定义加载指示器，使用自定义加载指示器
    if (isLoading && loadingWidget != null) {
      return loadingWidget!;
    }

    // 如果正在加载，使用默认加载指示器
    if (isLoading) {
      return _buildDefaultLoadingChild();
    }

    // 否则使用默认内容
    return _buildDefaultChild();
  }

  /// 构建默认按钮内容（前缀 + 图标 + 文字 + 后缀）
  Widget _buildDefaultChild() {
    final children = _buildContentChildren();

    return Row(
      mainAxisSize: mainAxisSize,
      children: _spacedChildren(children),
    );
  }

  /// 构建内容子元素列表
  List<Widget> _buildContentChildren() {
    return [
      if (prefix != null) prefix!,        // 前缀插槽
      if (icon != null && !isLoading) icon!, // 图标（非加载状态）
      if (text.isNotEmpty) _buildText(),   // 文字
      if (suffix != null) suffix!,        // 后缀插槽
    ];
  }

  /// 构建文字组件
  Widget _buildText() {
    return Text(text, style: textStyle);
  }

  /// 为子元素列表添加间距
  List<Widget> _spacedChildren(List<Widget> children) {
    if (children.isEmpty) return children;

    final spacing = iconSpacing ?? _getDefaultIconSpacing();
    final spaced = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      // 在元素之间添加间距（最后一个元素除外）
      if (i < children.length - 1) {
        spaced.add(SizedBox(width: spacing));
      }
    }

    return spaced;
  }

  /// 构建默认加载指示器
  Widget _buildDefaultLoadingChild() {
    final iconSize = _getDefaultIconSize();
    final spacing = iconSpacing ?? _getDefaultIconSpacing();

    return Row(
      mainAxisSize: mainAxisSize,
      children: [
        // 圆形进度条
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,  // 线条粗细
            valueColor: AlwaysStoppedAnimation<Color>(
              foregroundColor ?? _getDefaultTextColor(),
            ),
          ),
        ),
        // 如果有文字，添加间距
        if (text.isNotEmpty) SizedBox(width: spacing),
        // 如果有文字，显示文字
        if (text.isNotEmpty) Text(text, style: textStyle),
      ],
    );
  }

  // ========== 容器构建函数 ==========

  /// 构建按钮外层容器（处理全宽）
  Widget _buildButtonWrapper(Widget child) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,  // 全宽时宽度无限
      child: _buildButtonWidget(child),
    );
  }

  /// 构建按钮组件（根据类型选择不同的按钮）
  Widget _buildButtonWidget(Widget child) {
    final isDisabled = _isButtonDisabled();

    // 根据按钮类型选择对应的按钮组件
    return switch (type) {
      AppButtonType.primary || AppButtonType.secondary || AppButtonType.danger =>
        _buildElevatedButton(isDisabled, child),
      AppButtonType.outline => _buildOutlinedButton(isDisabled, child),
      AppButtonType.text => _buildTextButton(isDisabled, child),
    };
  }

  /// 构建凸起按钮（primary、secondary、danger）
  Widget _buildElevatedButton(bool isDisabled, Widget child) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getEffectiveBackgroundColor(),      // 背景色
        foregroundColor: _getEffectiveForegroundColor(),      // 前景色
        disabledBackgroundColor: _getEffectiveDisabledBackgroundColor(),  // 禁用背景色
        disabledForegroundColor: disabledForegroundColor ?? Colors.grey.shade400,  // 禁用前景色
        padding: _getEffectivePadding(),                      // 内边距
        minimumSize: _getEffectiveMinimumSize(),              // 最小尺寸
        shape: RoundedRectangleBorder(                         // 圆角形状
          borderRadius: BorderRadius.circular(_getEffectiveBorderRadius()),
        ),
      ),
      child: child,
    );
  }

  /// 构建描边按钮（outline）
  Widget _buildOutlinedButton(bool isDisabled, Widget child) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _getEffectiveForegroundColor(),      // 前景色
        disabledForegroundColor: disabledForegroundColor ?? Colors.grey.shade400,  // 禁用前景色
        side: BorderSide(color: _getEffectiveBorderColor()),  // 边框样式
        padding: _getEffectivePadding(),                      // 内边距
        minimumSize: _getEffectiveMinimumSize(),              // 最小尺寸
        shape: RoundedRectangleBorder(                         // 圆角形状
          borderRadius: BorderRadius.circular(_getEffectiveBorderRadius()),
        ),
      ),
      child: child,
    );
  }

  /// 构建文本按钮（text）
  Widget _buildTextButton(bool isDisabled, Widget child) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: _getEffectiveForegroundColor(),      // 前景色
        disabledForegroundColor: disabledForegroundColor ?? Colors.grey.shade400,  // 禁用前景色
        padding: _getEffectivePadding(),                      // 内边距
        minimumSize: _getEffectiveMinimumSize(),              // 最小尺寸
      ),
      child: child,
    );
  }

  // ========== 样式获取函数 ==========

  /// 获取有效的背景色（自定义或默认）
  Color _getEffectiveBackgroundColor() {
    return backgroundColor ?? _getDefaultBackgroundColor();
  }

  /// 获取有效的前景色（自定义或默认）
  Color _getEffectiveForegroundColor() {
    return foregroundColor ?? _getDefaultTextColor();
  }

  /// 获取有效的禁用背景色（自定义或默认）
  Color _getEffectiveDisabledBackgroundColor() {
    return disabledBackgroundColor ?? _getDefaultDisabledBackgroundColor();
  }

  /// 获取有效的边框色（自定义或默认）
  Color _getEffectiveBorderColor() {
    return borderColor ?? _getDefaultBorderColor();
  }

  /// 获取有效的圆角半径（自定义或默认8px）
  double _getEffectiveBorderRadius() {
    return borderRadius ?? 8.0;
  }

  /// 获取有效的内边距（自定义或默认）
  EdgeInsetsGeometry _getEffectivePadding() {
    return padding ?? _getDefaultPadding();
  }

  /// 获取有效的最小尺寸（自定义或默认）
  Size _getEffectiveMinimumSize() {
    return minimumSize ?? _getDefaultMinimumSize();
  }

  // ========== 默认样式函数 ==========

  /// 获取默认背景色（根据按钮类型）
  Color _getDefaultBackgroundColor() {
    switch (type) {
      case AppButtonType.primary:
        return Colors.blue.shade600;    // 主要按钮：蓝色
      case AppButtonType.secondary:
        return Colors.grey.shade200;    // 次要按钮：浅灰色
      case AppButtonType.danger:
        return Colors.red.shade600;     // 危险按钮：红色
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;      // 描边/文本按钮：透明
    }
  }

  /// 获取默认文字颜色（根据按钮类型）
  Color _getDefaultTextColor() {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;            // 主要/危险按钮：白色文字
      case AppButtonType.secondary:
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.blue.shade600;    // 次要/描边/文本按钮：蓝色文字
    }
  }

  /// 获取默认禁用背景色（根据按钮类型）
  Color _getDefaultDisabledBackgroundColor() {
    switch (type) {
      case AppButtonType.primary:
        return Colors.blue.shade200;    // 主要按钮：浅蓝色
      case AppButtonType.secondary:
        return Colors.grey.shade100;    // 次要按钮：更浅灰色
      case AppButtonType.danger:
        return Colors.red.shade200;     // 危险按钮：浅红色
      case AppButtonType.outline:
      case AppButtonType.text:
        return Colors.transparent;      // 描边/文本按钮：透明
    }
  }

  /// 获取默认边框颜色
  Color _getDefaultBorderColor() {
    return Colors.blue.shade600;        // 默认蓝色边框
  }

  // ========== 尺寸获取函数 ==========

  /// 获取默认内边距（根据按钮尺寸）
  EdgeInsets _getDefaultPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);   // 小号：紧凑
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);  // 中号：适中
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);  // 大号：宽敞
    }
  }

  /// 获取默认最小尺寸（根据按钮尺寸）
  Size _getDefaultMinimumSize() {
    switch (size) {
      case AppButtonSize.small:
        return const Size(64, 32);   // 小号：64x32
      case AppButtonSize.medium:
        return const Size(80, 44);   // 中号：80x44
      case AppButtonSize.large:
        return const Size(96, 52);   // 大号：96x52
    }
  }

  /// 获取默认图标尺寸（根据按钮尺寸）
  double _getDefaultIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 14;   // 小号：14px
      case AppButtonSize.medium:
        return 16;   // 中号：16px
      case AppButtonSize.large:
        return 20;   // 大号：20px
    }
  }

  /// 获取默认图标间距（根据按钮尺寸）
  double _getDefaultIconSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 6;    // 小号：6px
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return 8;    // 中号/大号：8px
    }
  }
}
