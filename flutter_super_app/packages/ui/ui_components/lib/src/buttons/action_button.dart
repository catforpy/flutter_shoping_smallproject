import 'package:flutter/material.dart';

/// 操作按钮配置
class ActionButtonConfig {
  /// 图标
  final IconData icon;

  /// 文本
  final String label;

  /// 是否垂直布局（图标在上，文字在下）
  final bool isVertical;

  /// 图标大小
  final double? iconSize;

  /// 图标颜色
  final Color? iconColor;

  /// 文字颜色
  final Color? labelColor;

  /// 文字大小
  final double? labelFontSize;

  /// 水平内边距
  final double? horizontalPadding;

  /// 垂直内边距
  final double? verticalPadding;

  /// 水平布局时图标和文字的间距
  final double? horizontalSpacing;

  /// 垂直布局时图标和文字的间距
  final double? verticalSpacing;

  /// 点击水波纹的圆角半径
  final double? borderRadius;

  /// 点击回调
  final VoidCallback? onTap;

  const ActionButtonConfig({
    required this.icon,
    required this.label,
    required this.isVertical,
    this.iconSize,
    this.iconColor,
    this.labelColor,
    this.labelFontSize,
    this.horizontalPadding,
    this.verticalPadding,
    this.horizontalSpacing,
    this.verticalSpacing,
    this.borderRadius,
    this.onTap,
  });

  /// 复制并修改部分属性
  ActionButtonConfig copyWith({
    IconData? icon,
    String? label,
    bool? isVertical,
    double? iconSize,
    Color? iconColor,
    Color? labelColor,
    double? labelFontSize,
    double? horizontalPadding,
    double? verticalPadding,
    double? horizontalSpacing,
    double? verticalSpacing,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    return ActionButtonConfig(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      isVertical: isVertical ?? this.isVertical,
      iconSize: iconSize ?? this.iconSize,
      iconColor: iconColor ?? this.iconColor,
      labelColor: labelColor ?? this.labelColor,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
      verticalSpacing: verticalSpacing ?? this.verticalSpacing,
      borderRadius: borderRadius ?? this.borderRadius,
      onTap: onTap ?? this.onTap,
    );
  }
}

/// 操作按钮组件
///
/// 支持横向和纵向两种布局方式，带水波纹效果
class ActionButton extends StatelessWidget {
  /// 按钮配置
  final ActionButtonConfig config;

  const ActionButton({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // 如果缺少必要的参数，返回空组件
    if (config.iconSize == null ||
        config.iconColor == null ||
        config.labelColor == null ||
        config.labelFontSize == null ||
        config.horizontalPadding == null ||
        config.verticalPadding == null ||
        config.borderRadius == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: config.onTap,
        borderRadius: BorderRadius.circular(config.borderRadius!),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: config.horizontalPadding!,
            vertical: config.verticalPadding!,
          ),
          child: config.isVertical
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config.icon,
                      size: config.iconSize,
                      color: config.iconColor,
                    ),
                    if (config.verticalSpacing != null)
                      SizedBox(height: config.verticalSpacing!),
                    Text(
                      config.label,
                      style: TextStyle(
                        color: config.labelColor,
                        fontSize: config.labelFontSize,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config.icon,
                      size: config.iconSize,
                      color: config.iconColor,
                    ),
                    if (config.horizontalSpacing != null)
                      SizedBox(width: config.horizontalSpacing!),
                    Text(
                      config.label,
                      style: TextStyle(
                        color: config.labelColor,
                        fontSize: config.labelFontSize,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
