library;

import 'package:flutter/material.dart';

/// 可展开内容组件
///
/// 支持展开/收起动画，适用于长文本展示、商家信息、视频简介等场景
///
/// ## 使用示例
/// ```dart
/// // 受控模式（推荐）- 使用 Riverpod 管理状态
/// @riverpod
/// class ExpandState extends _$ExpandState {
///   @override
///   bool build() => false;
///   void toggle() => state = !state;
/// }
///
/// class MyWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final expanded = ref.watch(expandStateProvider);
///     return ExpandableContent(
///       expanded: expanded,
///       onTap: () => ref.read(expandStateProvider.notifier).toggle(),
///       title: '商品名称',
///       expandText: '详细描述...',
///     );
///   }
/// }
///
/// // 非受控模式（简单场景）- 组件内部管理状态
/// ExpandableContent(
///   title: '商品名称',
///   expandText: '详细描述...',
/// )
/// ```
class ExpandableContent extends StatefulWidget {
  /// 需要展开/收起的标题文本（如商家名称、视频标题）
  final String title;

  /// 标题区域右侧的自定义 Widget（替代原固定图标）
  final Widget? titleRightWidget;

  /// 标题下方的自定义信息区域（完全由调用方控制）
  final Widget? infoWidget;

  /// 需要展开/收起的详情文本（如活动描述、视频简介）
  final String expandText;

  /// 收起状态下的最大行数（默认 1 行）
  final int collapseMaxLines;

  /// 标题文本样式
  final TextStyle? titleStyle;

  /// 详情文本样式
  final TextStyle? expandTextStyle;

  /// 动画时长
  final Duration animationDuration;

  /// 是否展开（受控模式）
  final bool? expanded;

  /// 点击回调（受控模式）
  final VoidCallback? onTap;

  const ExpandableContent({
    super.key,
    required this.title,
    required this.expandText,
    this.titleRightWidget,
    this.infoWidget,
    this.collapseMaxLines = 1,
    this.titleStyle,
    this.expandTextStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.expanded,
    this.onTap,
  });

  @override
  State<ExpandableContent> createState() => _ExpandableContentState();
}

class _ExpandableContentState extends State<ExpandableContent>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  bool? _cachedExpanded;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _heightFactor = _controller.drive(_easeInTween);
    _cachedExpanded = widget.expanded;

    // 非受控模式：默认收起
    if (widget.expanded == null) {
      _controller.value = 0;
    } else {
      _controller.value = widget.expanded! ? 1.0 : 0;
    }
  }

  @override
  void didUpdateWidget(ExpandableContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 受控模式：同步外部状态
    if (widget.expanded != null && widget.expanded != _cachedExpanded) {
      _cachedExpanded = widget.expanded;
      if (widget.expanded!) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 是否展开
  bool get _isExpanded {
    if (widget.expanded != null) {
      return widget.expanded!;
    }
    return _cachedExpanded ?? false;
  }

  /// 切换展开/收起
  void _toggleExpand() {
    if (widget.onTap != null) {
      // 受控模式：调用外部回调
      widget.onTap!();
    } else {
      // 非受控模式：内部管理状态
      setState(() {
        _cachedExpanded = !_cachedExpanded!;
        if (_cachedExpanded!) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
  }

  /// 构建默认的展开/收起图标
  Widget _buildDefaultExpandIcon() {
    return Icon(
      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
      color: Colors.grey,
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 标题区域（可自定义右侧 Widget）
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: _isExpanded ? null : widget.collapseMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: widget.titleStyle ??
                        const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const SizedBox(width: 15),
                // 优先使用外部传入的右侧 Widget，否则使用默认图标
                widget.titleRightWidget ?? _buildDefaultExpandIcon(),
              ],
            ),
          ),
          // 2. 自定义信息区域（可选）
          if (widget.infoWidget != null) ...[
            const SizedBox(height: 8),
            widget.infoWidget!,
          ],
          // 3. 可展开的详情文本（核心动画区域）
          _buildExpandText(),
        ],
      ),
    );
  }

  /// 构建带动画的展开/收起文本
  Widget _buildExpandText() {
    // 收起状态：显示省略号；展开状态：显示完整文本
    final expandTextChild = _isExpanded
        ? Text(
            widget.expandText,
            style: widget.expandTextStyle ??
                const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
          )
        : Text(
            widget.expandText,
            maxLines: widget.collapseMaxLines,
            overflow: TextOverflow.ellipsis,
            style: widget.expandTextStyle ??
                const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
          );

    return AnimatedBuilder(
      animation: _controller.view,
      child: expandTextChild,
      builder: (context, child) {
        return Align(
          heightFactor: _heightFactor.value,
          alignment: Alignment.topCenter,
          child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 8),
            child: child,
          ),
        );
      },
    );
  }
}
