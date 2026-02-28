library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';
import '../../shared_providers.dart';

// ==================== Riverpod Providers ====================

/// 推荐页子标签状态 Provider
final discoverySubTabProvider = StateProvider<int>((ref) => 0);

/// 发现页面
class DiscoveryPage extends ConsumerStatefulWidget {
  const DiscoveryPage({super.key});

  @override
  ConsumerState<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends ConsumerState<DiscoveryPage> {
  /// PageView 控制器
  late PageController _pageController;

  /// 推荐页子标签列表
  static const List<UnderlineTabItem> _subTabs = [
    UnderlineTabItem(id: '0', title: '热门'),
    UnderlineTabItem(id: '1', title: '最新'),
    UnderlineTabItem(id: '2', title: 'Tony bai 说'),
    UnderlineTabItem(id: '3', title: '前端开发'),
    UnderlineTabItem(id: '4', title: '对话ChatGPT'),
    UnderlineTabItem(id: '5', title: '后端开发'),
    UnderlineTabItem(id: '6', title: '移动开发'),
    UnderlineTabItem(id: '7', title: '云计算/大数据'),
    UnderlineTabItem(id: '8', title: '产品设计'),
    UnderlineTabItem(id: '9', title: '工具资源'),
    UnderlineTabItem(id: '10', title: '人工智能'),
    UnderlineTabItem(id: '11', title: '职场生活'),
    UnderlineTabItem(id: '12', title: '经验分享'),
    UnderlineTabItem(id: '13', title: '其他'),
  ];

  @override
  void initState() {
    super.initState();
    final selectedTabIndex = ref.read(discoveryTabProvider);
    _pageController = PageController(initialPage: selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = ref.watch(discoveryTabProvider);

    // 监听 provider 变化，同步 PageView
    ref.listen<int>(discoveryTabProvider, (previous, next) {
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
          ref.read(discoveryTabProvider.notifier).state = index;
        },
        children: [
          _buildTabPage('推荐'),
          _buildTabPage('关注'),
        ],
      ),
    );
  }

  /// 构建标签页
  Widget _buildTabPage(String title) {
    if (title == '推荐') {
      // 推荐页面：显示横向滑动标签容器
      final selectedSubTabIndex = ref.watch(discoverySubTabProvider);

      return Column(
        children: [
          // 横向滑动标签容器
          _buildSubTabBar(selectedSubTabIndex),
          // 内容区域
          Expanded(
            child: Center(
              child: Text(
                '${_subTabs[selectedSubTabIndex].title} - 内容待开发',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // 关注页面：保持原样
      return Center(
        child: Text(
          '$title页面 - 待开发',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  /// 构建子标签栏（横向滑动）
  Widget _buildSubTabBar(int selectedIndex) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: UnderlineTabs(
        tabs: _subTabs,
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(discoverySubTabProvider.notifier).state = index;
        },
        indicatorConfig: const UnderlineIndicatorConfig(
          color: Colors.transparent, // 不显示下划线
          height: 0,
        ),
        styleConfig: const UnderlineTabStyleConfig(
          selectedColor: Colors.black87,
          unselectedColor: Colors.grey,
          selectedFontSize: 15, // 比推荐/关注（17/15）小一级
          unselectedFontSize: 14,
          selectedFontWeight: FontWeight.w500,
          unselectedFontWeight: FontWeight.normal,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          spacing: 20, // 标签间距
        ),
        backgroundColor: Colors.white,
        scrollable: true, // 支持横向滑动
      ),
    );
  }
}
