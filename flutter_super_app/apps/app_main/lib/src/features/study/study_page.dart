library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';
import 'package:go_router/go_router.dart';
import '../../shared_providers.dart';
import '../../router/app_routes.dart';

// ==================== Riverpod Providers ====================

/// 学习页内容标签状态 Provider（我的课程/我的专栏）
final studyContentTabProvider = StateProvider<int>((ref) => 0);

/// 学习页面
class StudyPage extends ConsumerStatefulWidget {
  const StudyPage({super.key});

  @override
  ConsumerState<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends ConsumerState<StudyPage> {
  /// PageView 控制器
  late PageController _pageController;

  /// 学习页内容标签列表
  static const List<UnderlineTabItem> _contentTabs = [
    UnderlineTabItem(id: '0', title: '我的课程'),
    UnderlineTabItem(id: '1', title: '我的专栏'),
  ];

  @override
  void initState() {
    super.initState();
    final selectedTabIndex = ref.read(studyTabProvider);
    _pageController = PageController(initialPage: selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听 provider 变化，同步 PageView
    ref.listen<int>(studyTabProvider, (previous, next) {
      if (previous != next && _pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar 由 MainShell 提供（包含标签导航栏）
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(studyTabProvider.notifier).state = index;
        },
        children: [
          _buildTabPage('学习'),
          _buildTabPage('课表'),
        ],
      ),
    );
  }

  /// 构建标签页
  Widget _buildTabPage(String title) {
    if (title == '学习') {
      // 学习页面：显示横向卡片 + 标签栏
      final selectedContentTabIndex = ref.watch(studyContentTabProvider);

      return Column(
        children: [
          const SizedBox(height: 16),
          _buildActionCard(),
          const SizedBox(height: 16),
          // 横向滑动标签栏（我的课程/我的专栏）
          _buildContentTabBar(selectedContentTabIndex),
          // 内容区域（待开发）
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.green[200],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _contentTabs[selectedContentTabIndex].title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '待开发...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // 课表页面：保持原样
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              '$title页面',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '待开发...',
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

  /// 构建内容标签栏（我的课程/我的专栏）
  Widget _buildContentTabBar(int selectedIndex) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 左侧：标签栏
          Expanded(
            child: UnderlineTabs(
              tabs: _contentTabs,
              currentIndex: selectedIndex,
              onTap: (index) {
                ref.read(studyContentTabProvider.notifier).state = index;
              },
              indicatorConfig: const UnderlineIndicatorConfig(
                color: Colors.transparent, // 不显示下划线
                height: 0,
              ),
              styleConfig: const UnderlineTabStyleConfig(
                selectedColor: Colors.black87,
                unselectedColor: Colors.grey,
                selectedFontSize: 15,
                unselectedFontSize: 14,
                selectedFontWeight: FontWeight.w500,
                unselectedFontWeight: FontWeight.normal,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                spacing: 20,
              ),
              backgroundColor: Colors.white,
              scrollable: false, // 只有两个标签，不需要滚动
            ),
          ),
          // 右侧："全部"按钮（仅在"我的课程"选中时显示）
          if (selectedIndex == 0)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('查看全部课程')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '全部',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建功能卡片（横向排列5个图标）
  Widget _buildActionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            icon: Icons.favorite,
            label: '收藏',
            onTap: () {
              context.push(AppRoutes.favorites);
            },
          ),
          _buildActionItem(
            icon: Icons.question_answer,
            label: '问答',
            onTap: () {
              context.push(AppRoutes.questions);
            },
          ),
          _buildActionItem(
            icon: Icons.edit_note,
            label: '笔记',
            onTap: () {
              context.push(AppRoutes.notes);
            },
          ),
          _buildActionItem(
            icon: Icons.menu_book,
            label: '手记',
            onTap: () {
              context.push(AppRoutes.notebooks);
            },
          ),
          _buildActionItem(
            icon: Icons.download,
            label: '下载',
            onTap: () {
              context.push(AppRoutes.downloads);
            },
          ),
        ],
      ),
    );
  }

  /// 构建单个功能项
  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
