library;

import 'package:flutter/material.dart';

/// 固定标签栏的标签项数据模型
class FixedTabItem {
  final String id;
  final String title;
  final IconData? icon;

  const FixedTabItem({
    required this.id,
    required this.title,
    this.icon,
  });
}

/// 固定标签栏样式配置
///
/// 采用不可变设计，支持链式调用
class FixedTabStyleConfig {
  /// 已选中文字颜色
  final Color selectedColor;

  /// 未选中文字颜色
  final Color unselectedColor;

  /// 已选中文字大小
  final double selectedFontSize;

  /// 未选中文字大小
  final double unselectedFontSize;

  /// 已选中文字粗细
  final FontWeight? selectedFontWeight;

  /// 未选中文字粗细
  final FontWeight? unselectedFontWeight;

  /// 下划线宽度
  final double indicatorWidth;

  /// 下划线高度
  final double indicatorHeight;

  /// 下划线圆角
  final double indicatorBorderRadius;

  /// 下划线与文字的间距
  final double indicatorGap;

  /// 下划线动画时长
  final Duration animationDuration;

  /// 下划线动画曲线
  final Curve animationCurve;

  /// 标签内边距
  final EdgeInsets padding;

  /// 是否使用弹性动画（拉伸→移动→收缩）
  final bool useElasticAnimation;

  const FixedTabStyleConfig({
    required this.selectedColor,
    required this.unselectedColor,
    this.selectedFontSize = 16,
    this.unselectedFontSize = 16,
    this.selectedFontWeight = FontWeight.w600,
    this.unselectedFontWeight = FontWeight.normal,
    this.indicatorWidth = 40,
    this.indicatorHeight = 3,
    this.indicatorBorderRadius = 1.5,
    this.indicatorGap = 8,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeInOut,
    this.padding = EdgeInsets.zero,
    this.useElasticAnimation = false,
  });

  /// 链式调用：创建副本并修改部分属性
  FixedTabStyleConfig copyWith({
    Color? selectedColor,
    Color? unselectedColor,
    double? selectedFontSize,
    double? unselectedFontSize,
    FontWeight? selectedFontWeight,
    FontWeight? unselectedFontWeight,
    double? indicatorWidth,
    double? indicatorHeight,
    double? indicatorBorderRadius,
    double? indicatorGap,
    Duration? animationDuration,
    Curve? animationCurve,
    EdgeInsets? padding,
    bool? useElasticAnimation,
  }) {
    return FixedTabStyleConfig(
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      selectedFontSize: selectedFontSize ?? this.selectedFontSize,
      unselectedFontSize: unselectedFontSize ?? this.unselectedFontSize,
      selectedFontWeight: selectedFontWeight ?? this.selectedFontWeight,
      unselectedFontWeight: unselectedFontWeight ?? this.unselectedFontWeight,
      indicatorWidth: indicatorWidth ?? this.indicatorWidth,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorBorderRadius: indicatorBorderRadius ?? this.indicatorBorderRadius,
      indicatorGap: indicatorGap ?? this.indicatorGap,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      padding: padding ?? this.padding,
      useElasticAnimation: useElasticAnimation ?? this.useElasticAnimation,
    );
  }

  /// 函数式：设置选中颜色
  FixedTabStyleConfig withSelectedColor(Color color) {
    return copyWith(selectedColor: color);
  }

  /// 函数式：设置未选中颜色
  FixedTabStyleConfig withUnselectedColor(Color color) {
    return copyWith(unselectedColor: color);
  }

  /// 函数式：设置字体大小
  FixedTabStyleConfig withFontSize({
    double? selected,
    double? unselected,
  }) {
    return copyWith(
      selectedFontSize: selected ?? selectedFontSize,
      unselectedFontSize: unselected ?? unselectedFontSize,
    );
  }

  /// 函数式：设置下划线宽度
  FixedTabStyleConfig withIndicatorWidth(double width) {
    return copyWith(indicatorWidth: width);
  }

  /// 函数式：设置内边距
  FixedTabStyleConfig withPadding(EdgeInsets padding) {
    return copyWith(padding: padding);
  }

  /// 函数式：启用弹性动画
  FixedTabStyleConfig withElasticAnimation() {
    return copyWith(useElasticAnimation: true);
  }
}

/// 固定标签栏组件
///
/// ## 功能特性
/// - 标签位置固定，不会横向滑动
/// - 标签均匀分布（使用 Expanded）
/// - 选中时显示下划线
/// - 支持点击切换和 PageView 滑动切换
/// - 支持粘性弹性动画（拉伸→移动→收缩）
/// - 所有样式可外部配置
///
/// ## 使用示例
/// ```dart
/// FixedTabs(
///   tabs: [
///     FixedTabItem(id: '1', title: '章节'),
///     FixedTabItem(id: '2', title: '评论'),
///     FixedTabItem(id: '3', title: '问答'),
///     FixedTabItem(id: '4', title: '笔记'),
///   ],
///   currentIndex: 0,
///   scrollPosition: 0.0,
///   onTap: (index) => print('点击: $index'),
///   styleConfig: FixedTabStyleConfig(
///     selectedColor: Colors.red,
///     unselectedColor: Colors.black,
///     useElasticAnimation: true,
///   ),
///   backgroundColor: Colors.white,
/// )
/// ```
class FixedTabs extends StatefulWidget {
  /// 标签列表
  final List<FixedTabItem> tabs;

