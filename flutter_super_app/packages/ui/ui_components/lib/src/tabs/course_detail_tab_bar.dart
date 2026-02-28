library;

import 'package:flutter/material.dart';
import 'underline_tabs.dart';

/// 课程详情页专用吸顶标签栏
///
/// 基于 UnderlineTabsWithSlider，添加课程详情页专用的样式：
/// - 容器上面两个角圆角（左上、右上）
/// - 纯白色背景（无毛玻璃效果）
/// - 标签居中显示（通过较大的左右边距实现）
/// - 复用下划线弹性动画
/// - 内置 PageController 监听，实时更新动画（避免 Provider 延迟）
///
/// ## 功能特性
/// - 上面两个角圆角（16px）
/// - 纯白色背景，无毛玻璃效果
/// - 标签居中（左右各 60px 边距）
/// - 标签之间间距合理（24px）
/// - 复用 UnderlineTabsWithSlider 的下划线动画
/// - 实时监听 PageController，零延迟动画更新
///
/// ## 示例用法
/// ```dart
/// CourseDetailTabBar(
///   tabs: [
///     UnderlineTabItem(id: '0', title: '简介'),
///     UnderlineTabItem(id: '1', title: '目录'),
///     UnderlineTabItem(id: '2', title: '评价'),
///     UnderlineTabItem(id: '3', title: '推荐'),
///   ],
///   pageController: _pageController,
///   onTap: (index) {
///     _pageController.animateToPage(index);
///   },
/// )
/// ```
class CourseDetailTabBar extends StatefulWidget {
  /// 标签列表
  final List<UnderlineTabItem> tabs;

  /// PageView 控制器（必须传入，用于实时监听滚动）
  final PageController pageController;

  /// 标签点击回调
  final ValueChanged<int> onTap;

  /// 容器高度
  final double height;

  /// 容器上面两个角的圆角半径
  final double topBorderRadius;

  /// 容器背景透明度
  ///
  /// 默认值：1.0（完全不透明）
  final double backgroundOpacity;

  /// 标签左右外边距（用于实现居中效果）
  ///
  /// 默认值：60px
  final double horizontalMargin;

  /// 标签是否居中显示
  final bool centerTabs;

  /// 下划线配置
  final UnderlineIndicatorConfig? indicatorConfig;

  /// 标签样式配置
  final UnderlineTabStyleConfig? styleConfig;

  const CourseDetailTabBar({
    super.key,
    required this.tabs,
    required this.pageController,
    required this.onTap,
    this.height = 50,
    this.topBorderRadius = 16,
    this.backgroundOpacity = 1.0,
    this.horizontalMargin = 0,
    this.centerTabs = false,
    this.indicatorConfig,
    this.styleConfig,
  });

  @override
  State<CourseDetailTabBar> createState() => _CourseDetailTabBarState();
}

class _CourseDetailTabBarState extends State<CourseDetailTabBar> {
  /// 当前选中的标签索引
  int _currentIndex = 0;

  /// 滚动位置（0.0-1.0，实时更新）
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    // 立即添加监听器，实时更新动画
    widget.pageController.addListener(_onPageViewScroll);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageViewScroll);
    super.dispose();
  }

  /// 监听 PageView 滚动，实时更新动画状态（零延迟）
  void _onPageViewScroll() {
    if (!widget.pageController.hasClients || widget.tabs.isEmpty) return;

    final page = widget.pageController.page;
    if (page == null) return;

    final index = page.floor();
    final position = page - index;

    // 只在值真正变化时才 setState，减少不必要的重建
    if (index != _currentIndex || (_scrollPosition - position).abs() > 0.001) {
      setState(() {
        _currentIndex = index;
        _scrollPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 直接返回 UnderlineTabsWithSlider，和首页保持一致
    // 需要白色背景和圆角，用 Container 包裹
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: widget.backgroundOpacity),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.topBorderRadius),
          topRight: Radius.circular(widget.topBorderRadius),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: _buildTabs(),
    );
  }

  /// 构建标签
  Widget _buildTabs() {
    final tabsWidget = UnderlineTabsWithSlider(
      tabs: widget.tabs,
      currentIndex: _currentIndex,
      scrollPosition: _scrollPosition,
      onTap: widget.onTap,
      indicatorConfig: widget.indicatorConfig ??
          const UnderlineIndicatorConfig(
            color: Colors.red,
            width: 40,
            height: 3,
            useElasticAnimation: true,
          ),
      styleConfig: widget.styleConfig ??
          const UnderlineTabStyleConfig(
            selectedColor: Colors.red,
            unselectedColor: Colors.black,
            selectedFontSize: 17,
            unselectedFontSize: 15,
            selectedFontWeight: FontWeight.bold,
            unselectedFontWeight: FontWeight.normal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            spacing: 12,
          ),
      backgroundColor: Colors.transparent,
    );

    // 如果需要居中，用 Row + Spacer 包裹
    if (widget.centerTabs) {
      return Row(
        children: [
          const Spacer(),
          Expanded(child: tabsWidget),
          const Spacer(),
        ],
      );
    }
    return tabsWidget;
  }
}
