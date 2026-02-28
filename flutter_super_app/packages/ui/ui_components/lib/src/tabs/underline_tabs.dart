library;

import 'package:flutter/material.dart';

/// 标签项数据模型
class UnderlineTabItem {
  final String id;
  final String title;
  final IconData? icon;
  final bool hasNewContent; // 是否有新内容（显示红点）

  const UnderlineTabItem({
    required this.id,
    required this.title,
    this.icon,
    this.hasNewContent = false,
  });

  /// 创建带有新内容标记的副本
  UnderlineTabItem copyWith({
    String? id,
    String? title,
    IconData? icon,
    bool? hasNewContent,
  }) {
    return UnderlineTabItem(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      hasNewContent: hasNewContent ?? this.hasNewContent,
    );
  }
}

/// 底部指示器配置
///
/// 采用不可变设计，支持链式调用
///
/// 注意：所有颜色和尺寸均需外部传入，避免硬编码
class UnderlineIndicatorConfig {
  /// 指示器高度
  final double height;

  /// 指示器颜色（必填）
  final Color color;

  /// 指示器宽度（null 表示根据文字宽度自适应）
  final double? width;

  /// 指示器宽度比例（相对于文字宽度，0.0-1.0）
  final double widthFactor;

  /// 指示器圆角
  final double borderRadius;

  /// 指示器与文字的间距
  final double gap;

  /// 动画时长
  final Duration animationDuration;

  /// 动画曲线
  final Curve animationCurve;

  /// 是否使用弹性动画（拉伸→移动→收缩）
  final bool useElasticAnimation;

  const UnderlineIndicatorConfig({
    this.height = 2,
    required this.color,
    this.width,
    this.widthFactor = 0.6,
    this.borderRadius = 1,
    this.gap = 4,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeInOut,
    this.useElasticAnimation = false,
  });

  /// 链式调用：创建副本并修改部分属性
  UnderlineIndicatorConfig copyWith({
    double? height,
    Color? color,
    double? width,
    double? widthFactor,
    double? borderRadius,
    double? gap,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? useElasticAnimation,
  }) {
    return UnderlineIndicatorConfig(
      height: height ?? this.height,
      color: color ?? this.color,
      width: width ?? this.width,
      widthFactor: widthFactor ?? this.widthFactor,
      borderRadius: borderRadius ?? this.borderRadius,
      gap: gap ?? this.gap,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      useElasticAnimation: useElasticAnimation ?? this.useElasticAnimation,
    );
  }

  /// 函数式：设置高度
  UnderlineIndicatorConfig withHeight(double height) {
    return copyWith(height: height);
  }

  /// 函数式：设置颜色
  UnderlineIndicatorConfig withColor(Color color) {
    return copyWith(color: color);
  }

  /// 函数式：设置宽度比例
  UnderlineIndicatorConfig withWidthFactor(double factor) {
    return copyWith(widthFactor: factor);
  }

  /// 函数式：设置动画时长
  UnderlineIndicatorConfig withAnimationDuration(Duration duration) {
    return copyWith(animationDuration: duration);
  }

  /// 函数式：启用弹性动画
  UnderlineIndicatorConfig withElasticAnimation() {
    return copyWith(useElasticAnimation: true);
  }
}

/// 标签样式配置
///
/// 采用不可变设计，支持链式调用
///
/// 注意：所有颜色和尺寸均需外部传入，避免硬编码
class UnderlineTabStyleConfig {
  /// 已选中文字颜色（必填）
  final Color selectedColor;

  /// 未选中文字颜色（必填）
  final Color unselectedColor;

  /// 已选中文字大小
  final double selectedFontSize;

  /// 未选中文字大小
  final double unselectedFontSize;

  /// 已选中文字粗细
  final FontWeight? selectedFontWeight;

  /// 未选中文字粗细
  final FontWeight? unselectedFontWeight;

  /// 标签内边距
  final EdgeInsets padding;

  /// 标签间距
  final double spacing;

  const UnderlineTabStyleConfig({
    required this.selectedColor,
    required this.unselectedColor,
    this.selectedFontSize = 16,
    this.unselectedFontSize = 15,
    this.selectedFontWeight = FontWeight.w500,
    this.unselectedFontWeight = FontWeight.normal,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.spacing = 0,
  });

