library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';
import 'package:go_router/go_router.dart';

// ==================== Riverpod Providers ====================

/// 底部导航状态 Provider
final bottomNavProvider = StateProvider<int>((ref) => 0);

/// 发现页面标签状态 Provider
final discoveryTabProvider = StateProvider<int>((ref) => 0);

/// 学习页面标签状态 Provider
final studyTabProvider = StateProvider<int>((ref) => 0);

// ==================== 主应用壳 ====================

/// 主应用壳（带底部导航栏和顶部导航栏）
///
/// 包含：
/// - 底部导航栏（5个标签）
/// - 顶部导航栏（首页显示搜索框，其他页面显示标题）
class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // 发现页菜单按钮的 GlobalKey，用于定位弹出菜单位置
  final _discoveryMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      // 顶部导航栏
      appBar: _buildAppBar(context, ref, currentIndex),
      // 内容区域
      body: widget.child,
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).state = index;
          // 同时更新路由
          _navigateToIndex(context, index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '分类',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '学习',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// 构建顶部导航栏
  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    // 首页不显示 AppBar（使用自己的 CourseDetailTabBar）
    if (currentIndex == 0) {
      return null;
    } else if (currentIndex == 1) {
      return _buildCategorySearchAppBar(context, ref);
    } else if (currentIndex == 2) {
      // 发现页面显示标签导航栏（推荐、关注）
      return _buildDiscoveryAppBar(context, ref);
    } else if (currentIndex == 3) {
      // 学习页面显示标签导航栏（学习、课表）
      return _buildStudyAppBar(context, ref);
    }
    // 其他页面显示标题
    return _buildTitleAppBar(context, _getPageTitle(currentIndex));
  }

  /// 构建分类页面搜索框导航栏（搜索框 + 购物车图标）
  PreferredSizeWidget _buildCategorySearchAppBar(
    BuildContext context,
    WidgetRef ref,
  ) {
    final searchController = TextEditingController();

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: SearchField(
        controller: searchController,
        hintText: '',
        readOnly: true,
        styleConfig: SearchFieldStyleConfig(
          backgroundColor: const Color(0xFFF5F5F5),
          textColor: Colors.black87,
          hintColor: Colors.grey[600]!,
          cursorColor: Colors.blue,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        animationConfig: SearchFieldAnimationConfig(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        ),
        actionConfig: SearchFieldActionConfig(
          onTap: () {
            context.push('/search');
          },
        ),
        prefix: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            SearchHintRotator(
              hintGroups: const [
                SearchHintGroup(hints: ['Flutter', '开发', '教程']),
                SearchHintGroup(hints: ['Dart', '语言', '基础']),
                SearchHintGroup(hints: ['状态管理', 'Riverpod', '实战']),
                SearchHintGroup(hints: ['性能', '优化', '技巧']),
              ],
              config: SearchHintRotatorConfig(
                hintColor: Colors.grey[600]!,
                interval: const Duration(seconds: 3),
                animationDuration: const Duration(milliseconds: 500),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      centerTitle: false,
      titleSpacing: 8,
      actions: [
        // 购物车图标
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('购物车功能待开发')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 24,
                  color: Colors.black87,
                ),
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 构建发现页面导航栏（标签 + 菜单按钮）
  PreferredSizeWidget _buildDiscoveryAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: UnderlineTabsWithSlider(
        tabs: const [
          UnderlineTabItem(id: '0', title: '推荐'),
          UnderlineTabItem(id: '1', title: '关注'),
        ],
        currentIndex: ref.watch(discoveryTabProvider),
        scrollPosition: 0.0,
        onTap: (index) {
          ref.read(discoveryTabProvider.notifier).state = index;
        },
        indicatorConfig: const UnderlineIndicatorConfig(
          color: Colors.black,
          width: 16, // 固定宽度，确保两个标签下划线一致
          height: 2,
          useElasticAnimation: false,
        ),
        styleConfig: UnderlineTabStyleConfig(
          selectedColor: Colors.black,
          unselectedColor: Colors.grey,
          selectedFontSize: 17,
          unselectedFontSize: 15,
          selectedFontWeight: FontWeight.bold,
          unselectedFontWeight: FontWeight.normal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 恢复合适的水平padding
          spacing: 32, // 增加标签之间的间距
        ),
        backgroundColor: Colors.white,
      ),
      centerTitle: false,
      titleSpacing: 8,
      actions: [
        // 菜单按钮（弹出悬浮菜单）
        GestureDetector(
          key: _discoveryMenuKey,
          onTap: () => _showDiscoveryPopupMenu(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.menu_rounded,
              size: 28,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 构建学习页面导航栏（标签，无菜单按钮）
  PreferredSizeWidget _buildStudyAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: UnderlineTabsWithSlider(
        tabs: const [
          UnderlineTabItem(id: '0', title: '学习'),
          UnderlineTabItem(id: '1', title: '课表'),
        ],
        currentIndex: ref.watch(studyTabProvider),
        scrollPosition: 0.0,
        onTap: (index) {
          ref.read(studyTabProvider.notifier).state = index;
        },
        indicatorConfig: const UnderlineIndicatorConfig(
          color: Colors.black,
          width: 16, // 固定宽度，确保两个标签下划线一致
          height: 2,
          useElasticAnimation: false,
        ),
        styleConfig: UnderlineTabStyleConfig(
          selectedColor: Colors.black,
          unselectedColor: Colors.grey,
          selectedFontSize: 17,
          unselectedFontSize: 15,
          selectedFontWeight: FontWeight.bold,
          unselectedFontWeight: FontWeight.normal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          spacing: 32, // 增加标签之间的间距
        ),
        backgroundColor: Colors.white,
      ),
      centerTitle: false,
      titleSpacing: 8,
      // 学习页面没有菜单按钮，所以 actions 为空
    );
  }

  /// 显示发现页悬浮菜单
  void _showDiscoveryPopupMenu(BuildContext context) {
    // 获取按钮的位置
    final RenderBox? renderBox =
        _discoveryMenuKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // 显示悬浮菜单
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5), // 半透明黑色遮罩
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _DiscoveryPopupMenu(
          buttonOffset: offset,
          buttonSize: size,
        );
      },
    );
  }

  /// 构建标题导航栏（其他页面使用）
  PreferredSizeWidget _buildTitleAppBar(BuildContext context, String title) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  /// 根据索引导航到对应页面
  void _navigateToIndex(BuildContext context, int index) {
    final paths = ['/', '/category', '/discovery', '/study', '/profile'];
    context.go(paths[index]);
  }

  /// 获取页面标题
  String _getPageTitle(int index) {
    final titles = ['首页', '分类', '发现', '学习', '我的'];
    return titles[index];
  }
}

/// 发现页悬浮菜单 Widget
class _DiscoveryPopupMenu extends StatelessWidget {
  final Offset buttonOffset;
  final Size buttonSize;

  const _DiscoveryPopupMenu({
    required this.buttonOffset,
    required this.buttonSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const menuWidth = 140.0; // 缩小菜单宽度，和文字对齐

    // 计算菜单位置：紧贴按钮下方，右对齐
    final left = screenWidth - menuWidth - 16;
    final top = buttonOffset.dy + buttonSize.height + 8;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 点击遮罩关闭菜单
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
          ),
          // 菜单卡片
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {}, // 阻止事件传递到遮罩
              child: _buildMenuCard(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建菜单卡片
  Widget _buildMenuCard(BuildContext context) {
    return Container(
      width: 140, // 缩小菜单宽度，和文字对齐
      decoration: BoxDecoration(
        color: const Color(0xFF333333), // 深灰色背景
        borderRadius: BorderRadius.circular(14), // 14px圆角
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.05),
            BlendMode.srcOver,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                icon: Icons.search,
                title: '搜索',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/search');
                },
                showDivider: true,
              ),
              _buildMenuItem(
                icon: Icons.edit,
                title: '修改关注',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('修改关注功能待开发')),
                  );
                },
                showDivider: true,
              ),
              _buildMenuItem(
                icon: Icons.note,
                title: '我的手记',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('我的手记功能待开发')),
                  );
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}
