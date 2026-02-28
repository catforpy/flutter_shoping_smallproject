library;

import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';

/// 我的笔记页面
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  /// PageView 控制器
  late PageController _pageController;

  /// 标签列表
  static const List<UnderlineTabItem> _tabs = [
    UnderlineTabItem(id: '0', title: '全部'),
    UnderlineTabItem(id: '1', title: '课程'),
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
          '我的笔记',
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
              children: [
                const _TabPage(title: '全部笔记'),
                const _CourseTabPage(), // 课程笔记（带子标签）
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
            Icons.edit_note,
            size: 80,
            color: Colors.blue[200],
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
  static const List<String> _subTabs = [
    '全部',
    '免费课',
    '实战课',
    '体系课',
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
              _SubTabPage(title: '全部课程笔记'),
              _SubTabPage(title: '免费课程笔记'),
              _SubTabPage(title: '实战课程笔记'),
              _SubTabPage(title: '体系课程笔记'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8, // 按钮之间的水平间距
        runSpacing: 8, // 按钮之间的垂直间距
        children: List.generate(_subTabs.length, (index) {
          final isSelected = _subTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _subTabIndex = index;
              });
              _subPageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _subTabs[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }),
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
            Icons.note,
            size: 80,
            color: Colors.blue[200],
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