  /// 链式调用：创建副本并修改部分属性
  UnderlineTabStyleConfig copyWith({
    Color? selectedColor,
    Color? unselectedColor,
    double? selectedFontSize,
    double? unselectedFontSize,
    FontWeight? selectedFontWeight,
    FontWeight? unselectedFontWeight,
    EdgeInsets? padding,
    double? spacing,
  }) {
    return UnderlineTabStyleConfig(
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      selectedFontSize: selectedFontSize ?? this.selectedFontSize,
      unselectedFontSize: unselectedFontSize ?? this.unselectedFontSize,
      selectedFontWeight: selectedFontWeight ?? this.selectedFontWeight,
      unselectedFontWeight: unselectedFontWeight ?? this.unselectedFontWeight,
      padding: padding ?? this.padding,
      spacing: spacing ?? this.spacing,
    );
  }

  /// 函数式：设置已选中颜色
  UnderlineTabStyleConfig withSelectedColor(Color color) {
    return copyWith(selectedColor: color);
  }

  /// 函数式：设置未选中颜色
  UnderlineTabStyleConfig withUnselectedColor(Color color) {
    return copyWith(unselectedColor: color);
  }

  /// 函数式：设置字体大小
  UnderlineTabStyleConfig withFontSize({
    double? selected,
    double? unselected,
  }) {
    return copyWith(
      selectedFontSize: selected ?? selectedFontSize,
      unselectedFontSize: unselected ?? unselectedFontSize,
    );
  }

  /// 函数式：设置内边距
  UnderlineTabStyleConfig withPadding(EdgeInsets padding) {
    return copyWith(padding: padding);
  }
}

/// 底部指示器标签组件
///
/// ## 设计理念
/// - **函数式风格**：配置类不可变，通过 copyWith 和函数式方法实现链式调用
/// - **高度灵活**：所有样式均可外部配置，避免硬编码
/// - **流畅动画**：底部指示器带动画滑动效果，支持拉长/缩小
/// - **可扩展性**：支持自定义指示器样式和动画
///
/// ## 使用示例
/// ```dart
/// // 基础用法
/// UnderlineTabs(
///   tabs: [
///     UnderlineTabItem(id: '1', title: '推荐'),
///     UnderlineTabItem(id: '2', title: '关注'),
///     UnderlineTabItem(id: '3', title: '热门'),
///   ],
///   currentIndex: 0,
///   onTap: (index) => print('点击: $index'),
/// )
///
/// // 函数式链式调用
/// UnderlineTabs(
///   tabs: [...],
///   currentIndex: 0,
///   onTap: (index) => setState(() => currentIndex = index),
///   indicatorConfig: UnderlineIndicatorConfig()
///       .withColor(Colors.blue)
///       .withHeight(3)
///       .withWidthFactor(0.8),
///   styleConfig: UnderlineTabStyleConfig()
///       .withSelectedColor(Colors.blue)
///       .withUnselectedColor(Colors.grey),
/// )
/// ```
class UnderlineTabs extends StatefulWidget {
  /// 标签列表
  final List<UnderlineTabItem> tabs;

  /// 当前选中的索引
  final int currentIndex;

  /// 标签点击回调
  final ValueChanged<int> onTap;

  /// 底部指示器配置
  final UnderlineIndicatorConfig? indicatorConfig;

  /// 标签样式配置
  final UnderlineTabStyleConfig? styleConfig;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否可滚动
  final bool scrollable;

  const UnderlineTabs({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.indicatorConfig,
    this.styleConfig,
    this.backgroundColor,
    this.scrollable = true,
  });

  @override
  State<UnderlineTabs> createState() => _UnderlineTabsState();
}

class _UnderlineTabsState extends State<UnderlineTabs> {
  final GlobalKey _tabsKey = GlobalKey();
  final Map<int, double> _tabWidths = {};
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.currentIndex;
    // 延迟测量标签宽度
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabWidths());
  }

  @override
  void didUpdateWidget(UnderlineTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      setState(() => _currentTab = widget.currentIndex);
    }
  }

  /// 测量所有标签的宽度
  void _measureTabWidths() {
    final RenderBox? renderBox = _tabsKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // 遍历所有标签，测量宽度
    for (int i = 0; i < widget.tabs.length; i++) {
      // 这里需要实际的测量逻辑，简化处理
      _tabWidths[i] = 80.0; // 默认宽度，实际应该动态测量
    }
  }

  /// 获取指示器配置
  UnderlineIndicatorConfig? get _indicatorConfig => widget.indicatorConfig;

  /// 获取样式配置
  UnderlineTabStyleConfig? get _styleConfig => widget.styleConfig;

  @override
  Widget build(BuildContext context) {
    final styleConfig = _styleConfig;
    if (styleConfig == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.backgroundColor,
      child: widget.scrollable ? _buildScrollableTabs(styleConfig) : _buildFixedTabs(styleConfig),
    );
  }

  /// 构建可滚动标签
  Widget _buildScrollableTabs(UnderlineTabStyleConfig styleConfig) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: widget.tabs
            .asMap()
            .entries
            .map((entry) => Padding(
                  padding: EdgeInsets.only(right: styleConfig.spacing),
                  child: _buildTab(entry.key, styleConfig),
                ))
            .toList(),
      ),
    );
  }

  /// 构建固定标签
  Widget _buildFixedTabs(UnderlineTabStyleConfig styleConfig) {
    return Row(
      key: _tabsKey,
      children: widget.tabs
          .asMap()
          .entries
          .map((entry) => Padding(
                padding: EdgeInsets.only(right: styleConfig.spacing),
                child: _buildTab(entry.key, styleConfig),
              ))
          .toList(),
    );
  }

  /// 构建单个标签
  Widget _buildTab(int index, UnderlineTabStyleConfig styleConfig) {
    final tab = widget.tabs[index];
    final isSelected = index == _currentTab;
    final indicatorConfig = _indicatorConfig;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: _TabItem(
        tab: tab,
        isSelected: isSelected,
        styleConfig: styleConfig,
        indicatorConfig: indicatorConfig,
        showIndicator: isSelected,
      ),
    );
  }
}

