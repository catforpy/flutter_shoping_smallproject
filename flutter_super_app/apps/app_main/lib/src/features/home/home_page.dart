library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';
import 'data/data.dart';
import 'tabs/tabs.dart';
import 'providers/home_page_provider.dart';

/// 首页
///
/// ## 功能模块化架构
/// - 标签切换由 HomePage 管理
/// - 每个标签页的内容由独立的 Tab 组件管理
/// - 数据层使用 Repository 模式
/// - 状态管理使用 Riverpod
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  /// PageView 控制器
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // 初始化 PageController（使用 Provider 的初始值）
    final initialIndex = ref.read(homeCurrentIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
    // 添加滚动监听器
    _pageController.addListener(_onPageViewScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageViewScroll);
    _pageController.dispose();
    super.dispose();
  }

  /// 监听 PageView 滚动，实时更新标签动画状态
  void _onPageViewScroll() {
    // FutureProvider 可能还没加载完成，所以需要检查
    final tabsAsyncValue = ref.read(homeTabsProvider);
    if (tabsAsyncValue is! AsyncData) return;

    final tabs = (tabsAsyncValue as AsyncData).value;
    if (!_pageController.hasClients || tabs.isEmpty) return;

    final page = _pageController.page;
    if (page == null) return;

    final index = page.floor();
    final position = page - index;

    // 更新 Provider 状态
    ref.read(homeCurrentIndexProvider.notifier).state = index;
    ref.read(homeScrollPositionProvider.notifier).state = position;
  }

  @override
  Widget build(BuildContext context) {
    // 监听首页标签数据（自动处理加载状态和错误状态）
    final tabsAsyncValue = ref.watch(homeTabsProvider);

    // 监听当前选中的标签索引和滚动位置
    final currentIndex = ref.watch(homeCurrentIndexProvider);
    final scrollPosition = ref.watch(homeScrollPositionProvider);

    return tabsAsyncValue.when(
      loading: () => _buildLoadingView(),
      error: (error, stackTrace) => _buildErrorView(error.toString()),
      data: (tabs) {
        return _buildHomePage(tabs, currentIndex, scrollPosition);
      },
    );
  }

  /// 构建加载中视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载中...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // 刷新数据
              ref.invalidate(homeTabsProvider);
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建首页整体布局（顶部标签 + 内容区域）
  Widget _buildHomePage(List<HomeTabModel> tabs, int currentIndex, double scrollPosition) {
    return Column(
      children: [
        _buildHorizontalTabs(tabs, currentIndex, scrollPosition), // 构建横向滑动标签栏（推荐、关注、热门...）
        _buildContentArea(tabs), // 构建内容区域（占满剩余空间）
      ],
    );
  }

  /// 构建横向滑动标签栏（弹性下划线动画）
  Widget _buildHorizontalTabs(List<HomeTabModel> tabs, int currentIndex, double scrollPosition) {
    // 将 HomeTabModel 转换为 UnderlineTabItem
    final tabItems = tabs
        .map((model) => UnderlineTabItem(id: model.id, title: model.title))
        .toList();

    return UnderlineTabsWithSlider(
      tabs: tabItems,
      currentIndex: currentIndex,
      scrollPosition: scrollPosition,
      onTap: _onTabTap,
      indicatorConfig: UnderlineIndicatorConfig(
        color: Colors.red, // 红色下划线
        width: 40, // 固定宽度
        height: 3, // 下划线高度
        useElasticAnimation: true, // 启用弹性动画
      ),
      styleConfig: UnderlineTabStyleConfig(
        selectedColor: Colors.red, // 选中文字红色
        unselectedColor: Colors.black, // 未选中文字黑色
        selectedFontSize: 17,
        unselectedFontSize: 15,
        selectedFontWeight: FontWeight.bold,
        unselectedFontWeight: FontWeight.normal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        spacing: 12,
      ),
      backgroundColor: Colors.white, // 白色背景
    );
  }

  /// 构建内容区域（占满剩余空间，使用 PageView 支持滑动切换）
  Widget _buildContentArea(List<HomeTabModel> tabs) {
    return Expanded(
      child: PageView(
        controller: _pageController,
        children: tabs.map((tab) => _buildTabPageContent(tab)).toList(),
      ),
    );
  }

  /// 构建单个标签页的内容
  Widget _buildTabPageContent(HomeTabModel tab) {
    // 根据标签 ID 返回对应的标签页组件
    switch (tab.id) {
      case '0':
        return const RecommendTab(); // 推荐标签页（有轮播图）
      case '1':
        return const FollowTab(); // 关注标签页（列表）
      case '2':
        return const HotTab(); // 热门标签页（网格）
      default:
        // 如果有更多标签，默认显示推荐页
        return const RecommendTab();
    }
  }

  /// 标签点击事件处理
  void _onTabTap(int index) {
    // 点击标签时，同步滚动 PageView
    // 动画时长设置为 400ms，与下划线的弹性动画同步
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    // 不在这里更新 _currentIndex，让 PageView 的 onPageChanged 来更新
    // 这样标签切换就会和内容滑动、下划线动画同步
  }
}
