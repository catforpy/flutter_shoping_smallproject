library;

import 'package:flutter/material.dart';

/// 标签项数据模型
class TabItem {
  final String id;
  final String title;
  final IconData? icon;
  final Widget? customWidget;

  const TabItem({
    required this.id,
    required this.title,
    this.icon,
    this.customWidget,
  });
}

/// 横向滑动标签组件
///
/// 支持指定某个标签吸附到左侧（类似抖音首页的"推荐"标签）
class HorizontalTabs extends StatefulWidget {
  /// 标签列表
  final List<TabItem> tabs;

  /// 当前选中的索引
  final int currentIndex;

  /// 标签点击回调
  final ValueChanged<int> onTap;

  /// 要吸附在左侧的标签索引（null 表示不吸附）
  final int? pinnedTabIndex;

  /// 标签高度
  final double height;

  /// 标签间距
  final double spacing;

  /// 标签内边距
  final EdgeInsets tabPadding;

  /// 标签圆角半径
  final double borderRadius;

  /// 选中标签样式
  final TextStyle? selectedStyle;

  /// 未选中标签样式
  final TextStyle? unselectedStyle;

  /// 选中标签颜色
  final Color? selectedColor;

  /// 未选中标签颜色
  final Color? unselectedColor;

  /// 选中标签背景色
  final Color? selectedBackgroundColor;

  /// 未选中标签背景色
  final Color? unselectedBackgroundColor;

  /// 标签栏整体背景色
  final Color? backgroundColor;

  // ========== 吸顶标签独立样式配置 ==========

  /// 吸顶标签内边距（null 则使用 tabPadding）
  final EdgeInsets? pinnedTabPadding;

  /// 吸顶标签圆角半径（null 则使用 borderRadius）
  final double? pinnedBorderRadius;

  /// 吸顶标签选中文字颜色（null 则使用 selectedColor）
  final Color? pinnedSelectedColor;

  /// 吸顶标签未选中文字颜色（null 则使用 unselectedColor）
  final Color? pinnedUnselectedColor;

  /// 吸顶标签选中背景色（null 则使用 selectedBackgroundColor）
  final Color? pinnedSelectedBackgroundColor;

  /// 吸顶标签未选中背景色（null 则使用 unselectedBackgroundColor）
  final Color? pinnedUnselectedBackgroundColor;

  /// 吸顶标签边框（null 则无边框）
  final BoxBorder? pinnedBorder;

  const HorizontalTabs({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.pinnedTabIndex,
    this.height = 40,
    this.spacing = 12,
    this.tabPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.borderRadius = 20,
    this.selectedStyle,
    this.unselectedStyle,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.backgroundColor,
    // 吸顶标签独立样式
    this.pinnedTabPadding,
    this.pinnedBorderRadius,
    this.pinnedSelectedColor,
    this.pinnedUnselectedColor,
    this.pinnedSelectedBackgroundColor,
    this.pinnedUnselectedBackgroundColor,
    this.pinnedBorder,
  });

  @override
  State<HorizontalTabs> createState() => _HorizontalTabsState();
}

class _HorizontalTabsState extends State<HorizontalTabs> {
  late ScrollController _scrollController;
  bool _showPinnedTab = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// 监听滚动，判断是否需要显示固定标签
  void _onScroll() {
    if (widget.pinnedTabIndex == null) return;

    final shouldShow = _scrollController.offset > 50; // 滚动超过50像素时显示吸顶标签
    if (shouldShow != _showPinnedTab) {
      setState(() => _showPinnedTab = shouldShow);
    }
  }

  /// 获取标签文字颜色（选中/未选中）
  Color? _getTabTextColor(bool isSelected, bool isPinned) {
    if (isPinned) {
      return isSelected
          ? (widget.pinnedSelectedColor ?? widget.selectedColor)
          : (widget.pinnedUnselectedColor ?? widget.unselectedColor ?? Colors.grey);
    }
    return isSelected
        ? (widget.selectedColor ?? Theme.of(context).primaryColor)
        : (widget.unselectedColor ?? Colors.grey);
  }

  /// 获取标签背景色（选中/未选中）
  Color? _getTabBackgroundColor(bool isSelected, bool isPinned) {
    if (isPinned) {
      return isSelected
          ? (widget.pinnedSelectedBackgroundColor ?? widget.selectedBackgroundColor)
          : (widget.pinnedUnselectedBackgroundColor ?? widget.unselectedBackgroundColor);
    }
    return isSelected
        ? widget.selectedBackgroundColor
        : widget.unselectedBackgroundColor;
  }

