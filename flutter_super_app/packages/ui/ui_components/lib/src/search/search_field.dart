library;

import 'package:flutter/material.dart';

/// 搜索框样式配置
///
/// 采用不可变设计，支持链式调用
///
/// 注意：所有颜色和尺寸均需外部传入，避免硬编码
class SearchFieldStyleConfig {
  /// 背景颜色
  final Color backgroundColor;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 圆角
  final double borderRadius;

  /// 内边距
  final EdgeInsets padding;

  /// 文字颜色
  final Color textColor;

  /// 提示词颜色
  final Color hintColor;

  /// 文字大小
  final double fontSize;

  /// 光标颜色
  final Color cursorColor;

  /// 高度（null 表示自适应）
  final double? height;

  /// 内容间距（prefix、输入框、suffix 之间的间距）
  final double contentSpacing;

  const SearchFieldStyleConfig({
    required this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    required this.textColor,
    required this.hintColor,
    this.fontSize = 14,
    required this.cursorColor,
    this.height,
    this.contentSpacing = 8,
  });

  /// 链式调用：创建副本并修改部分属性
  SearchFieldStyleConfig copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    EdgeInsets? padding,
    Color? textColor,
    Color? hintColor,
    double? fontSize,
    Color? cursorColor,
    double? height,
    double? contentSpacing,
  }) {
    return SearchFieldStyleConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textColor: textColor ?? this.textColor,
      hintColor: hintColor ?? this.hintColor,
      fontSize: fontSize ?? this.fontSize,
      cursorColor: cursorColor ?? this.cursorColor,
      height: height ?? this.height,
      contentSpacing: contentSpacing ?? this.contentSpacing,
    );
  }

  /// 函数式：设置背景颜色
  SearchFieldStyleConfig withBackgroundColor(Color color) {
    return copyWith(backgroundColor: color);
  }

  /// 函数式：设置圆角
  SearchFieldStyleConfig withBorderRadius(double radius) {
    return copyWith(borderRadius: radius);
  }

  /// 函数式：设置内边距
  SearchFieldStyleConfig withPadding(EdgeInsets padding) {
    return copyWith(padding: padding);
  }

  /// 函数式：设置高度
  SearchFieldStyleConfig withHeight(double height) {
    return copyWith(height: height);
  }
}

/// 搜索框动画配置
///
/// 采用不可变设计，支持链式调用
class SearchFieldAnimationConfig {
  /// 动画时长
  final Duration duration;

  /// 动画曲线
  final Curve curve;

  /// 是否启用动画
  final bool enabled;

  const SearchFieldAnimationConfig({
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.enabled = true,
  });

  /// 链式调用：创建副本并修改部分属性
  SearchFieldAnimationConfig copyWith({
    Duration? duration,
    Curve? curve,
    bool? enabled,
  }) {
    return SearchFieldAnimationConfig(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      enabled: enabled ?? this.enabled,
    );
  }

  /// 函数式：设置动画时长
  SearchFieldAnimationConfig withDuration(Duration duration) {
    return copyWith(duration: duration);
  }

  /// 函数式：设置动画曲线
  SearchFieldAnimationConfig withCurve(Curve curve) {
    return copyWith(curve: curve);
  }

  /// 函数式：禁用动画
  SearchFieldAnimationConfig withoutAnimation() {
    return copyWith(enabled: false);
  }
}

/// 搜索框交互配置
///
/// 采用不可变设计，支持链式调用
class SearchFieldActionConfig {
  /// 整体点击回调
  final VoidCallback? onTap;

  /// 左侧 prefix 点击回调
  final VoidCallback? onPrefixTap;

  /// 右侧 suffix 点击回调
  final VoidCallback? onSuffixTap;

  /// 文字变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 清除回调（当右侧 widget 是清除按钮时）
  final VoidCallback? onClear;

