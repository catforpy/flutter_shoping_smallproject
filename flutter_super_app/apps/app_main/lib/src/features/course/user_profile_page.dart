library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_components/ui_components.dart';
import 'providers/user_profile_provider.dart';

/// 用户个人信息页
///
/// 特性：
/// - 透明状态栏和导航栏
/// - 全屏背景图
/// - 滚动动画效果（导航栏毛玻璃渐显）
/// - 吸顶标签栏
class UserProfilePage extends ConsumerStatefulWidget {
  /// 用户 ID
  final String userId;

  /// 用户名
  final String username;

  /// 头像 URL
  final String avatarUrl;

  /// 背景图 URL
  final String? coverUrl;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    this.coverUrl,
  });

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  /// ScrollController（用于监听页面垂直滚动）
  final ScrollController _scrollController = ScrollController();

  /// 标签页 PageView 控制器
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // 监听页面垂直滚动，更新滚动进度和动画效果
    _scrollController.addListener(_onScroll);
    // 初始化标签页控制器
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// 监听页面垂直滚动，计算滚动进度
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    const maxHeight = 200.0; // 最大滚动距离
    final offset = _scrollController.offset;
    final progress = (offset / maxHeight).clamp(0.0, 1.0);

    // 使用 Riverpod Provider 更新滚动进度
    ref.read(userProfileScrollProgressProvider.notifier).state = progress;
  }

  @override
  Widget build(BuildContext context) {
    // 监听滚动进度
    final scrollProgress = ref.watch(userProfileScrollProgressProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // 使用图片作为背景
        body: Stack(
          children: [
          // === 固定的全屏背景图 ===
          Positioned.fill(
            child: Image.network(
              'https://picsum.photos/400/800?random=${widget.userId.hashCode}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return CachedNetworkImage(
                  imageUrl: widget.coverUrl ?? widget.avatarUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade400,
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // === 毛玻璃遮罩层（让背景图变暗，突出内容）===
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),

          // === 可滚动内容区域 ===
          Column(
            children: [
              // === 固定的顶部导航栏（带毛玻璃渐显动画，覆盖状态栏）===
              _buildNavigationBar(scrollProgress),

              // === 可滚动内容 ===
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // 顶部间距（可滚动）
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 50),
                    ),
                    // 白色内容卡片
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            // 用户信息卡片
                            _buildUserInfoCard(),
                          ],
                        ),
                      ),
                    ),
                    // 标签栏（吸顶）
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        child: _buildTabBar(),
                      ),
                    ),
                    // 内容列表（白色背景，使用 PageView）
                    SliverFillRemaining(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _TabPageContent(child: _HomePageContent()),
                          _TabPageContent(child: _CoursesContent()),
                          _TabPageContent(child: _ReviewsContent()),
                          _TabPageContent(child: _ArticlesContent()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// 构建导航栏（带毛玻璃渐显动画，覆盖状态栏区域）
  Widget _buildNavigationBar(double scrollProgress) {
    // 获取状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // 总高度 = 状态栏高度 + 导航栏高度
    final totalHeight = statusBarHeight + 56;

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 10 * scrollProgress,
          sigmaY: 10 * scrollProgress,
        ),
        child: Container(
          height: totalHeight,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: statusBarHeight, // 内容从状态栏下方开始
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: scrollProgress.clamp(0.0, 0.95)),
          ),
          child: Row(
            children: [
              // 返回按钮
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Color.lerp(Colors.white, Colors.black, scrollProgress),
                ),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              // 标题
              Text(
                widget.username,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.lerp(Colors.white, Colors.black, scrollProgress),
                ),
              ),
              const Spacer(),
              // 更多按钮
              IconButton(
                icon: Icon(
                  Icons.more_horiz,
                  color: Color.lerp(Colors.white, Colors.black, scrollProgress),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('更多功能待实现'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 补偿头像向上移动的空间
          const SizedBox(height: 20),
          // 头像（向上移动，突出到卡片外）
          Transform.translate(
            offset: const Offset(0, -40),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/头像001.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 40),
                    );
                  },
                ),
              ),
            ),
          ),
          // const SizedBox(height: 12),
          // 用户名、签名和关注按钮
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名和签名
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '这位同学很懒，木有签名的说~',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 关注按钮
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('关注功能待实现'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '+ 关注',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 成长数据
          const Text(
            '成长数据',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildGrowthItem('累计学习', '2小时'),
          const SizedBox(height: 12),
          _buildGrowthItem('获得经验值', '80'),
          const SizedBox(height: 12),
          _buildGrowthItem('累积获得证书', '0张'),
          const SizedBox(height: 12),
          _buildGrowthItem('已在慕课网学习', '1871天'),
        ],
      ),
    );
  }

  /// 构建成长数据项
  Widget _buildGrowthItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return CourseDetailTabBar(
      tabs: userProfileTabs,
      pageController: _pageController,
      onTap: (index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      topBorderRadius: 0,
      horizontalMargin: 0,
    );
  }
}

/// 标签页内容包装器
class _TabPageContent extends StatelessWidget {
  final Widget child;

  const _TabPageContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// 主页内容
class _HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '动态 ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这是一条动态内容...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 在学课程内容
class _CoursesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '在学课程 ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这是一门课程的简介...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 参与评价内容
class _ReviewsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '课程评价 ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这是一条课程评价内容...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 文章内容
class _ArticlesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '文章 ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '这是一篇文章的摘要...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// SliverPersistentHeader 代理，用于吸顶标签栏
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
