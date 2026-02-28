library;

import 'package:flutter/material.dart';

// ========== 枚举定义 ==========

/// 列表项类型
///
/// 定义了常见的列表项样式：
/// - navigation: 导航项（右侧 > 箭头，跳转到其他页面）
/// - disclosure: 展开项（右侧 ↓ 箭头，展开/折叠内容）
/// - toggle: 开关项（右侧 Switch 控件，开启/关闭功能）
/// - checkbox: 复选项（右侧 ☑ 复选框，多选场景）
/// - radio: 单选项（右侧 ○ 单选框，单选场景）
/// - menu: 菜单项（图标+文字，用于悬浮菜单、底部菜单）
/// - action: 操作项（用于对话框菜单）
/// - basic: 基础项（仅文字内容）
/// - custom: 自定义（完全自定义内容）
enum AppListTileType {
  navigation,  // 导航项（跳转页面）
  disclosure,  // 展开项（展开折叠）
  toggle,      // 开关项
  checkbox,    // 复选项
  radio,       // 单选项
  menu,        // 菜单项
  action,      // 操作项
  basic,       // 基础项
  custom,      // 自定义
}

// ========== 主组件 ==========

/// 通用列表项组件
///
/// ## 设计理念
/// - 提供合理的默认值，开箱即用
/// - 完全可配置的样式（不硬编码颜色）
/// - 预留扩展插槽，支持自定义
/// - 覆盖常见的列表项使用场景
///
/// ## 使用示例
/// ```dart
/// // 导航项（设置页面）
/// AppListTile(
///   title: "账号与安全",
///   subtitle: "管理密码和隐私",
///   leading: Icon(Icons.security),
///   onTap: () => push(AccountSecurityPage()),
/// )
///
/// // 开关项（设置页面）
/// AppListTile(
///   title: "消息通知",
///   subtitle: "接收新消息通知",
///   leading: Icon(Icons.notifications),
///   type: AppListTileType.toggle,
///   value: true,
///   onChanged: (value) => updateNotification(value),
/// )
///
/// // 菜单项（悬浮菜单）
/// AppListTile(
///   title: "发起群聊",
///   leading: Icon(Icons.group_add),
///   type: AppListTileType.menu,
///   onTap: () => startGroupChat(),
/// )
///
/// // 复选项（多选列表）
/// AppListTile(
///   title: "篮球",
///   type: AppListTileType.checkbox,
///   value: isSelected,
///   onChanged: (value) => selectItem(value),
/// )
/// ```
class AppListTile extends StatelessWidget {
  // ========== 基础属性 ==========

  /// 列表项类型（默认导航项）
  final AppListTileType type;

  /// 主标题文字
  final String title;

  /// 副标题文字（可选）
  final String? subtitle;

  /// 点击回调事件
  final VoidCallback? onTap;

  /// 是否禁用（禁用时不可点击且变灰）
  final bool enabled;

  // ========== 内容属性 ==========

  /// 前缀图标/组件（显示在左侧）
  final Widget? leading;

  /// 后缀组件（显示在右侧，完全自定义）
  final Widget? trailing;

  // ========== 控件属性（toggle/checkbox/radio） ==========

  /// 控件值（用于 toggle/checkbox/radio）
  final bool? value;

  /// 控件值变化回调（用于 toggle/checkbox/radio）
  final ValueChanged<bool?>? onChanged;

  /// Switch 控件的配置属性
  final Color? activeColor;          // 激活颜色
  final Color? activeTrackColor;    // 激活轨道颜色
  final Color? inactiveThumbColor;  // 非激活滑块颜色
  final Color? inactiveTrackColor;  // 非激活轨道颜色

  // ========== 样式配置属性 ==========

  /// 背景色（null 则使用透明）
  final Color? backgroundColor;

  /// 标题文字颜色（null 则使用默认黑色）
  final Color? titleColor;

  /// 副标题文字颜色（null 则使用默认灰色）
  final Color? subtitleColor;

  /// 图标颜色（null 则使用默认灰色）
  final Color? leadingColor;

  /// 箭头颜色（null 则使用默认灰色）
  final Color? trailingArrowColor;

  /// 分隔线颜色（null 则使用默认浅灰色）
  final Color? dividerColor;

  /// 圆角半径（null 则使用 0，即无圆角）
  final double? borderRadius;

  /// 内边距（null 则使用默认值）
  final EdgeInsetsGeometry? padding;

  /// 标题文字样式
  final TextStyle? titleStyle;

  /// 副标题文字样式
  final TextStyle? subtitleStyle;

  // ========== 布局属性 ==========

  /// 是否显示底部分隔线
  final bool hasDivider;

  /// 分隔线高度（null 则使用 1px）
  final double? dividerHeight;

  /// 分隔线左边距（用于分隔线不延伸到边缘）
  final double? dividerIndent;

  /// 列表项高度（null 则根据内容自适应）
  final double? height;

  /// 是否紧凑模式（减少内边距，适合密集列表）
  final bool isDense;

  /// 水波纹颜色（null 则使用默认灰色）
  final Color? splashColor;

