import 'package:flutter/material.dart';

/// 加载指示器类型
enum AppLoadingType {
  circular,
  linear,
  dots,
}

/// 通用加载指示器
///
/// 设计理念：
/// - 提供合理的默认值
/// - 完全可配置的样式
/// - 预留扩展插槽
class AppLoading extends StatelessWidget {
  final AppLoadingType type;
  final Color? color;
  final double? size;
  final String? message;

  // ========== 可配置样式 ==========
  final double? strokeWidth;
  final TextStyle? messageStyle;
  final MainAxisAlignment? alignment;
  final EdgeInsetsGeometry? padding;

  // ========== 扩展插槽 ==========
  /// 完全自定义的加载器
  final Widget? customBuilder;

  /// 自定义消息组件
  final Widget? messageWidget;

  const AppLoading({
    super.key,
    this.type = AppLoadingType.circular,
    this.color,
    this.size,
    this.message,
    // 可配置样式
    this.strokeWidth,
    this.messageStyle,
    this.alignment,
    this.padding,
    // 扩展插槽
    this.customBuilder,
    this.messageWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 如果提供了自定义构建器，使用它
    if (customBuilder != null) {
      return customBuilder!;
    }

    final effectiveColor = color ?? Theme.of(context).primaryColor;
    final effectiveAlignment = alignment ?? MainAxisAlignment.center;
    final effectivePadding = padding ?? const EdgeInsets.all(16);

    // 如果有消息，使用消息布局
    if (message != null || messageWidget != null) {
      return Padding(
        padding: effectivePadding,
        child: Column(
          mainAxisAlignment: effectiveAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoading(effectiveColor),
            if (messageWidget != null) ...[
              SizedBox(height: size != null ? size! / 2 : 8),
              messageWidget!,
            ] else if (message != null && message!.isNotEmpty) ...[
              SizedBox(height: size != null ? size! / 2 : 8),
              Text(
                message!,
                style: messageStyle ??
                    TextStyle(
                      color: effectiveColor,
                      fontSize: 14,
                    ),
              ),
            ],
          ],
        ),
      );
    }

    return _buildLoading(effectiveColor);
  }

  Widget _buildLoading(Color effectiveColor) {
    switch (type) {
      case AppLoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: effectiveColor,
            strokeWidth: strokeWidth ?? (size != null ? size! / 8 : 3),
          ),
        );
      case AppLoadingType.linear:
        return SizedBox(
          width: size ?? double.infinity,
          child: LinearProgressIndicator(
            color: effectiveColor,
            minHeight: size != null ? size! / 10 : 4,
          ),
        );
      case AppLoadingType.dots:
        return SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: _DotsLoading(color: effectiveColor),
        );
    }
  }
}

/// 点状加载指示器
class _DotsLoading extends StatefulWidget {
  final Color color;

  const _DotsLoading({required this.color});

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + 0.5 * (1 - (value * 2 - 1).abs());
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
