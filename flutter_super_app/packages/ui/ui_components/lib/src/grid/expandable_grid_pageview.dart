library;

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';

/// 可展开的网格轮播组件
///
/// ## 功能特性
/// - 类似轮播图的滑动效果
/// - 第一页显示1行，第二页显示3行（可配置）
/// - **动态高度动画**：滑动时组件高度平滑过渡
/// - 组件高度自动计算
/// - 支持自定义"全部频道"入口
/// - 底部轮播指示点
///
/// ## 示例用法
/// ```dart
/// ExpandableGridPageView(
///   children: [
///     _buildCategoryItem('推荐', Icons.recommend),
///     _buildCategoryItem('新人补贴', Icons.card_giftcard),
///     // ... 更多widget
///   ],
///   onTap: (index) {
///     print('点击了 $index');
///   },
///   onMoreTap: () {
///     print('查看全部频道');
///   },
/// )
/// ```
class ExpandableGridPageView extends StatefulWidget {
  /// 子widget列表
  final List<Widget> children;

  /// 每行显示的widget数量（默认5）
  final int crossAxisCount;

  /// 第一页显示的行数（默认1）
  final int firstPageRows;

  /// 第二页显示的行数（默认3）
  final int secondPageRows;

  /// 组件顶部内边距
  final double topPadding;

  /// 组件底部内边距
  final double bottomPadding;

  /// widget之间的水平间距
  final double spacing;

  /// widget之间的垂直间距
  final double runSpacing;

  /// "全部频道"widget（null时使用默认样式）
  final Widget? moreIndicator;

  /// 是否显示底部指示点（默认true）
  final bool showIndicator;

  /// 指示点颜色
  final Color indicatorColor;

  /// 当前指示点颜色
  final Color currentIndicatorColor;

  /// widget点击回调
  final ValueChanged<int>? onTap;

  /// "全部频道"点击回调
  final VoidCallback? onMoreTap;

  /// 高度动画时长（默认300ms）
  final Duration animationDuration;

  /// 高度动画曲线
  final Curve animationCurve;

  const ExpandableGridPageView({
    super.key,
    required this.children,
    this.crossAxisCount = 5,
    this.firstPageRows = 1,
    this.secondPageRows = 3,
    this.topPadding = 16,
    this.bottomPadding = 16,
    this.spacing = 12,
    this.runSpacing = 12,
    this.moreIndicator,
    this.showIndicator = true,
    this.indicatorColor = Colors.grey,
    this.currentIndicatorColor = Colors.red,
    this.onTap,
    this.onMoreTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<ExpandableGridPageView> createState() => _ExpandableGridPageViewState();
}

class _ExpandableGridPageViewState extends State<ExpandableGridPageView> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _calculatePages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 计算总页数
  void _calculatePages() {
    final totalWidgets = widget.children.length;
    final firstPageCount = widget.crossAxisCount * widget.firstPageRows;
    final secondPageCount = widget.crossAxisCount * widget.secondPageRows;

    if (totalWidgets <= firstPageCount) {
      _totalPages = 1;
    } else if (totalWidgets <= firstPageCount + secondPageCount) {
      _totalPages = 2;
    } else {
      _totalPages = 2;
    }
  }

  /// 计算第一页显示的widget数量
  int _getFirstPageCount() {
    final totalWidgets = widget.children.length;
    final firstPageMax = widget.crossAxisCount * widget.firstPageRows;

    if (totalWidgets <= firstPageMax) {
      return totalWidgets;
    }
    // 显示5+半个（用6个表示，最后一个被遮挡一半）
    return firstPageMax + 1;
  }

  /// 计算第二页显示的widget数量
  int _getSecondPageCount() {
    final totalWidgets = widget.children.length;
    final firstPageMax = widget.crossAxisCount * widget.firstPageRows;
    final secondPageMax = widget.crossAxisCount * widget.secondPageRows;

    if (totalWidgets > firstPageMax + secondPageMax) {
      // 超过20个，第二页最后一个显示"全部频道"
      return secondPageMax + 1;
    }
    // 不超过20个，显示剩余的widget
    return totalWidgets - firstPageMax;
  }

  /// 计算第一页的高度
  double _calculateFirstPageHeight(double itemHeight) {
    return widget.topPadding +
        (itemHeight * widget.firstPageRows) +
        (widget.runSpacing * (widget.firstPageRows - 1)) +
        widget.bottomPadding;
  }

  /// 计算第二页的高度
  double _calculateSecondPageHeight(double itemHeight) {
    final displayCount = _getSecondPageCount();
    final rows = (displayCount / widget.crossAxisCount).ceil();

    return widget.topPadding +
        (itemHeight * rows) +
        (widget.runSpacing * (rows - 1)) +
        widget.bottomPadding +
        (widget.showIndicator ? 30 : 0); // 指示点的高度
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有widget，返回空容器
    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    // 如果只有1页，直接显示网格
    if (_totalPages == 1) {
      return _buildSinglePage();
    }

    // 多页，使用PageView
    return _buildPageView();
  }

  /// 构建单页网格
  Widget _buildSinglePage() {
    return Container(
      color: Colors.white,
      child: _buildGrid(
        widget.children,
        widget.children.length,
      ),
    );
  }

  /// 构建多页PageView（使用 ExpandablePageView 实现高度自适应）
  Widget _buildPageView() {
    return ExpandablePageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: [
        _buildFirstPage(),
        _buildSecondPage(),
      ],
    );
  }