  /// 高亮颜色（null 则使用默认灰色）
  final Color? highlightColor;

  // ========== 扩展插槽属性 ==========

  /// 自定义标题区域（完全控制标题显示）
  final Widget? titleBuilder;

  /// 自定义副标题区域（完全控制副标题显示）
  final Widget? subtitleBuilder;

  /// 自定义后缀区域（完全控制后缀显示）
  final Widget? trailingBuilder;

  /// 自定义内容（设置后忽略 title、subtitle、leading、trailing）
  final Widget? childBuilder;

  const AppListTile({
    super.key,
    // 基础属性
    this.type = AppListTileType.navigation,  // 默认导航项
    required this.title,                    // 必填：标题
    this.subtitle,                          // 可选：副标题
    this.onTap,                            // 可选：点击回调
    this.enabled = true,                    // 默认：启用
    // 内容属性
    this.leading,                           // 可选：前缀图标
    this.trailing,                          // 可选：后缀组件
    // 控件属性
    this.value,                            // 控件值
    this.onChanged,                        // 控件变化回调
    this.activeColor,                      // 激活颜色
    this.activeTrackColor,                 // 激活轨道颜色
    this.inactiveThumbColor,               // 非激活滑块颜色
    this.inactiveTrackColor,               // 非激活轨道颜色
    // 样式配置
    this.backgroundColor,                   // 背景色
    this.titleColor,                       // 标题颜色
    this.subtitleColor,                    // 副标题颜色
    this.leadingColor,                     // 前缀图标颜色
    this.trailingArrowColor,               // 箭头颜色
    this.dividerColor,                     // 分隔线颜色
    this.borderRadius,                     // 圆角半径
    this.padding,                          // 内边距
    this.titleStyle,                       // 标题样式
    this.subtitleStyle,                    // 副标题样式
    this.splashColor,                      // 水波纹颜色
    this.highlightColor,                   // 高亮颜色
    // 布局属性
    this.hasDivider = false,               // 默认：无分隔线
    this.dividerHeight,                    // 分隔线高度
    this.dividerIndent,                    // 分隔线左边距
    this.height,                           // 列表项高度
    this.isDense = false,                  // 默认：非紧凑模式
    // 扩展插槽
    this.titleBuilder,                     // 自定义标题
    this.subtitleBuilder,                  // 自定义副标题
    this.trailingBuilder,                  // 自定义后缀
    this.childBuilder,                     // 自定义内容
  });

  @override
  Widget build(BuildContext context) {
    // 如果有完全自定义的内容构建器，使用自定义内容
    if (childBuilder != null) {
      return _buildCustomTile();
    }

    // 否则根据类型构建对应的列表项
    return _buildDefaultTile();
  }

  // ========== 自定义列表项 ==========

  /// 构建自定义列表项（使用 childBuilder）
  Widget _buildCustomTile() {
    return _buildTileContainer(
      child: childBuilder!,
    );
  }

  // ========== 默认列表项 ==========

  /// 构建默认列表项
  Widget _buildDefaultTile() {
    return _buildTileContainer(
      child: _buildTileContent(),
    );
  }

