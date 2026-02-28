import 'package:flutter/material.dart';

/// 空状态组件
///
/// 设计理念：
/// - 提供合理的默认值
/// - 完全可配置的样式和布局
/// - 预留扩展插槽
class AppEmpty extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onActionPressed;

  // ========== 可配置样式 ==========
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment? alignment;
  final CrossAxisAlignment? contentAlignment;

  // ========== 扩展插槽 ==========
  /// 完全自定义内容
  final Widget? customContent;

  /// 自定义操作按钮
  final Widget? customAction;

  /// 自定义头部（图标/插图部分）
  final Widget? headerBuilder;

  const AppEmpty({
    super.key,
    this.message,
    this.icon,
    this.illustration,
    this.actionText,
    this.onActionPressed,
    // 可配置样式
    this.iconSize,
    this.iconColor,
    this.messageStyle,
    this.padding,
    this.alignment,
    this.contentAlignment,
    // 扩展插槽
    this.customContent,
    this.customAction,
    this.headerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 如果提供了自定义内容，使用它
    if (customContent != null) {
      return customContent!;
    }

    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: alignment ?? MainAxisAlignment.center,
          crossAxisAlignment: contentAlignment ?? CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 头部（图标/插图）
            if (headerBuilder != null)
              headerBuilder!
            else if (illustration != null)
              illustration!
            else if (icon != null)
              Icon(
                icon,
                size: iconSize ?? 64,
                color: iconColor ?? theme.disabledColor,
              )
            else
              Icon(
                Icons.inbox_outlined,
                size: iconSize ?? 64,
                color: iconColor ?? theme.disabledColor,
              ),
            // 消息
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: messageStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: theme.disabledColor,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            // 操作按钮
            if (_hasAction()) ...[
              const SizedBox(height: 24),
              _buildActionButton(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasAction() {
    return (actionText != null && onActionPressed != null) || customAction != null;
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    if (customAction != null) {
      return customAction!;
    }
    return ElevatedButton(
      onPressed: onActionPressed,
      child: Text(actionText!),
    );
  }
}

/// 错误状态组件
class AppError extends StatelessWidget {
  final String? message;
  final Widget? illustration;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final VoidCallback? onRetryPressed;

  // ========== 可配置样式 ==========
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? messageStyle;
  final EdgeInsetsGeometry? padding;

  // ========== 扩展插槽 ==========
  /// 完全自定义内容
  final Widget? customContent;

  /// 自定义操作按钮组
  final List<Widget>? actionButtons;

  const AppError({
    super.key,
    this.message,
    this.illustration,
    this.actionText,
    this.onActionPressed,
    this.onRetryPressed,
    // 可配置样式
    this.iconSize,
    this.iconColor,
    this.messageStyle,
    this.padding,
    // 扩展插槽
    this.customContent,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    // 如果提供了自定义内容，使用它
    if (customContent != null) {
      return customContent!;
    }

    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标/插图
            if (illustration != null)
              illustration!
            else
              Icon(
                Icons.error_outline,
                size: iconSize ?? 64,
                color: iconColor ?? Colors.red.shade300,
              ),
            // 消息
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: messageStyle ??
                    theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            // 操作按钮
            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    // 如果提供了自定义按钮组，使用它
    if (actionButtons != null) {
      return Wrap(
        spacing: 12,
        children: actionButtons!,
      );
    }

    // 否则使用默认按钮
    return Wrap(
      spacing: 12,
      children: [
        if (onRetryPressed != null)
          ElevatedButton.icon(
            onPressed: onRetryPressed,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        if (actionText != null && onActionPressed != null)
          OutlinedButton(
            onPressed: onActionPressed,
            child: Text(actionText!),
          ),
      ],
    );
  }
}
