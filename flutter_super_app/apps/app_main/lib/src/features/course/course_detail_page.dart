library;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_ui/core_ui.dart';
import 'package:ui_components/ui_components.dart';
import 'tabs/tabs.dart';
import 'free_course_play_page.dart';
import 'providers/course_detail_provider.dart';

/// 课程详情页
///
/// ## 整体架构
/// - Scaffold + Stack 布局
/// - 底层：固定的全屏背景图（不滚动）
/// - 顶层：CustomScrollView（可滚动内容）
///   - SliverToBoxAdapter: 标题区域（280px，带滚动动画）
///   - SliverPersistentHeader: 吸顶标签栏（4个标签）
///   - SliverToBoxAdapter: PageView（标签内容）
///
/// ## 功能特性
/// - **透明导航栏**：初始完全透明，滚动后逐渐显示毛玻璃效果
/// - **标题区域**：背景图 + 毛玻璃 + 标题文字
/// - **标题滚动动画**：向上滑动 + 淡出
/// - **导航栏标题**：淡入效果
/// - **吸顶标签**：4个横向滑动标签（简介、目录、评价、推荐）
/// - **标签容器**：纯白色背景，无毛玻璃效果，上面两个角圆角
/// - **下划线动画**：复用首页的下划线滑动效果
///
/// ## 滚动效果详解
/// 滚动进度: 0.0 → 1.0（基于滚动偏移量 / 标题区域高度）
///
/// 标题区域动画：
/// - Transform.translate: 向上滑动 (translateY: -scrollProgress * 50)
/// - Opacity: 渐变淡出 (opacity: 1 - scrollProgress)
/// - 毛玻璃背景：不淡出，始终显示
///
/// 导航栏动画：
/// - 标题淡入: opacity: scrollProgress
/// - 毛玻璃渐显: sigmaX/Y * scrollProgress
///
/// ## 视觉效果说明
/// - **"双层毛玻璃"效果**：导航栏毛玻璃 + 标题区域毛玻璃叠加
/// - **不是通过颜色采样实现**：而是通过视觉层叠实现
/// - **标签容器无毛玻璃**：纯白色背景，避免视觉干扰
class CourseDetailPage extends ConsumerStatefulWidget {
  /// 课程图片URL
  final String imageUrl;

  /// 课程标题
  final String title;

  /// 课程副标题
  final String? subtitle;

  /// 课程 ID
  final String courseId;

