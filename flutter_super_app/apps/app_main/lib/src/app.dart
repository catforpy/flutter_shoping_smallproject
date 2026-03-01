library;

import 'package:flutter/material.dart';
import 'features/home/home_page.dart';
import 'features/category/category_page.dart';
import 'features/discovery/discovery_page.dart';
import 'features/study/study_page.dart';
import 'features/profile/profile_page/profile_page.dart';

/// 主应用框架 - 底部导航栏 + 顶部导航栏
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  // 页面列表
  final List<_PageItem> _pages = [
    const _PageItem(
      title: '首页',
      icon: Icons.home,
      page: HomePage(),
    ),
    const _PageItem(
      title: '分类',
      icon: Icons.category,
      page: CategoryPage(),
    ),
    const _PageItem(
      title: '发现',
      icon: Icons.explore,
      page: DiscoveryPage(),
    ),
    const _PageItem(
      title: '学习',
      icon: Icons.school,
      page: StudyPage(),
    ),
    _PageItem(
      title: '我的',
      icon: Icons.person,
      page: ProfilePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      // 顶部导航栏（首页不显示 AppBar，其他页面显示标题）
      appBar: _currentIndex == 0 ? null : _buildTitleAppBar(currentPage.title),
      // 内容区域
      body: currentPage.page,
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _pages
            .map(
              (page) => BottomNavigationBarItem(
                icon: Icon(page.icon),
                label: page.title,
              ),
            )
            .toList(),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// 构建标题导航栏（其他页面使用）
  PreferredSizeWidget _buildTitleAppBar(String title) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }
}

/// 页面项
class _PageItem {
  final String title;
  final IconData icon;
  final Widget page;

  const _PageItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}
