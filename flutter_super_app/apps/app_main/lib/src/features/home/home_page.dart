library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';
import '../../widgets/main_shell.dart';
import 'providers/home_product_provider.dart';
import 'theme/home_theme.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/home_category_tabs.dart';
import 'widgets/home_category_grid.dart';
import 'widgets/home_product_list.dart';

/// 首页
///
/// 使用 CourseDetailTabBar 组件作为顶部导航栏
/// 标签：特价、首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// PageView 控制器
  late PageController _pageController;

  /// 标签列表
  final List<UnderlineTabItem> _tabs = const [
    UnderlineTabItem(id: '0', title: '特价'),
    UnderlineTabItem(id: '1', title: '首页'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // 默认显示"首页"
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部标签栏（使用 SafeArea 确保不被刘海屏/状态栏遮挡）
          SafeArea(
            bottom: false,
            child: CourseDetailTabBar(
              tabs: _tabs,
              pageController: _pageController,
              onTap: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              height: 50,
              topBorderRadius: 0,
              centerTabs: true,
            ),
          ),

          // 内容区域（支持手势滑动）
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                // PageView 滑动时，CourseDetailTabBar 会自动监听并更新
                // 这里不需要额外操作，CourseDetailTabBar 已经通过 listener 监听了
              },
              children: const [
                // 特价页面
                _SpecialPricePage(),
                // 首页内容
                _HomePageContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 特价页面
class _SpecialPricePage extends StatelessWidget {
  const _SpecialPricePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HomeTheme.lightGreyBackground,
      child: Column(
        children: [
          // 搜索框区域
          const HomeSearchBar(),

          // 内容区域
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '特价页面',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '← 向右滑动切换到首页 →',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页内容
class _HomePageContent extends ConsumerWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizontalTabIndex = ref.watch(homeHorizontalTabProvider);

    return Container(
      color: HomeTheme.lightGreyBackground,
      child: Column(
        children: [
          // 搜索框区域
          const HomeSearchBar(),

          // 横向滑动标签栏
          HomeCategoryTabs(
            currentIndex: horizontalTabIndex,
            onTap: (index) {
              ref.read(homeHorizontalTabProvider.notifier).state = index;
            },
          ),

          // 可展开网格轮播组件
          const HomeCategoryGrid(),

          // 商品列表区域（可滚动）
          const Expanded(
            child: HomeProductList(),
          ),
        ],
      ),
    );
  }
}