  /// 构建列表项容器（处理背景色、圆角、分隔线）
  Widget _buildTileContainer({required Widget child}) {
    final effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
    final effectiveBorderRadius = borderRadius ?? 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          child: child,
        ),
        // 分隔线
        if (hasDivider && _hasDividerStyle()) _buildDivider(),
      ],
    );
  }

  /// 检查是否有分隔线样式（全部参数都不为空）
  bool _hasDividerStyle() {
    return dividerColor != null && dividerHeight != null && dividerIndent != null;
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      color: Colors.white,  // 🔥 分隔线容器背景色为白色
      height: dividerHeight!,
      child: Container(
        height: dividerHeight!,
        color: dividerColor!,
        margin: EdgeInsets.only(left: dividerIndent!),
      ),
    );
  }

  /// 构建列表项内容
  Widget _buildTileContent() {
    final effectivePadding = padding ?? _getDefaultPadding();

    return InkWell(
      onTap: enabled ? onTap : null,  // 禁用时不可点击
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: Container(
        padding: effectivePadding,
        height: height,
        child: Row(
          children: [
            // 前缀图标
            if (leading != null) ...[
              _buildLeading(),
              SizedBox(width: 16),  // 图标和标题的间距
            ],
            // 标题和副标题
            Expanded(
              child: _buildTitleArea(),
            ),
            SizedBox(width: 16),  // 标题和后缀的间距
            // 后缀组件
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  /// 构建前缀图标
  Widget _buildLeading() {
    final effectiveLeadingColor = leadingColor ?? Colors.grey.shade600;

    return IconTheme(
      data: IconThemeData(color: effectiveLeadingColor),
      child: leading!,
    );
  }

  /// 构建标题区域（标题 + 副标题）
  Widget _buildTitleArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题
        if (titleBuilder != null)
          titleBuilder!
        else
          Text(
            title,
            style: _getTitleStyle(),
          ),
        // 副标题
        if (subtitle != null) ...[
          SizedBox(height: 4),  // 标题和副标题的间距
          if (subtitleBuilder != null)
            subtitleBuilder!
          else
            Text(
              subtitle!,
              style: _getSubtitleStyle(),
            ),
        ],
      ],
    );
  }

  /// 构建后缀组件
  Widget _buildTrailing() {
    // 如果有自定义后缀构建器，使用自定义后缀
    if (trailingBuilder != null) {
      return trailingBuilder!;
    }

    // 如果有自定义后缀组件，使用自定义后缀
    if (trailing != null) {
      return trailing!;
    }

    // 否则根据类型构建默认后缀
    return _buildDefaultTrailing();
  }

  /// 构建默认后缀组件（根据类型）
  Widget _buildDefaultTrailing() {
    return switch (type) {
      // 导航项：右侧箭头 >
      AppListTileType.navigation => _buildNavigationArrow(),

      // 展开项：向下箭头 ↓（可根据展开状态变化）
      AppListTileType.disclosure => _buildDisclosureArrow(),

      // 开关项：Switch 控件
      AppListTileType.toggle => _buildToggleSwitch(),

      // 复选项：Checkbox 控件
      AppListTileType.checkbox => _buildCheckbox(),

      // 单选项：Radio 控件
      AppListTileType.radio => _buildRadio(),

      // 菜单项/操作项/基础项：无后缀
      AppListTileType.menu ||
      AppListTileType.action ||
      AppListTileType.basic => const SizedBox.shrink(),

      // 自定义：无后缀
      AppListTileType.custom => const SizedBox.shrink(),
    };
  }

  /// 构建导航箭头（>）
  Widget _buildNavigationArrow() {
    final effectiveArrowColor = trailingArrowColor ?? Colors.grey.shade400;

    return Icon(
      Icons.chevron_right,
      color: effectiveArrowColor,
      size: 20,
    );
  }

  /// 构建展开箭头（↓）
  Widget _buildDisclosureArrow() {
    final effectiveArrowColor = trailingArrowColor ?? Colors.grey.shade400;

    return Icon(
      Icons.expand_more,
      color: effectiveArrowColor,
      size: 20,
    );
  }

  /// 构建 Switch 开关
  Widget _buildToggleSwitch() {
    final effectiveActiveColor = activeColor ?? Colors.blue.shade600;
    final effectiveActiveTrackColor = activeTrackColor ?? effectiveActiveColor.withValues(alpha: 0.5);
    final effectiveInactiveThumbColor = inactiveThumbColor ?? Colors.grey.shade300;
    final effectiveInactiveTrackColor = inactiveTrackColor ?? Colors.grey.shade300;

    return Switch(
      value: value ?? false,
      onChanged: enabled ? onChanged : null,  // 禁用时不可操作
      activeColor: effectiveActiveColor,
      activeTrackColor: effectiveActiveTrackColor,
      inactiveThumbColor: effectiveInactiveThumbColor,
      inactiveTrackColor: effectiveInactiveTrackColor,
    );
  }

  /// 构建 Checkbox 复选框
  Widget _buildCheckbox() {
    final effectiveActiveColor = activeColor ?? Colors.blue.shade600;

    return Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,  // 禁用时不可操作
      activeColor: effectiveActiveColor,
    );
  }

  /// 构建 Radio 单选框
  Widget _buildRadio() {
    final effectiveActiveColor = activeColor ?? Colors.blue.shade600;

    return Radio<bool>(
      value: true,
      groupValue: value ?? false,
      onChanged: enabled ? (v) => onChanged?.call(v ?? false) : null,  // 禁用时不可操作
      activeColor: effectiveActiveColor,
    );
  }

  // ========== 样式获取函数 ==========

  /// 获取标题文字样式
  TextStyle _getTitleStyle() {
    final defaultColor = enabled ? Colors.black : Colors.grey.shade400;
    final defaultStyle = TextStyle(
      fontSize: isDense ? 14 : 16,
      fontWeight: FontWeight.w500,
      color: defaultColor,
    );

    // 如果有自定义样式，合并自定义样式
    if (titleStyle != null) {
      return titleStyle!.copyWith(
        color: titleColor ?? defaultStyle.color,
      );
    }

    // 否则应用自定义颜色
    if (titleColor != null) {
      return defaultStyle.copyWith(color: titleColor);
    }

    return defaultStyle;
  }

  /// 获取副标题文字样式
  TextStyle _getSubtitleStyle() {
    final defaultColor = enabled ? Colors.grey.shade600 : Colors.grey.shade400;
    final defaultStyle = TextStyle(
      fontSize: isDense ? 12 : 14,
      color: defaultColor,
    );

    // 如果有自定义样式，合并自定义样式
    if (subtitleStyle != null) {
      return subtitleStyle!.copyWith(
        color: subtitleColor ?? defaultStyle.color,
      );
    }

    // 否则应用自定义颜色
    if (subtitleColor != null) {
      return defaultStyle.copyWith(color: subtitleColor);
    }

    return defaultStyle;
  }

  /// 获取默认内边距
  EdgeInsets _getDefaultPadding() {
    final horizontal = 16.0;
    final vertical = isDense ? 8.0 : 16.0;

    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }
}
