library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';

/// 我的收藏页面
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  /// 当前选中的标签索引
  int _currentIndex = 0;

  /// PageView 控制器
  late PageController _pageController;

  /// 标签列表
  static const List<UnderlineTabItem> _tabs = [
    UnderlineTabItem(id: '0', title: '课程'),
    UnderlineTabItem(id: '1', title: '专栏'),
    UnderlineTabItem(id: '2', title: '教程'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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
      // 顶部导航栏
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '我的收藏',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      // 标签栏 + 内容
      body: Column(
        children: [
          // 标签栏
          _buildTabBar(),
          // 内容区域
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                _CourseTabPage(), // 课程页面（带子标签）
                const _TabPage(title: '专栏'),
                const _TabPage(title: '教程'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签栏（红色主题）
  Widget _buildTabBar() {
    return UnderlineTabs(
      tabs: _tabs,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      indicatorConfig: const UnderlineIndicatorConfig(
        color: Colors.red, // 红色下划线
        width: 40,
        height: 3,
      ),
      styleConfig: const UnderlineTabStyleConfig(
        selectedColor: Colors.red, // 选中文字红色
        unselectedColor: Colors.black, // 未选中文字黑色
        selectedFontSize: 17,
        unselectedFontSize: 15,
        selectedFontWeight: FontWeight.bold,
        unselectedFontWeight: FontWeight.normal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        spacing: 12,
      ),
      backgroundColor: Colors.white,
    );
  }
}

/// 标签页内容
class _TabPage extends StatelessWidget {
  final String title;

  const _TabPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.red[200],
          ),
          const SizedBox(height: 16),
          Text(
            '$title收藏',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '暂无内容',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// 课程标签页（带子标签）
class _CourseTabPage extends StatefulWidget {
  const _CourseTabPage();

  @override
  State<_CourseTabPage> createState() => _CourseTabPageState();
}

class _CourseTabPageState extends State<_CourseTabPage> {
  /// 子标签索引
  int _subTabIndex = 0;

  /// 子标签 PageView 控制器
  late PageController _subPageController;

  /// 子标签列表
  static const List<UnderlineTabItem> _subTabs = [
    UnderlineTabItem(id: '0', title: '全部'),
    UnderlineTabItem(id: '1', title: '免费课'),
    UnderlineTabItem(id: '2', title: '实战课'),
  ];

  @override
  void initState() {
    super.initState();
    _subPageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _subPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 子标签栏
        _buildSubTabBar(),
        // 子标签内容
        Expanded(
          child: PageView(
            controller: _subPageController,
            physics: const NeverScrollableScrollPhysics(), // 禁用横向滑动
            onPageChanged: (index) {
              setState(() {
                _subTabIndex = index;
              });
            },
            children: const [
              _SubTabPage(title: '全部课程'),
              _SubTabPage(title: '免费课程'),
              _SubTabPage(title: '实战课程'),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建子标签栏
  Widget _buildSubTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: UnderlineTabs(
        tabs: _subTabs,
        currentIndex: _subTabIndex,
        onTap: (index) {
          setState(() {
            _subTabIndex = index;
          });
          _subPageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        indicatorConfig: const UnderlineIndicatorConfig(
          color: Colors.red,
          width: 40,
          height: 2,
        ),
        styleConfig: const UnderlineTabStyleConfig(
          selectedColor: Colors.red,
          unselectedColor: Colors.grey,
          selectedFontSize: 15,
          unselectedFontSize: 14,
          selectedFontWeight: FontWeight.w500,
          unselectedFontWeight: FontWeight.normal,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          spacing: 20,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}

/// 子标签页内容
class _SubTabPage extends StatelessWidget {
  final String title;

  const _SubTabPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 80,
            color: Colors.red[200],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '暂无内容',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