  const SearchFieldActionConfig({
    this.onTap,
    this.onPrefixTap,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  /// 链式调用：创建副本并修改部分属性
  SearchFieldActionConfig copyWith({
    VoidCallback? onTap,
    VoidCallback? onPrefixTap,
    VoidCallback? onSuffixTap,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onClear,
  }) {
    return SearchFieldActionConfig(
      onTap: onTap ?? this.onTap,
      onPrefixTap: onPrefixTap ?? this.onPrefixTap,
      onSuffixTap: onSuffixTap ?? this.onSuffixTap,
      onChanged: onChanged ?? this.onChanged,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      onClear: onClear ?? this.onClear,
    );
  }

  /// 函数式：设置点击回调
  SearchFieldActionConfig withOnTap(VoidCallback onTap) {
    return copyWith(onTap: onTap);
  }

  /// 函数式：设置文字变化回调
  SearchFieldActionConfig withOnChanged(ValueChanged<String> onChanged) {
    return copyWith(onChanged: onChanged);
  }

  /// 函数式：设置清除回调
  SearchFieldActionConfig withOnClear(VoidCallback onClear) {
    return copyWith(onClear: onClear);
  }
}

/// 搜索框组件
///
/// ## 设计理念
/// - **函数式风格**：配置类不可变，通过 copyWith 和函数式方法实现链式调用
/// - **高度灵活**：所有样式均可外部配置，避免硬编码
/// - **丰富接口**：左侧 prefix、右侧 suffix、清除按钮均支持自定义 widget
/// - **动画支持**：prefix 和 suffix 支持淡入淡出动画
/// - **灵活交互**：支持整体点击和独立区域点击
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// SearchField(
///   controller: _controller,
///   hintText: '搜索...',
///   styleConfig: SearchFieldStyleConfig(
///     backgroundColor: Colors.grey[200]!,
///     textColor: Colors.black,
///     hintColor: Colors.grey,
///     cursorColor: Colors.blue,
///   ),
///   actionConfig: SearchFieldActionConfig(
///     onChanged: (text) => setState(() {}),
///     onSubmitted: (text) => print('搜索: $text'),
///   ),
///   prefix: Icon(Icons.search, color: Colors.grey),
/// )
///
/// // 高级用法：带清除按钮
/// SearchField(
///   controller: _controller,
///   hintText: '搜索...',
///   styleConfig: SearchFieldStyleConfig(
///     backgroundColor: Colors.grey[200]!,
///     textColor: Colors.black,
///     hintColor: Colors.grey,
///     cursorColor: Colors.blue,
///   ),
///   actionConfig: SearchFieldActionConfig(
///     onChanged: (text) => setState(() {}),
///     onClear: () => _controller.clear(),
///   ),
///   prefix: _buildPrefix(),
///   suffix: _controller.text.isNotEmpty ? _buildClearButton() : null,
///   animationConfig: SearchFieldAnimationConfig(),
/// )
/// ```
class SearchField extends StatefulWidget {
  /// 输入控制器
  final TextEditingController? controller;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 提示词
  final String? hintText;

  /// 左侧 widget（图标、提示词、或组合）
  final Widget? prefix;

  /// 右侧 widget（清除按钮、其他按钮）
  final Widget? suffix;

  /// 样式配置
  final SearchFieldStyleConfig? styleConfig;

  /// 动画配置
  final SearchFieldAnimationConfig? animationConfig;

  /// 交互配置
  final SearchFieldActionConfig? actionConfig;

  /// 是否自动获取焦点
  final bool autofocus;

  /// 是否只读
  final bool readOnly;

  /// 文字输入类型
  final TextInputType? keyboardType;

  /// 文字对齐方式
  final TextAlign textAlign;

  /// 最大行数
  final int maxLines;

  /// 最小行数
  final int minLines;

  const SearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefix,
    this.suffix,
    this.styleConfig,
    this.animationConfig,
    this.actionConfig,
    this.autofocus = false,
    this.readOnly = false,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  SearchFieldStyleConfig? get _styleConfig => widget.styleConfig;

  SearchFieldAnimationConfig? get _animationConfig => widget.animationConfig;

  SearchFieldActionConfig? get _actionConfig => widget.actionConfig;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? TextEditingController();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleConfig = _styleConfig;
    if (styleConfig == null) {
      return const SizedBox.shrink();
    }

    // 构建搜索框主体
    Widget searchField = Container(
      height: styleConfig.height,
      padding: styleConfig.padding,
      decoration: BoxDecoration(
        color: styleConfig.backgroundColor,
        border: styleConfig.borderColor != null
            ? Border.all(
                color: styleConfig.borderColor!,
                width: styleConfig.borderWidth,
              )
            : null,
        borderRadius: BorderRadius.circular(styleConfig.borderRadius),
      ),
      child: Row(
        children: [
          // 左侧 prefix（带动画）
          if (widget.prefix != null) ...[
            _buildAnimatedWidget(
              widget: widget.prefix!,
              onTap: _actionConfig?.onPrefixTap,
            ),
            SizedBox(width: styleConfig.contentSpacing),
          ],
          // 输入框
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              style: TextStyle(
                color: styleConfig.textColor,
                fontSize: styleConfig.fontSize,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: styleConfig.hintColor,
                  fontSize: styleConfig.fontSize,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: styleConfig.cursorColor,
              onChanged: _actionConfig?.onChanged,
              onSubmitted: _actionConfig?.onSubmitted,
              onTap: _actionConfig?.onTap,
            ),
          ),
          SizedBox(width: styleConfig.contentSpacing),
          // 右侧 suffix（带动画）
          if (widget.suffix != null)
            _buildAnimatedWidget(
              widget: widget.suffix!,
              onTap: _actionConfig?.onSuffixTap ?? _actionConfig?.onClear,
            ),
        ],
      ),
    );

    // 整体点击事件（如果没有配置 onTap，则不需要 InkWell）
    if (_actionConfig?.onTap != null &&
        _actionConfig?.onPrefixTap == null &&
        _actionConfig?.onSuffixTap == null) {
      searchField = InkWell(
        onTap: () {
          _actionConfig?.onTap?.call();
          _focusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(styleConfig.borderRadius),
        child: searchField,
      );
    }

    return searchField;
  }

  /// 构建带动画的 widget
  Widget _buildAnimatedWidget({
    required Widget widget,
    VoidCallback? onTap,
  }) {
    final animConfig = _animationConfig;
    if (animConfig == null || !animConfig.enabled) {
      return onTap != null
          ? GestureDetector(onTap: onTap, child: widget)
          : widget;
    }

    Widget animatedWidget = AnimatedOpacity(
      opacity: 1.0,
      duration: animConfig.duration,
      curve: animConfig.curve,
      child: AnimatedScale(
        scale: 1.0,
        duration: animConfig.duration,
        curve: animConfig.curve,
        child: widget,
      ),
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: animatedWidget)
        : animatedWidget;
  }
}
