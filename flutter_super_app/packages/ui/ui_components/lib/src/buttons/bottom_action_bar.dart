import 'package:flutter/material.dart';
import 'action_button.dart';

/// 主要按钮配置（左侧带边框的按钮）
class PrimaryButtonConfig {
  /// 图标
  final IconData icon;

  /// 文本
  final String label;

  /// 图标大小
  final double? iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 文字颜色
  final Color? labelColor;

  /// 文字大小
  final double? labelFontSize;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 圆角半径
  final double? borderRadius;

  /// 水平内边距
  final double? horizontalPadding;

  /// 垂直内边距
  final double? verticalPadding;

  /// 图标和文字的间距
  final double? iconTextSpacing;

  /// 点击回调
  final VoidCallback? onTap;

  const PrimaryButtonConfig({
    required this.icon,
    required this.label,
    this.iconSize,
    this.iconColor,
    this.labelColor,
    this.labelFontSize,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.horizontalPadding,
    this.verticalPadding,
    this.iconTextSpacing,
    this.onTap,
  });

  /// 复制并修改部分属性
  PrimaryButtonConfig copyWith({
    IconData? icon,
    String? label,
    double? iconSize,
    Color? iconColor,
    Color? labelColor,
    double? labelFontSize,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    double? horizontalPadding,
    double? verticalPadding,
    double? iconTextSpacing,
    VoidCallback? onTap,
  }) {
    return PrimaryButtonConfig(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      labelColor: labelColor ?? this.labelColor,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      iconTextSpacing: iconTextSpacing ?? this.iconTextSpacing,
      onTap: onTap ?? this.onTap,
    );
  }
}

/// 底部操作栏配置
class BottomActionBarConfig {
  /// 主要按钮配置（左侧带边框的按钮）
  final PrimaryButtonConfig? primaryButton;

  /// 右侧操作按钮列表
  final List<ActionButtonConfig>? actionButtons;

  /// 按钮之间的间距
  final double? buttonSpacing;

  /// 左右内边距
  final double? horizontalPadding;

  /// 上下内边距
  final double? verticalPadding;

  /// 背景颜色
  final Color? backgroundColor;

  /// 顶部边框颜色
  final Color? topBorderColor;

  /// 顶部边框宽度
  final double? topBorderWidth;

  const BottomActionBarConfig({
    this.primaryButton,
    this.actionButtons,
    this.buttonSpacing,
    this.horizontalPadding,
    this.verticalPadding,
    this.backgroundColor,
    this.topBorderColor,
    this.topBorderWidth,
  });

  /// 复制并修改部分属性
  BottomActionBarConfig copyWith({
    PrimaryButtonConfig? primaryButton,
    List<ActionButtonConfig>? actionButtons,
    double? buttonSpacing,
    double? horizontalPadding,
    double? verticalPadding,
    Color? backgroundColor,
    Color? topBorderColor,
    double? topBorderWidth,
  }) {
    return BottomActionBarConfig(
      primaryButton: primaryButton ?? this.primaryButton,
      actionButtons: actionButtons ?? this.actionButtons,
      buttonSpacing: buttonSpacing ?? this.buttonSpacing,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      topBorderColor: topBorderColor ?? this.topBorderColor,
      topBorderWidth: topBorderWidth ?? this.topBorderWidth,
    );
  }
}

/// 底部操作栏组件
///
/// 包含左侧的主要按钮（带边框，Expanded）和右侧的多个操作按钮
class BottomActionBar extends StatelessWidget {
  /// 操作栏配置
  final BottomActionBarConfig config;

  const BottomActionBar({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // 如果缺少必要的参数，返回空组件
    if (config.backgroundColor == null ||
        config.topBorderColor == null ||
        config.topBorderWidth == null ||
        config.horizontalPadding == null ||
        config.verticalPadding == null ||
        config.buttonSpacing == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: Border(
          top: BorderSide(
            color: config.topBorderColor!,
            width: config.topBorderWidth!,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: config.horizontalPadding!,
            vertical: config.verticalPadding!,
          ),
          child: Row(
            children: [
              // 主要按钮（Expanded，占满剩余空间）- 仅在有 primaryButton 时显示
              if (config.primaryButton != null) ...[
                Expanded(child: _buildPrimaryButton()),
                SizedBox(width: config.buttonSpacing!),
              ],
              // 右侧操作按钮列表（自然宽度，右对齐）
              ..._buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建主要按钮
  Widget _buildPrimaryButton() {
    if (config.primaryButton == null) {
      return const SizedBox.shrink();
    }

    final buttonConfig = config.primaryButton!;

    // 如果缺少必要的参数，返回空组件
    if (buttonConfig.borderColor == null ||
        buttonConfig.borderWidth == null ||
        buttonConfig.borderRadius == null ||
        buttonConfig.horizontalPadding == null ||
        buttonConfig.verticalPadding == null ||
        buttonConfig.iconSize == null ||
        buttonConfig.iconColor == null ||
        buttonConfig.labelColor == null ||
        buttonConfig.labelFontSize == null ||
        buttonConfig.iconTextSpacing == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(buttonConfig.borderRadius!),
      child: InkWell(
        onTap: buttonConfig.onTap,
        borderRadius: BorderRadius.circular(buttonConfig.borderRadius!),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: buttonConfig.borderColor!,
              width: buttonConfig.borderWidth!,
            ),
            borderRadius: BorderRadius.circular(buttonConfig.borderRadius!),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: buttonConfig.horizontalPadding!,
            vertical: buttonConfig.verticalPadding!,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  buttonConfig.icon,
                  size: buttonConfig.iconSize,
                  color: buttonConfig.iconColor,
                ),
                SizedBox(width: buttonConfig.iconTextSpacing!),
                Text(
                  buttonConfig.label,
                  style: TextStyle(
                    color: buttonConfig.labelColor,
                    fontSize: buttonConfig.labelFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建右侧操作按钮列表
  List<Widget> _buildActionButtons() {
    if (config.actionButtons == null) {
      return [];
    }

    return config.actionButtons!.map((buttonConfig) {
      return ActionButton(config: buttonConfig);
    }).toList();
  }
}