  /// 当前选中的索引
  final int currentIndex;

  /// 滚动位置（0.0-1.0，用于粘性动画）
  final double scrollPosition;

  /// 标签点击回调
  final ValueChanged<int> onTap;

  /// 样式配置
  final FixedTabStyleConfig? styleConfig;

  /// 背景颜色
  final Color? backgroundColor;

  /// 容器内边距
  final EdgeInsets padding;

  const FixedTabs({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.scrollPosition = 0.0,
    required this.onTap,
    this.styleConfig,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<FixedTabs> createState() => _FixedTabsState();
}

class _FixedTabsState extends State<FixedTabs> {
  final Map<int, GlobalKey> _tabKeys = {};
  final GlobalKey _stackKey = GlobalKey();
  bool _isLayoutReady = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.tabs.length; i++) {
      _tabKeys[i] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLayoutReady = true;
        });
      }
    });
  }

  /// 获取指定标签的位置和宽度（相对于 Stack）
  Rect? _getTabRect(int index) {
    if (!_isLayoutReady) return null;

    final key = _tabKeys[index];
    if (key == null) return null;
    final tabContext = key.currentContext;
    if (tabContext == null) return null;

    final stackContext = _stackKey.currentContext;
    if (stackContext == null) return null;

    final tabRenderBox = tabContext.findRenderObject() as RenderBox?;
    final stackRenderBox = stackContext.findRenderObject() as RenderBox?;

    if (tabRenderBox == null || !tabRenderBox.hasSize) return null;
    if (stackRenderBox == null || !stackRenderBox.hasSize) return null;

    try {
      // 获取标签在 Stack 中的局部位置
      final position = tabRenderBox.localToGlobal(Offset.zero, ancestor: stackRenderBox);
      final size = tabRenderBox.size;
      return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    } catch (e) {
      return null;
    }
  }

  /// 计算标签的颜色（基于滚动位置的渐进式插值）
  Color _computeTabColor(int index) {
    final styleConfig = widget.styleConfig;
    if (styleConfig == null) return Colors.black;

    final currentIndex = widget.currentIndex;
    final scrollPosition = widget.scrollPosition;

    // 如果是完全选中状态（没有滚动）
    if (scrollPosition == 0.0) {
      return index == currentIndex
          ? styleConfig.selectedColor
          : styleConfig.unselectedColor;
    }

    // 确定目标标签（向右滑动）
    final targetIndex = currentIndex + 1;

    // 计算当前标签的插值进度
    double progress;
    if (index == currentIndex) {
      // 当前标签：从选中渐变到未选中
      progress = scrollPosition;
    } else if (index == targetIndex) {
      // 目标标签：从未选中渐变到选中
      progress = 1.0 - scrollPosition;
    } else {
      // 其他标签：保持未选中
      return styleConfig.unselectedColor;
    }

    // 颜色插值
    return Color.lerp(
      styleConfig.selectedColor,
      styleConfig.unselectedColor,
      progress,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final styleConfig = widget.styleConfig;
    final useElastic = styleConfig?.useElasticAnimation ?? false;

    return Container(
      color: widget.backgroundColor,
      padding: widget.padding,
      child: IntrinsicHeight(
        child: Stack(
          key: _stackKey,
          alignment: AlignmentDirectional.topStart,
          children: [
            // 标签行
            Row(
              children: List.generate(widget.tabs.length, (index) {
                final tab = widget.tabs[index];
                return Expanded(
                  key: _tabKeys[index],
                  child: GestureDetector(
                    onTap: () => widget.onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: _buildTabItem(tab, index),
                  ),
                );
              }),
            ),
            // 粘性滑动指示器
            if (useElastic && styleConfig != null)
              _buildSlidingIndicator(styleConfig),
          ],
        ),
      ),
    );
  }

  /// 构建单个标签项
  Widget _buildTabItem(FixedTabItem tab, int index) {
    final styleConfig = widget.styleConfig;
    final effectiveStyle = styleConfig ?? const FixedTabStyleConfig(
      selectedColor: Colors.red,
      unselectedColor: Colors.black,
    );
    final useElastic = styleConfig?.useElasticAnimation ?? false;

    // 计算颜色（支持粘性动画的渐进式颜色变化）
    final color = useElastic ? _computeTabColor(index) : (index == widget.currentIndex ? effectiveStyle.selectedColor : effectiveStyle.unselectedColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标签内容（文字 + 图标）
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(
                tab.icon!,
                size: effectiveStyle.selectedFontSize,
                color: color,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              tab.title,
              style: TextStyle(
                fontSize: index == widget.currentIndex
                    ? effectiveStyle.selectedFontSize
                    : effectiveStyle.unselectedFontSize,
                fontWeight: index == widget.currentIndex
                    ? effectiveStyle.selectedFontWeight
                    : effectiveStyle.unselectedFontWeight,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: effectiveStyle.indicatorGap),
        // 占位符（为指示器预留空间）
        SizedBox(height: effectiveStyle.indicatorHeight),
      ],
    );
  }

  /// 构建粘性滑动指示器
  Widget _buildSlidingIndicator(FixedTabStyleConfig styleConfig) {
    return _ElasticSlidingIndicator(
      currentIndex: widget.currentIndex,
      scrollPosition: widget.scrollPosition,
      tabKeys: _tabKeys,
      getTabRect: _getTabRect,
      config: styleConfig,
      isLayoutReady: _isLayoutReady,
    );
  }
}