  /// 构建标签文字样式
  TextStyle _buildTabTextStyle(bool isSelected, bool isPinned) {
    // 吸顶标签使用自己的样式，普通标签使用默认样式
    final style = isSelected ? widget.selectedStyle : widget.unselectedStyle;

    return style ??
        TextStyle(
          fontSize: isSelected ? 16 : 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        );
  }

  /// 构建标签图标
  Widget? _buildTabIcon(IconData? icon, bool isSelected, bool isPinned) {
    if (icon == null) return null;
    return Icon(
      icon,
      size: 16,
      color: _getTabTextColor(isSelected, isPinned),
    );
  }

  /// 构建标签内容行（图标 + 文字）
  Widget _buildTabContentRow(TabItem tab, bool isSelected, bool isPinned) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_buildTabIcon(tab.icon, isSelected, isPinned) != null) ...[
          _buildTabIcon(tab.icon, isSelected, isPinned)!,
          SizedBox(width: 4), // 图标和文字之间的间距
        ],
        Text(
          tab.title,
          style: _buildTabTextStyle(isSelected, isPinned).copyWith(
            color: _getTabTextColor(isSelected, isPinned),
          ),
        ),
      ],
    );
  }

  /// 构建标签装饰（背景色 + 圆角 + 边框）
  BoxDecoration _buildTabDecoration(bool isSelected, bool isPinned) {
    return BoxDecoration(
      color: _getTabBackgroundColor(isSelected, isPinned),
      borderRadius: BorderRadius.circular(isPinned ? (widget.pinnedBorderRadius ?? widget.borderRadius) : widget.borderRadius),
      border: isPinned ? widget.pinnedBorder : null,
    );
  }

  /// 构建标签容器（装饰 + 内容）
  Widget _buildTabContainer({required Widget child, required bool isSelected, required bool isPinned}) {
    return Container(
      padding: isPinned ? (widget.pinnedTabPadding ?? widget.tabPadding) : widget.tabPadding,
      height: widget.height,
      decoration: _buildTabDecoration(isSelected, isPinned),
      child: child,
    );
  }

  /// 构建普通标签（非吸顶）
  Widget _buildNormalTab(TabItem tab, int index) {
    final isSelected = widget.currentIndex == index;
    final content = _buildTabContentRow(tab, isSelected, false);

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: _buildTabContainer(child: content, isSelected: isSelected, isPinned: false),
    );
  }

  /// 构建吸顶标签（独立样式）
  Widget _buildPinnedTab() {
    final pinnedIndex = widget.pinnedTabIndex!;
    if (pinnedIndex < 0 || pinnedIndex >= widget.tabs.length) {
      return SizedBox.shrink();
    }

    final tab = widget.tabs[pinnedIndex];
    final isSelected = widget.currentIndex == pinnedIndex;
    final content = _buildTabContentRow(tab, isSelected, true);

    return Container(
      padding: EdgeInsets.only(left: 16, right: widget.spacing / 2), // 吸顶标签的外边距
      height: widget.height,
      child: GestureDetector(
        onTap: () => widget.onTap(pinnedIndex),
        child: _buildTabContainer(child: content, isSelected: isSelected, isPinned: true),
      ),
    );
  }

  /// 构建可滑动标签列表
  Widget _buildScrollableTabs() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: _showPinnedTab ? widget.spacing / 2 : 16, // 根据是否显示吸顶标签调整左右边距
        ),
        itemCount: widget.tabs.length,
        itemBuilder: (context, index) {
          // 如果显示吸顶标签，跳过该索引
          if (_showPinnedTab && index == widget.pinnedTabIndex) {
            return SizedBox.shrink();
          }

          return Padding(
            padding: EdgeInsets.only(right: widget.spacing), // 标签之间的间距
            child: _buildNormalTab(widget.tabs[index], index),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      child: Row(
        children: [
          // 固定标签（条件显示）
          if (_showPinnedTab && widget.pinnedTabIndex != null)
            _buildPinnedTab(),
          // 可滑动标签区域
          _buildScrollableTabs(),
        ],
      ),
    );
  }
}
