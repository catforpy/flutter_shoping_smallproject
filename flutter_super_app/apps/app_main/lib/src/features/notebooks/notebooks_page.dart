library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';

/// 我的手记页面
class NotebooksPage extends StatefulWidget {
  const NotebooksPage({super.key});

  @override
  State<NotebooksPage> createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  /// PageView 控制器
  late PageController _pageController;

  /// 标签列表
  static const List<UnderlineTabItem> _tabs = [
    UnderlineTabItem(id: '0', title: '历史'),
    UnderlineTabItem(id: '1', title: '收藏'),
    UnderlineTabItem(id: '2', title: '发表'),
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
          '我的手记',
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
              children: const [
                _TabPage(title: '历史手记'),
                _TabPage(title: '收藏手记'),
                _TabPage(title: '发表手记'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return CourseDetailTabBar(
      tabs: _tabs,
      pageController: _pageController,
      onTap: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
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
            Icons.menu_book,
            size: 80,
            color: Colors.purple[200],
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