  /// 构建第一页
  Widget _buildFirstPage() {
    final displayCount = _getFirstPageCount();
    final displayWidgets = widget.children.take(displayCount).toList();
    final firstPageHeight = _calculateFirstPageHeight(80);

    return Container(
      color: Colors.white,
      height: firstPageHeight,
      child: _buildGrid(displayWidgets, displayCount),
    );
  }

  /// 构建第二页
  Widget _buildSecondPage() {
    final firstPageMax = widget.crossAxisCount * widget.firstPageRows;
    final secondPageCount = _getSecondPageCount();

    List<Widget> displayWidgets = [];

    if (widget.children.length > firstPageMax + (widget.crossAxisCount * widget.secondPageRows)) {
      // 超过20个，第二页显示第6-20个 + "全部频道"
      final startIndex = firstPageMax;
      final endIndex = firstPageMax + (widget.crossAxisCount * widget.secondPageRows);
      displayWidgets = widget.children.sublist(startIndex, endIndex);
      displayWidgets.add(_buildMoreIndicator());
    } else {
      // 不超过20个，显示剩余widget
      displayWidgets = widget.children.sublist(firstPageMax);
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 网格内容
          _buildGrid(displayWidgets, secondPageCount),

          // 底部指示点
          if (widget.showIndicator)
            _buildIndicator(),
        ],
      ),
    );
  }

  /// 构建网格
  Widget _buildGrid(List<Widget> children, int displayCount) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: widget.topPadding,
        bottom: widget.bottomPadding,
      ),
      child: GridView.count(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.runSpacing,
        crossAxisSpacing: widget.spacing,
        childAspectRatio: 1.0,
        physics: const NeverScrollableScrollPhysics(), // 禁用GridView滚动
        shrinkWrap: true,
        children: List.generate(
          displayCount,
          (index) {
            if (index < children.length) {
              return GestureDetector(
                onTap: () {
                  if (widget.onTap != null) {
                    // 计算实际索引
                    final actualIndex = _getActualIndex(index);
                    if (actualIndex != -1) {
                      widget.onTap!(actualIndex);
                    } else {
                      // "全部频道"
                      widget.onMoreTap?.call();
                    }
                  }
                },
                child: children[index],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// 计算widget的实际索引
  int _getActualIndex(int pageIndex) {
    final firstPageMax = widget.crossAxisCount * widget.firstPageRows;

    if (_currentPageIndex == 0) {
      return pageIndex;
    } else {
      // 第二页
      if (widget.children.length > firstPageMax + (widget.crossAxisCount * widget.secondPageRows)) {
        // 超过20个，最后一个索引返回-1表示"全部频道"
        if (pageIndex == (widget.crossAxisCount * widget.secondPageRows)) {
          return -1;
        }
      }
      return firstPageMax + pageIndex;
    }
  }

  /// 构建"全部频道"指示器
  Widget _buildMoreIndicator() {
    if (widget.moreIndicator != null) {
      return widget.moreIndicator!;
    }

    // 默认样式：Icon + 文字
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.apps,
          size: 24,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          '全部频道',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建底部指示点
  Widget _buildIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _totalPages,
          (index) {
            final isCurrent = index == _currentPageIndex;
            return Container(
              width: isCurrent ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isCurrent
                    ? widget.currentIndicatorColor
                    : widget.indicatorColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        ),
      ),
    );
  }
}