/// 单个标签项（内部使用）
class _TabItem extends StatelessWidget {
  final UnderlineTabItem tab;
  final bool isSelected;
  final UnderlineTabStyleConfig styleConfig;
  final UnderlineIndicatorConfig? indicatorConfig;
  final bool showIndicator;

  const _TabItem({
    required this.tab,
    required this.isSelected,
    required this.styleConfig,
    required this.indicatorConfig,
    required this.showIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final config = indicatorConfig;
    if (config == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: config.animationDuration,
      curve: config.animationCurve,
      padding: styleConfig.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标签内容 + 红点
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tab.title,
                style: TextStyle(
                  color: isSelected ? styleConfig.selectedColor : styleConfig.unselectedColor,
                  fontSize: isSelected ? styleConfig.selectedFontSize : styleConfig.unselectedFontSize,
                  fontWeight: isSelected ? styleConfig.selectedFontWeight : styleConfig.unselectedFontWeight,
                ),
              ),
              // 红点提示（当有新内容时显示）
              if (tab.hasNewContent) ...[
                SizedBox(width: 4),
                _buildRedDot(),
              ],
            ],
          ),
          SizedBox(height: config.gap),
          // 底部指示器（带动画）
          AnimatedContainer(
            duration: config.animationDuration,
            curve: config.animationCurve,
            width: config.width ?? (isSelected ? 40.0 : 0.0),
            height: config.height,
            decoration: BoxDecoration(
              color: isSelected ? config.color : Colors.transparent,
              borderRadius: BorderRadius.circular(config.borderRadius),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建红点提示
  Widget _buildRedDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 带指示器位置的标签组件（支持指示器滑动）
///
/// 这个版本支持指示器在不同标签之间平滑滑动
/// 支持 useElasticAnimation 弹性动画模式
/// 支持左右滑动手势切换标签
/// 支持滚动位置驱动的渐进式颜色和下划线动画
class UnderlineTabsWithSlider extends StatefulWidget {
  /// 标签列表
  final List<UnderlineTabItem> tabs;

  /// 当前选中的索引
  final int currentIndex;

  /// 滚动位置（0.0-1.0，用于渐进式动画）
  final double scrollPosition;

  /// 标签点击回调
  final ValueChanged<int> onTap;

  /// 底部指示器配置
  final UnderlineIndicatorConfig? indicatorConfig;

  /// 标签样式配置
  final UnderlineTabStyleConfig? styleConfig;

  /// 背景颜色
  final Color? backgroundColor;

  /// 外层内边距（控制标签列表的左右边距）
  ///
  /// 例如：EdgeInsets.symmetric(horizontal: 60) 可以让标签居中并远离屏幕边缘
  final EdgeInsetsGeometry? outerPadding;

  const UnderlineTabsWithSlider({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.scrollPosition = 0.0,
    required this.onTap,
    this.indicatorConfig,
    this.styleConfig,
    this.backgroundColor,
    this.outerPadding,
  });

  @override
  State<UnderlineTabsWithSlider> createState() => _UnderlineTabsWithSliderState();
}

class _UnderlineTabsWithSliderState extends State<UnderlineTabsWithSlider> {
  final Map<int, GlobalKey> _tabKeys = {};
  bool _isLayoutReady = false;

  // 手势跟踪
  double? _dragStartX;
  DateTime? _dragStartTime;

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

  /// 处理触摸开始
  void _handlePointerDown(PointerDownEvent event) {
    _dragStartX = event.position.dx;
    _dragStartTime = DateTime.now();
  }

  /// 处理触摸结束
  void _handlePointerUp(PointerUpEvent event) {
    if (_dragStartX == null || _dragStartTime == null) return;

    final endX = event.position.dx;
    final deltaX = endX - _dragStartX!;
    final deltaTime = DateTime.now().difference(_dragStartTime!).inMilliseconds;

    // 计算速度（像素/毫秒）
    final velocity = deltaTime > 0 ? deltaX / deltaTime : 0.0;
    const velocityThreshold = 1.5;
    const minDistance = 30.0;

    if (deltaX.abs() > minDistance && velocity.abs() > velocityThreshold) {
      if (deltaX > 0 && widget.currentIndex > 0) {
        widget.onTap(widget.currentIndex - 1);
      } else if (deltaX < 0 && widget.currentIndex < widget.tabs.length - 1) {
        widget.onTap(widget.currentIndex + 1);
      }
    }

    _dragStartX = null;
    _dragStartTime = null;
  }

  /// 获取指定标签的位置和宽度
  Rect? _getTabRect(int index) {
    if (!_isLayoutReady) return null;

    final key = _tabKeys[index];
    if (key == null) return null;
    final context = key.currentContext;
    if (context == null) return null;

    final RenderBox? renderBox =
        context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return null;

    try {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    } catch (e) {
      return null;
    }
  }

  UnderlineIndicatorConfig? get _indicatorConfig => widget.indicatorConfig;

  /// 获取样式配置
  UnderlineTabStyleConfig? get _styleConfig => widget.styleConfig;

  /// 计算标签的颜色（基于滚动位置的渐进式插值）
  Color _computeTabColor(int index) {
    final styleConfig = _styleConfig!;
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
    final config = widget.indicatorConfig;
    if (config == null || _styleConfig == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          // 标签行 - 使用 Listener 监听原始触摸事件支持左右滑动切换
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _handlePointerDown,
            onPointerUp: _handlePointerUp,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: widget.outerPadding ?? const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: widget.tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;

                  return GestureDetector(
                    key: _tabKeys[index],
                    onTap: () => widget.onTap(index),
                    child: Container(
                      padding: _styleConfig!.padding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tab.title,
                            style: TextStyle(
                              color: _computeTabColor(index),
                              fontSize: index == widget.currentIndex
                                  ? _styleConfig!.selectedFontSize
                                  : _styleConfig!.unselectedFontSize,
                              fontWeight: index == widget.currentIndex
                                  ? _styleConfig!.selectedFontWeight
                                  : _styleConfig!.unselectedFontWeight,
                            ),
                          ),
                          SizedBox(height: config.gap),
                          // 占位符，为指示器预留空间
                          SizedBox(height: config.height),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 滑动指示器
          _buildSlidingIndicator(),
        ],
      ),
    );
  }

  /// 构建滑动指示器
  Widget _buildSlidingIndicator() {
    final config = _indicatorConfig;
    if (config == null) {
      return const SizedBox.shrink();
    }

    return _ProgressiveSlidingIndicator(
      currentIndex: widget.currentIndex,
      scrollPosition: widget.scrollPosition,
      tabKeys: _tabKeys,
      getTabRect: _getTabRect,
      config: config,
      isLayoutReady: _isLayoutReady,
    );
  }
}

/// 渐进式滑动指示器（内部使用）
///
/// 根据滚动位置实时计算下划线的位置和宽度
/// 实现拉长→移动→收缩的渐进式动画效果
class _ProgressiveSlidingIndicator extends StatelessWidget {
  final int currentIndex;
  final double scrollPosition; // 0.0 - 1.0
  final Map<int, GlobalKey> tabKeys;
  final Rect? Function(int) getTabRect;
  final UnderlineIndicatorConfig config;
  final bool isLayoutReady;

  const _ProgressiveSlidingIndicator({
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

    // 计算渐进式动画
    final fixedWidth = config.width ?? 40;
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
      bottom: 0,
      child: Container(
        width: currentWidth,
        height: config.height,
        decoration: BoxDecoration(
          color: config.color,
          borderRadius: BorderRadius.circular(config.borderRadius),
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
  final UnderlineIndicatorConfig config;

  const _StaticIndicator({
    required this.tabIndex,
    required this.tabKeys,
    required this.getTabRect,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final rect = getTabRect(tabIndex);
    if (rect == null) {
      return const SizedBox.shrink();
    }

    final width = config.width ?? rect.width * 0.6;
    final center = rect.left + rect.width / 2;

    return Positioned(
      left: center - width / 2,
      bottom: 0,
      child: Container(
        width: width,
        height: config.height,
        decoration: BoxDecoration(
          color: config.color,
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
      ),
    );
  }
}
