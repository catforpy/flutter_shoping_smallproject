library;

import 'package:flutter/material.dart';

/// 我的问答页面
class QuestionsPage extends StatefulWidget {
  const QuestionsPage({super.key});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  /// 筛选菜单是否展开
  bool _isFilterMenuOpen = false;

  /// 当前选中的筛选选项
  String _selectedFilter = '全部';

  /// 筛选选项列表
  static const List<String> _filterOptions = [
    '全部',
    '我的提问',
    '我的回答',
    '我的关注',
  ];

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
        title: _buildTitleWithFilter(),
        centerTitle: true,
      ),
      // 内容区域
      body: Stack(
        children: [
          // 主内容（带点击监听，可关闭菜单）
          GestureDetector(
            onTap: () {
              if (_isFilterMenuOpen) {
                setState(() {
                  _isFilterMenuOpen = false;
                });
              }
            },
            behavior: HitTestBehavior.translucent,
            child: _buildContent(),
          ),
          // 筛选菜单（悬浮层，紧贴 AppBar 底部）
          if (_isFilterMenuOpen) _buildFilterMenu(),
        ],
      ),
    );
  }

  /// 构建带筛选按钮的标题
  Widget _buildTitleWithFilter() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFilterMenuOpen = !_isFilterMenuOpen;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '我的问答',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          // 三角形图标（带旋转动画）
          AnimatedRotation(
            turns: _isFilterMenuOpen ? 0.5 : 0.0, // 旋转180度
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: const Icon(
              Icons.expand_more,
              size: 24,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选菜单
  Widget _buildFilterMenu() {
    return Positioned(
      top: 0, // 紧贴 Scaffold body 的顶部（即 AppBar 底部）
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          // 点击菜单区域本身不关闭（防止事件冒泡）
        },
        child: Column(
          children: [
            // 菜单容器（居中显示）
            Center(
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _filterOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = option == _selectedFilter;

                    return _buildFilterMenuItem(
                      option,
                      isSelected,
                      isFirst: index == 0,
                      isLast: index == _filterOptions.length - 1,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个筛选菜单项
  Widget _buildFilterMenuItem(
    String title,
    bool isSelected, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
          _isFilterMenuOpen = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[50] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            topRight: isFirst ? const Radius.circular(8) : Radius.zero,
            bottomLeft: isLast ? const Radius.circular(8) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.red : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 16,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建主内容
  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.question_answer,
            size: 80,
            color: Colors.orange[200],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter,
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