/// 粘性弹性滑动指示器（内部使用）
///
/// 实现拉伸→移动→收缩的三阶段动画效果
class _ElasticSlidingIndicator extends StatelessWidget {
  final int currentIndex;
  final double scrollPosition; // 0.0 - 1.0
  final Map<int, GlobalKey> tabKeys;
  final Rect? Function(int) getTabRect;
  final FixedTabStyleConfig config;
  final bool isLayoutReady;

  const _ElasticSlidingIndicator({
    required this.currentIndex,
    required this.scrollPosition,
    required this.tabKeys,
    required this.getTabRect,
    required this.config,
    required this.isLayoutReady,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLayoutReady || scrollPosition == 0.0) {
      // 没有滚动时，显示静态指示器
      return _StaticIndicator(
        tabIndex: currentIndex,
        tabKeys: tabKeys,
        getTabRect: getTabRect,
        config: config,
      );
    }

    // 有滚动时，显示动态指示器
    final currentRect = getTabRect(currentIndex);
    final nextIndex = currentIndex + 1;
    final nextRect = getTabRect(nextIndex);

    if (currentRect == null || nextRect == null) {
      return _StaticIndicator(
        tabIndex: currentIndex,
        tabKeys: tabKeys,
        getTabRect: getTabRect,
        config: config,
      );
    }

    // 计算三阶段动画
    final fixedWidth = config.indicatorWidth;
    final currentCenter = currentRect.left + currentRect.width / 2;
    final nextCenter = nextRect.left + nextRect.width / 2;

    // 三阶段动画：拉长 → 移动 → 收缩
    double currentWidth;
    double currentPosition;

    if (scrollPosition < 0.3) {
      // 阶段1: 拉伸 (0.0 - 0.3)
      final stretchProgress = scrollPosition / 0.3;
      currentWidth = fixedWidth * (1 + stretchProgress * 0.5);
      currentPosition = currentCenter;
    } else if (scrollPosition < 0.7) {
      // 阶段2: 移动 (0.3 - 0.7)
      final moveProgress = (scrollPosition - 0.3) / 0.4;
      currentWidth = fixedWidth * 1.5;
      currentPosition = currentCenter + (nextCenter - currentCenter) * moveProgress;
    } else {
      // 阶段3: 收缩 (0.7 - 1.0)
      final shrinkProgress = (scrollPosition - 0.7) / 0.3;
      currentWidth = fixedWidth * (1.5 - shrinkProgress * 0.5);
      currentPosition = nextCenter;
    }

    return Positioned(
      left: currentPosition - currentWidth / 2,
      bottom: config.padding.bottom,
      child: Container(
        width: currentWidth,
        height: config.indicatorHeight,
        decoration: BoxDecoration(
          color: config.selectedColor,
          borderRadius: BorderRadius.circular(config.indicatorBorderRadius),
        ),
      ),
    );
  }
}

/// 静态指示器（无滚动时显示）
class _StaticIndicator extends StatelessWidget {
  final int tabIndex;
  final Map<int, GlobalKey> tabKeys;
  final Rect? Function(int) getTabRect;
  final FixedTabStyleConfig config;

  const _StaticIndicator({
    required this.tabIndex,
    required this.tabKeys,
    required this.getTabRect,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final rect = getTabRect(tabIndex);
    if (rect == null) return const SizedBox.shrink();

    final width = config.indicatorWidth;
    final center = rect.left + rect.width / 2;

    return Positioned(
      left: center - width / 2,
      bottom: config.padding.bottom,
      child: Container(
        width: width,
        height: config.indicatorHeight,
        decoration: BoxDecoration(
          color: config.selectedColor,
          borderRadius: BorderRadius.circular(config.indicatorBorderRadius),
        ),
      ),
    );
  }
}