  /// 标题区域底部间距（距离标签栏的距离）
  final double titleBottomPadding;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.titleBottomPadding = 60,
  });

  @override
  ConsumerState<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends ConsumerState<CourseDetailPage> {
  /// PageView 控制器
  ///
  /// 用于控制横向标签页的滑动，监听滑动事件来更新下划线动画
  late PageController _pageController;

  /// CustomScrollView 控制器（用于监听页面垂直滚动）
  ///
  /// 监听页面的垂直滚动，计算滚动进度来实现：
  /// - 标题区域淡出 + 向上滑动
  /// - 导航栏标题淡入
  /// - 导航栏毛玻璃效果渐显
  final ScrollController _scrollController = ScrollController();

  /// 截断后的标题（用于导航栏显示，避免标题过长）
  ///
  /// 在 initState 中计算一次，避免重复计算
  late String _truncatedTitle;

  @override
  void initState() {
    super.initState();
    // 初始化 PageView 控制器（初始显示第一个标签）
    final currentIndex = ref.read(courseDetailCurrentTabIndexProvider);
    _pageController = PageController(initialPage: currentIndex);
    // 监听 PageView 滑动，更新下划线动画
    _pageController.addListener(_onPageViewScroll);
    // 监听页面垂直滚动，更新滚动进度和动画效果
    _scrollController.addListener(_onScroll);
    // 预计算截断后的标题
    _truncatedTitle = _computeTruncatedTitle();
  }

  @override
  void dispose() {
    // 清理资源，避免内存泄漏
    _pageController.removeListener(_onPageViewScroll);
    _pageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 计算截断后的标题
  ///
  /// 假设导航栏可容纳约10个字符（中文字符）
  String _computeTruncatedTitle() {
    const maxChars = 10;
    if (widget.title.length <= maxChars) {
      return widget.title;
    }
    return '${widget.title.substring(0, maxChars)}...';
  }

  /// 监听页面垂直滚动，计算滚动进度
  ///
  /// 工作流程：
  /// 1. 获取当前滚动偏移量（_scrollController.offset）
  /// 2. 除以收缩距离得到滚动进度（0.0 - 1.0）
  /// 3. 通过 Riverpod Provider 更新滚动进度，触发页面重建
  /// 4. 所有依赖滚动进度的动画都会同时更新
  ///
  /// 关键：收缩距离 = expandedHeight - collapsedHeight
  /// - expandedHeight = 280（展开高度）
  /// - collapsedHeight = kToolbarHeight + tabBarHeight ≈ 56 + 50 = 106（收缩高度）
  /// - 当滚动到 174 时，标签栏正好吸顶，此时标题应该完全淡出
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    const expandedHeight = 280.0;
    const collapsedHeight = kToolbarHeight + 50.0; // toolbar(56) + tabBar(50) = 106
    const collapseDistance = expandedHeight - collapsedHeight; // 280 - 106 = 174

    final offset = _scrollController.offset;

    // 计算滚动进度（0.0 - 1.0）
    // - offset = 0 时，progress = 0.0（未滚动，标题完全显示）
    // - offset = 174 时，progress = 1.0（标签栏吸顶，标题完全淡出）
    final progress = (offset / collapseDistance).clamp(0.0, 1.0);

    // 使用 Riverpod Provider 更新滚动进度
    ref.read(courseDetailScrollProgressProvider.notifier).state = progress;
  }

  /// 监听 PageView 横向滚动，实时更新标签下划线动画状态
  ///
  /// 工作流程：
  /// 1. 获取 PageView 当前位置（_pageController.page，如 0.5 表示在第1和第2个标签之间）
  /// 2. 提取整数部分作为当前标签索引
  /// 3. 提取小数部分作为滑动位置（用于下划线动画插值）
  void _onPageViewScroll() {
    if (!_pageController.hasClients || courseDetailTabs.isEmpty) return;

    final page = _pageController.page;
    if (page == null) return;

    // page.floor() 获取当前标签索引（如 0.5 → 0，1.3 → 1）
    final index = page.floor();
    // page - index 获取滑动位置（如 0.5 → 0.5，1.3 → 0.3）
    final position = page - index;

    // 使用 Riverpod Provider 更新状态
    ref.read(courseDetailCurrentTabIndexProvider.notifier).state = index;
    ref.read(courseDetailScrollPositionProvider.notifier).state = position;
  }

  @override
  Widget build(BuildContext context) {
    // 监听所有需要的状态
    final scrollProgress = ref.watch(courseDetailScrollProgressProvider);
    final currentIndex = ref.watch(courseDetailCurrentTabIndexProvider);
    final scrollPosition = ref.watch(courseDetailScrollPositionProvider);
    final isFavorite = ref.watch(courseDetailFavoriteProvider);

    return Scaffold(
      // 关键修复：extendBodyBehindAppBar = true
      // 让 body 延伸到状态栏后面，背景图可以显示在状态栏区域
      extendBodyBehindAppBar: true,
      // 设置 Scaffold 背景为透明
      backgroundColor: Colors.transparent,
      // 移除 Scaffold 的 appBar，避免重复的导航栏
      // NestedScrollView 中的 SliverAppBar 会作为导航栏显示
      body: Stack(
        children: [
          // === 层级 1：固定的全屏背景图（最底层，不滚动）===
          // 背景图使用 Positioned.fill 填充整个屏幕
          // 图片位置固定，不会随页面滚动
          // 关键：背景图会覆盖到状态栏区域
          _buildFixedBackground(),

          // === 层级 2：嵌套滚动视图（在背景图之上）===
          // NestedScrollView 自动协调外层和内层的滚动
          // SliverAppBar 会作为导航栏显示在顶部
          _buildNestedScrollView(scrollProgress, currentIndex, scrollPosition),

          // === 层级 3：底部按钮栏（固定在底部）===
          _buildBottomActionBar(isFavorite),
        ],
      ),
    );
  }

  /// 构建固定的全屏背景图
  Widget _buildFixedBackground() {
    return Positioned.fill(
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) {
          return Container(color: Colors.grey[300]);
        },
      ),
    );
  }

  /// 构建嵌套滚动视图
  ///
  /// NestedScrollView 自动协调外层和内层的滚动行为：
  /// - 外层：标题区域 + 吸顶标签栏
  /// - 内层：PageView 的内容
  ///
  /// 滚动协调：
  /// - 向上滚动：先收起标题区域（280px）→ 标签栏吸顶 → 然后滚动内层内容
  /// - 向下滚动：先滚动内层内容到顶 → 然后展开标题区域
  /// 构建嵌套滚动视图
  ///
  /// NestedScrollView 自动协调外层和内层的滚动行为：
  /// - 外层：标题区域 + 吸顶标签栏
  /// - 内层：PageView 的内容
  ///
  /// 滚动协调：
  /// - 向上滚动：先收起标题区域（280px）→ 标签栏吸顶 → 然后滚动内层内容
  /// - 向下滚动：先滚动内层内容到顶 → 然后展开标题区域
  Widget _buildNestedScrollView(double scrollProgress, int currentIndex, double scrollPosition) {
    return NestedScrollView(
      // 外层滚动控制器（用于监听整个页面的滚动）
      controller: _scrollController,
      // 内层滚动坐标轴（垂直方向）
      physics: const AlwaysScrollableScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // === SliverAppBar: 标题区域 + 吸顶标签栏 ===
          SliverAppBar(
            // 展开高度 = 标题区域高度
            expandedHeight: 280,
            // 不浮动（始终显示）
            floating: false,
            // 固定（标签栏吸顶）
            pinned: true,
            // 透明背景
            backgroundColor: Colors.transparent,
            // 移除默认的阴影，保持透明
            elevation: 0,
            // 白色返回按钮
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            // 白色分享按钮
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                color: Colors.white,
                onPressed: () {
                  // TODO: 实现分享功能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('分享功能待实现'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            // 标题区域内容（包含毛玻璃、标题文字）
            flexibleSpace: _buildTitleFlexibleSpace(scrollProgress),
            // 吸顶标签栏
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _buildTabBar(),
            ),
          ),
        ];
      },
      // 内层内容：PageView（标签内容）
      body: Builder(
        builder: (context) => MediaQuery.removePadding(
          context: context,
          removeTop: true, // 移除顶部 padding
          child: _buildTabContentView(),
        ),
      ),
    );
  }

  /// 构建 SliverAppBar 的 flexibleSpace（标题区域 + 导航栏标题淡入动画）
  ///
  /// 包含：毛玻璃背景 + 标题文字 + 副标题 + 导航栏标题淡入动画
  /// 注意：返回按钮和分享按钮已移到 SliverAppBar 的 leading 和 actions 参数中
  Widget _buildTitleFlexibleSpace(double scrollProgress) {
    return Stack(
      children: [
        // === 毛玻璃背景 + 标题内容 ===
        _buildTitleContent(scrollProgress),

        // === 顶部导航栏标题（固定在最顶层，淡入动画）===
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: kToolbarHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: AnimatedOpacity(
                opacity: scrollProgress.clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 100),
                child: Text(
                  _truncatedTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建 PageView 内容视图
  ///
  /// NestedScrollView 的 body 部分
  /// 包含：PageView（4 个标签页）
  ///
  /// 使用 ClipRect 确保内容不会溢出到标签栏上方
  Widget _buildTabContentView() {
    return ClipRect(
      child: Padding(
        // 底部 padding = 底部按钮栏高度 + 安全区域
        padding: EdgeInsets.only(bottom: 80 + MediaQuery.of(context).padding.bottom),
        child: PageView(
          controller: _pageController,
          children: _buildTabContents(),
        ),
      ),
    );
  }

  /// 构建标题内容
  ///
  /// 布局结构：
  /// - Stack 叠加布局
  /// - 底层：毛玻璃效果 + 黑色半透明渐变
  /// - 顶层：标题文字（带滚动动画）
  ///
  /// 动画效果说明：
  /// 当用户向上滚动页面时：
  /// 1. scrollProgress 从 0.0 逐渐增加到 1.0
  /// 2. 标题文字向上移动 50px（translateY: -scrollProgress * 50）
  /// 3. 标题文字逐渐淡出（opacity: 1 - scrollProgress）
  /// 4. 同时，导航栏标题逐渐淡入，导航栏毛玻璃效果逐渐显现
  ///
  /// 注意：毛玻璃背景层不淡出，只有文字淡出
  ///
  /// ⚠️ 关键修复：使用 ClipRect 限制 BackdropFilter 的作用范围
  /// BackdropFilter 默认会影响 Stack 中所有上方的元素
  /// ClipRect 确保毛玻璃效果只影响标题区域本身
  Widget _buildTitleContent(double scrollProgress) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // === 第 1 层：增强的毛玻璃背景 ===
          // 这个层不淡出，始终显示
          // 包含：强化的模糊效果 + 黑色半透明渐变
          Positioned.fill(
            child: ClipRect(
              // 关键修复：用 ClipRect 限制 BackdropFilter 的作用范围
              // 确保毛玻璃效果只影响标题区域（280px 高度），不会影响标签栏和内容
              child: BackdropFilter(
                // 使用更强的模糊效果（sigmaX=20, sigmaY=20）让毛玻璃更明显
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    // 黑色半透明渐变（增加不透明度让毛玻璃效果更明显）
                    // 顶部 40% 不透明度 → 底部 75% 不透明度
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // === 第 2 层：标题文字（带滚动动画）===
          //
          // 🎯 动画实现原理：
          //
          // 工作流程：
          // 1. 用户滚动页面 → _scrollController 发出滚动通知
          // 2. _onScroll() 监听器被调用（在 initState 中注册）
          // 3. _onScroll() 计算 scrollProgress 并调用 setState()
          // 4. setState() 触发 build() 方法重新执行
          // 5. Transform 和 Opacity 读取新的 scrollProgress 值
          // 6. 标题文字更新：向上移动 + 淡出
          //
          // 动画效果：
          // - Transform.translate: 向上滑动 (translateY: -scrollProgress * 50)
          //   - scrollProgress = 0.0 时，translateY = 0（原始位置）
          //   - scrollProgress = 0.5 时，translateY = -25（向上移动 25px）
          //   - scrollProgress = 1.0 时，translateY = -50（向上移动 50px）
          //
          // - Opacity: 渐变淡出 (opacity: 1 - scrollProgress)
          //   - scrollProgress = 0.0 时，opacity = 1.0（完全不透明）
          //   - scrollProgress = 0.5 时，opacity = 0.5（半透明）
          //   - scrollProgress = 1.0 时，opacity = 0.0（完全透明，不可见）
          //
          // ✅ 已实现：向上滑动 + 淡出效果
          // ⚠️ 调试提示：如果动画不生效，在 _onScroll() 方法中添加 print 语句
          Positioned(
            left: 16,
            right: 16,
            bottom: widget.titleBottomPadding,
            child: Transform.translate(
              // 向上滑动效果：随着滚动进度增加，向上移动
              offset: Offset(0, -scrollProgress * 50),
              child: Opacity(
                // 淡出效果：随着滚动进度增加，透明度降低
                opacity: 1 - scrollProgress,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题文字
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 副标题（如果有）
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 16),
                    // 价格信息（免费课程）
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '免费课程',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签栏
  ///
  /// CourseDetailTabBar 组件说明：
  /// - 白色背景（无毛玻璃效果）
  /// - 上面两个角圆角（topLeft, topRight）
  /// - 复用首页的下划线滑动动画效果
  /// - 4个标签：简介、目录、评价、推荐
  ///
  /// 优化：直接传入 PageController，由组件内部监听，零延迟更新动画
  Widget _buildTabBar() {
    return CourseDetailTabBar(
      tabs: courseDetailTabs,
      pageController: _pageController,
      onTap: _onTabTap,
    );
  }

  /// 构建标签内容列表
  ///
  /// 返回 4 个标签页组件：
  /// - CourseIntroTab: 课程简介（白色背景 + SingleChildScrollView）
  /// - CourseCatalogTab: 课程目录（白色背景 + 可展开章节列表）
  /// - CourseReviewsTab: 课程评价（白色背景 + 评分统计 + 评价列表）
  /// - CourseRecommendTab: 推荐课程（白色背景 + ProductCard 列表）
  ///
  /// ⚠️ 每个 Tab 页面都有独立的白色背景（Container(color: Colors.white)）
  /// 这样可以确保背景图不会透过标签内容显示
  List<Widget> _buildTabContents() {
    return [
      const CourseIntroTab(),
      const CourseCatalogTab(),
      const CourseReviewsTab(),
      const CourseRecommendTab(),
    ];
  }

  /// 标签点击事件处理
  ///
  /// 当用户点击标签时：
  /// 1. PageView 动画滚动到对应的标签页
  /// 2. _onPageViewScroll 监听到滑动，更新 _currentIndex 和 _scrollPosition
  /// 3. 下划线动画自动跟随滑动位置
  void _onTabTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  /// 构建底部操作按钮栏
  ///
  /// 布局结构：
  /// - 左侧：收藏按钮（图标按钮）
  /// - 右侧：购买按钮（主要按钮，占据剩余空间）
  ///
  /// 视觉效果：
  /// - 白色背景
  /// - 毛玻璃效果
  /// - 顶部边框分割线
  /// - 安全区域适配
  Widget _buildBottomActionBar(bool isFavorite) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            // 白色半透明背景 + 顶部边框
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              border: const Border(
                top: BorderSide(
                  color: Colors.black12,
                  width: 0.5,
                ),
              ),
            ),
            // SafeArea 自动处理底部安全区域
            child: SafeArea(
              top: false,
              child: Padding(
                // vertical: 12 控制按钮距离顶部和底部的间距
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // 收藏按钮（固定宽度）
                    _buildFavoriteButton(isFavorite),
                    const SizedBox(width: 12),

                    // 购买按钮（占据剩余空间）
                    Expanded(child: _buildBuyButton()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建收藏按钮
  ///
  /// 使用 IconButton 实现简单的图标按钮
  /// - 未收藏：空心星星图标
  /// - 已收藏：实心星星图标（金色）
  Widget _buildFavoriteButton(bool isFavorite) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? Colors.amber : Colors.grey.shade600,
        ),
        onPressed: _onFavoriteTap,
      ),
    );
  }

  /// 构建购买按钮
  ///
  /// 使用 AppButton 的主要按钮样式
  /// - 全宽（Expanded）
  /// - 显示价格和"立即购买"文字
  Widget _buildBuyButton() {
    return AppButton(
      text: '免费学习',
      type: AppButtonType.primary,
      size: AppButtonSize.large,
      isFullWidth: true,
      borderRadius: 12,
      onPressed: _onBuyTap,
    );
  }

  /// 收藏按钮点击事件
  void _onFavoriteTap() {
    // 使用 Riverpod Provider 更新收藏状态
    final currentValue = ref.read(courseDetailFavoriteProvider);
    ref.read(courseDetailFavoriteProvider.notifier).state = !currentValue;

    final newValue = !currentValue;

    // 显示提示消息
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newValue ? '已添加到收藏' : '已取消收藏'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 购买按钮点击事件
  void _onBuyTap() {
    // 跳转到免费课程播放页
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => FreeCoursePlayPage(
          courseId: widget.courseId,
          title: widget.title,
          // 使用指定的视频链接
          videoUrl:
              'https://fuyin15190311094.oss-cn-beijing.aliyuncs.com/04%E5%9C%A8VSCode%E4%B8%8B%E7%BC%96%E5%86%99Flutter%E4%BB%A3%E7%A0%81_%E3%80%90%E6%9B%B4%E5%A4%9A%E8%B5%84%E6%96%99%E7%9C%8Bdaavip%E6%9C%8B%E5%8F%8B%E5%9C%88%E3%80%91.mp4',
          coverImage: widget.imageUrl,
        ),
      ),
    );
  }
}
