library;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_media/core_media.dart';
import 'package:ui_components/ui_components.dart';
import '../../../main.dart';
import 'models/course_chapter.dart';
import 'models/course_lesson.dart';
import 'data/course_chapter_data.dart';
import '../note/note_editor_page.dart';
import 'course_schedule_page.dart';
import 'course_download_page.dart';
import 'user_profile_page.dart';
import 'providers/free_course_play_provider.dart';


/// 免费课程播放页
///
/// 免费课程可以直接播放，无需购买
/// - 状态栏为黑色（暗色模式）
/// - 无顶部导航栏
/// - 视频播放器 + 标签容器
/// - 支持画中画模式
class FreeCoursePlayPage extends ConsumerStatefulWidget {
  /// 课程ID
  final String courseId;

  /// 课程标题
  final String title;

  /// 视频 URL
  final String videoUrl;

  /// 课程封面图
  final String coverImage;

  /// 恢复播放控制器（从悬浮窗返回时传入）
  final AppVideoPlayerController? restoreController;

  const FreeCoursePlayPage({
    super.key,
    required this.courseId,
    required this.title,
    required this.videoUrl,
    required this.coverImage,
    this.restoreController,
  });

  @override
  ConsumerState<FreeCoursePlayPage> createState() => _FreeCoursePlayPageState();
}

class _FreeCoursePlayPageState extends ConsumerState<FreeCoursePlayPage> {
  /// 视频播放器控制器
  AppVideoPlayerController? _videoController;

  /// 评论输入框控制器
  final TextEditingController _commentController = TextEditingController();

  /// 控制栏显示状态（默认显示）
  bool _showOverlay = true;

  /// 悬浮窗控制器
  FloatingVideoController? _floatingController;

  /// 控制器是否已转移到悬浮窗
  bool _controllerTransferred = false;

  /// PageView 滚动位置（0.0 - 1.0，用于下划线粘性动画插值）
  double _scrollPosition = 0.0;

  /// 标签列表
  final List<FixedTabItem> _tabs = const [
    FixedTabItem(id: 'chapter', title: '章节'),
    FixedTabItem(id: 'comment', title: '评论'),
    FixedTabItem(id: 'qa', title: '问答'),
    FixedTabItem(id: 'note', title: '笔记'),
  ];

  /// PageView 控制器（用于滑动切换标签）
  late PageController _pageController;

  /// 章节数据
  final List<CourseChapter> _chapters = courseChapterData;

  @override
  void initState() {
    super.initState();

    // 🔥 在第一帧构建后隐藏当前正在显示的悬浮窗（如果有的话）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FloatingVideoState().hideCurrentFloating();
    });

    // 初始化 PageController（使用 Provider 的初始值）
    final initialIndex = ref.read(freeCoursePlayCurrentTabIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
    // 监听 PageView 滑动，更新下划线动画
    _pageController.addListener(_onPageViewScroll);

    // 设置状态栏为黑色背景、白色文字
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark, // iOS: 状态栏内容为浅色
        statusBarIconBrightness: Brightness.light, // Android: 状态栏图标为白色
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    // 设置为边缘到边缘模式（保留状态栏）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 初始化视频控制器
    if (widget.restoreController != null) {
      // 从悬浮窗恢复
      _videoController = widget.restoreController;
      // 清除全局状态的引用，但不释放 controller（因为页面还在使用）
      FloatingVideoState().clearController(disposeController: false);
    } else {
      // 新建控制器
      _initializeVideo();
    }
  }

  /// 初始化视频播放器
  Future<void> _initializeVideo() async {
    final controller = await AppVideoPlayerController.network(widget.videoUrl);

    if (mounted) {
      setState(() {
        _videoController = controller;
        // 自动播放
        _videoController!.play();
      });
    }
  }

  @override
  void dispose() {
    // 隐藏悬浮窗
    _floatingController?.hide();
    // 移除 PageView 监听器
    _pageController.removeListener(_onPageViewScroll);
    // 释放 PageController
    _pageController.dispose();
    // 释放评论输入框控制器
    _commentController.dispose();
    // 恢复系统 UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    // 只有未转移到悬浮窗时才释放控制器
    if (!_controllerTransferred) {
      _videoController?.dispose();
    }
    super.dispose();
  }

  /// 监听 PageView 横向滚动，更新选中的标签和下划线动画
  void _onPageViewScroll() {
    if (!_pageController.hasClients || _tabs.isEmpty) return;

    final page = _pageController.page;
    if (page == null) return;

    final index = page.floor();
    final position = page - index;

    // 更新 Provider 状态
    ref.read(freeCoursePlayCurrentTabIndexProvider.notifier).state = index;

    // 更新本地滚动位置状态
    setState(() {
      _scrollPosition = position;
    });
  }

  /// 点击视频空白处 - 切换控制栏显示/隐藏
  void _onVideoTap() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  /// 返回按钮点击
  void _onBackTap() {
    Navigator.of(context).pop();
  }

  /// 收藏按钮点击
  void _onFavoriteTap() {
    // 从 Provider 读取当前值并切换
    final currentValue = ref.read(freeCoursePlayFavoriteProvider);
    final newValue = !currentValue;
    ref.read(freeCoursePlayFavoriteProvider.notifier).state = newValue;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newValue ? '已添加到收藏' : '已取消收藏'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 投屏按钮点击
  void _onCastTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('投屏功能待实现'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 字幕按钮点击
  void _onSubtitleTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('字幕功能待实现'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 更多按钮点击
  void _onMoreTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('更多功能待实现'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 悬浮按钮点击 - 开启画中画模式
  void _onFloatTap() {
    if (_videoController == null) return;

    // 创建悬浮窗控制器
    _floatingController = FloatingVideoController();

    // 保存控制器到全局状态
    FloatingVideoState().saveController(_videoController!, widget.videoUrl);

    // 标记控制器已转移
    _controllerTransferred = true;

    // 保存当前悬浮窗的 entry 引用
    OverlayEntry? floatingEntry;

    // 在闭包中保存 controller 的引用，避免使用可能为 null 的 _videoController
    final savedController = _videoController;
    final savedVideoUrl = widget.videoUrl;
    final savedCourseId = widget.courseId;
    final savedTitle = widget.title;
    final savedCoverImage = widget.coverImage;

    // 标记悬浮窗是否已关闭（避免重复操作）
    bool floatingWindowClosed = false;

    // 显示悬浮窗
    floatingEntry = showFloatingVideo(
      context: context,
      navigatorKey: navigatorKey,
      floatingOverlayManager: floatingOverlayManager, // 传入悬浮窗管理器
      controller: _videoController!,
      floatingController: _floatingController!,
      onBack: () {
        // 返回播放页面 - 使用 navigatorKey.currentContext 获取全局有效的 context
        final context = navigatorKey.currentContext;
        if (context == null) return;

        // 标记悬浮窗已关闭（这样 onClose 就不会再释放 controller）
        floatingWindowClosed = true;

        // 先关闭悬浮窗（如果还在的话）
        if (floatingEntry != null) {
          floatingOverlayManager.remove(floatingEntry!);
          floatingEntry = null;
        }

        // 直接使用原有的 controller 恢复播放页面
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FreeCoursePlayPage(
              courseId: savedCourseId,
              title: savedTitle,
              videoUrl: savedVideoUrl,
              coverImage: savedCoverImage,
              restoreController: savedController,
            ),
          ),
        );
      },
      onClose: () {
        // 关闭悬浮窗
        if (floatingWindowClosed) return; // 如果已经在 onBack 中处理过了，直接返回
        floatingWindowClosed = true;

        // 延迟释放 controller，确保悬浮窗 widget 已经完全移除
        // 使用 post-frame-callback 确保在当前帧完成后再释放
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 释放控制器（如果还在的话）
          if (savedController != null) {
            try {
              // 检查 controller 是否已经被释放
              if (savedController.isInitialized) {
                savedController.dispose();
              }
            } catch (e) {
              // 忽略释放错误
            }
          }

          // 清除全局状态
          FloatingVideoState().clearController(disposeController: false);
        });
      },
      autoDispose: false, // 手动管理释放
    );

    // 显示提示（在 pop 之前，因为 pop 后 context 会失效）
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('悬浮窗已显示，可拖拽到任意位置'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 关闭当前页面（悬浮窗接管）
    Navigator.of(context).pop();
  }

  /// 横竖屏切换
  void _onOrientationTap() {
    // 从 Provider 读取当前值并切换
    final currentValue = ref.read(freeCoursePlayIsLandscapeProvider);
    final newValue = !currentValue;
    ref.read(freeCoursePlayIsLandscapeProvider.notifier).state = newValue;

    // TODO: 实现实际的横竖屏切换逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newValue ? '切换到竖屏' : '切换到横屏'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听所有需要的状态
    final isFavorite = ref.watch(freeCoursePlayFavoriteProvider);
    final isLandscape = ref.watch(freeCoursePlayIsLandscapeProvider);
    final currentTabIndex = ref.watch(freeCoursePlayCurrentTabIndexProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _videoController == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
                // 视频播放器 - 宽度占满，高度根据16:9自动计算
                SafeArea(
                  bottom: false,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: FullVideoPlayer(
                      controller: _videoController!,
                      onBackgroundTap: _onVideoTap, // 点击空白处切换控制栏
                      showCenterPlayButton: false, // 禁用中央播放按钮
                      // 顶部悬浮层配置
                      showTopBar: _showOverlay,
                      topBarConfig: VideoTopBarConfig(
                        onBackTap: _onBackTap,
                        onCastTap: _onCastTap,
                        isFavorite: isFavorite,
                        onFavoriteTap: _onFavoriteTap,
                        onSubtitleTap: _onSubtitleTap,
                        onMoreTap: _onMoreTap,
                        spacing: 0,
                        iconSize: 24,
                        gradientBegin: const Color(0xCC000000),
                        gradientEnd: Colors.transparent,
                      ),
                      // 底部控制栏配置
                      showBottomBar: _showOverlay,
                      bottomBarConfig: VideoBottomBarConfig(
                        onFloatTap: _onFloatTap,
                        isLandscape: isLandscape,
                        onOrientationTap: _onOrientationTap,
                        spacing: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        progressBarColor: Colors.red,
                        gradientBegin: Colors.transparent,
                        gradientEnd: const Color(0xCC000000),
                        useSafeArea: false, // 禁用 SafeArea，避免底部额外间距
                      ),
                    ),
                  ),
                ),

                // 横向滑动标签容器
                _buildTabBar(currentTabIndex),

                // 标签内容区域
                Expanded(child: _buildTabContent()),
              ],
            ),
    );
  }

  /// 构建固定标签栏（不滑动）
  Widget _buildTabBar(int currentTabIndex) {
    return FixedTabs(
      tabs: _tabs,
      currentIndex: currentTabIndex,
      scrollPosition: _scrollPosition,
      onTap: (index) {
        // 使用 Provider 更新状态
        ref.read(freeCoursePlayCurrentTabIndexProvider.notifier).state = index;
        // 滑动 PageView 到对应页面
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      styleConfig: const FixedTabStyleConfig(
        selectedColor: Colors.red,
        unselectedColor: Colors.black,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        selectedFontWeight: FontWeight.w600,
        unselectedFontWeight: FontWeight.normal,
        indicatorWidth: 40,
        indicatorHeight: 3,
        indicatorGap: 8,
        useElasticAnimation: true,
      ),
      backgroundColor: Colors.white,
    );
  }

  /// 构建标签内容区域
  Widget _buildTabContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        // 使用 Provider 更新状态
        ref.read(freeCoursePlayCurrentTabIndexProvider.notifier).state = index;
      },
      children: [
        // 第1个标签：章节
        _buildChapterContent(),
        // 第2个标签：评论
        _buildCommentContent(),
        // 第3个标签：问答
        _buildQAContent(),
        // 第4个标签：笔记
        _buildNoteContent(),
      ],
    );
  }

  /// 构建章节内容
  Widget _buildChapterContent() {
    return Column(
      children: [
        // 章节列表（可滚动）
        Expanded(
          child: CustomScrollView(
            slivers: [
              // 头部信息（不吸顶）
              SliverToBoxAdapter(
                child: _buildCourseHeader(),
              ),
              // 章节列表（每个章节标题可吸顶）
              ..._buildChapterSections(),
            ],
          ),
        ),
        // 底部操作栏
        _buildChapterBottomBar(),
      ],
    );
  }

  /// 构建章节区域列表
  List<Widget> _buildChapterSections() {
    return _chapters.map((chapter) {
      return SliverMainAxisGroup(
        slivers: [
          // 吸顶章节标题
          SliverPersistentHeader(
            pinned: true, // 吸顶
            delegate: _ChapterHeaderDelegate(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                ),
                child: Text(
                  '${chapter.title} (${chapter.duration})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          // 课时列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: chapter.lessons.length,
              (context, index) {
                final lesson = chapter.lessons[index];
                return _buildLessonTile(lesson);
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  /// 构建课程头部信息
  Widget _buildCourseHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Text(
            'TypeScript极速入门',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          // 副标题 + 学习人数
          Row(
            children: [
              const Text(
                '初级',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              // 人数 icon
              const Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              // 人数
              const Text(
                '4490',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 进度条
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.0,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '0%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建章节列表
  Widget _buildChapterList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _chapters.length,
      itemBuilder: (context, index) {
        return _buildChapterSection(_chapters[index]);
      },
    );
  }

  /// 构建单个章节区域
  Widget _buildChapterSection(CourseChapter chapter) {
    return Column(
      children: [
        // 章节标题
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          child: Text(
            '${chapter.title} (${chapter.duration})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        // 课时列表
        ...chapter.lessons.map((lesson) => _buildLessonTile(lesson)),
      ],
    );
  }

  /// 构建课时列表项
  Widget _buildLessonTile(CourseLesson lesson) {
    // 判断是否正在播放
    final isPlaying = lesson.id == '1-1'; // 假设1-1正在播放

    return AppListTile(
      type: AppListTileType.basic,
      title: lesson.title,
      subtitle: lesson.duration,
      leading: Icon(
        Icons.play_circle_outline,
        size: 24,
        color: isPlaying ? Colors.red : Colors.grey,
      ),
      leadingColor: isPlaying ? Colors.red : Colors.grey,
      titleColor: isPlaying ? Colors.red : Colors.black,
      titleStyle: TextStyle(
        fontSize: 15,
        fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
      ),
      subtitleColor: Colors.grey,
      backgroundColor: Colors.white,
      hasDivider: true,
      dividerColor: Colors.grey.withValues(alpha: 0.2),  // 浅灰色
      dividerHeight: 1,  // 分隔线高度
      dividerIndent: 53,  // 左边缩进53
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      splashColor: Colors.grey.withValues(alpha: 0.3),  // 水波纹颜色
      highlightColor: Colors.grey.withValues(alpha: 0.1),  // 高亮颜色
      trailing: lesson.isRecent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '最近学习',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('播放: ${lesson.title}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  /// 构建评论内容
  Widget _buildCommentContent() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // 评论列表（可滚动）
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 1, // 只显示一条评论
              itemBuilder: (context, index) {
                return _buildCommentItem(index);
              },
            ),
          ),
          // 评论输入框
          _buildCommentBottomBar(),
        ],
      ),
    );
  }

  /// 构建问答内容
  Widget _buildQAContent() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // 问答列表（可滚动）
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildQAItem(index);
              },
            ),
          ),
          // 问答输入框
          _buildQABottomBar(),
        ],
      ),
    );
  }

  /// 构建笔记内容
  Widget _buildNoteContent() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // 笔记列表（可滚动）
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildNoteItem(index);
              },
            ),
          ),
          // 记笔记按钮
          _buildNoteBottomBar(),
        ],
      ),
    );
  }

  /// 构建单条评论
  Widget _buildCommentItem(int index) {
    return Column(
      children: [
        // 评论卡片 - 点击跳转到评论详情页
        InkWell(
          onTap: () {
            // 暂停视频
            _videoController?.pause();

            // 跳转到用户个人信息页（从右侧滑入）
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => UserProfilePage(
                  userId: 'user_001',
                  username: '慕盖茨6458881',
                  avatarUrl: 'assets/头像001.jpg',
                  coverUrl: widget.coverImage,
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // 从右侧滑入
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: InfoCard(
            avatar: 'assets/头像001.jpg', // 使用本地资源
            title: '慕盖茨6458881',
            subtitle: '2025-12-30',
            content: '老师讲的这不错，点赞',
            trailing: const _LikeButton(),
            padding: EdgeInsets.zero,
            spacing: 12,
          ),
        ),
        const SizedBox(height: 16),
        // 底部提示
        Center(
          child: Text(
            '已经到底部，没有更多内容了',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 构建问答条目
  Widget _buildQAItem(int index) {
    final questions = [
      {
        'avatar': 'https://via.placeholder.com/40',
        'username': '学员${index + 1}',
        'question': '老师，Flutter中的状态管理有哪些推荐方案？',
        'answer': 'Flutter中常用的状态管理方案有Provider、Riverpod、Bloc等，推荐根据项目规模选择。',
        'time': '1小时前',
        'likes': 8,
      },
    ];
    final qa = questions[0];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 问题部分
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 12),
              // 问题内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          qa['username'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '提问',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      qa['question'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 回答部分
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.question_answer,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '老师回答',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  qa['answer'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建笔记条目
  Widget _buildNoteItem(int index) {
    final notes = [
      {
        'title': '第1章笔记',
        'content': 'AI产品经理需要掌握的核心技能：\n1. 需求分析与产品设计\n2. 数据分析与用户研究\n3. AI技术理解与应用场景...',
        'time': '3小时前',
      },
    ];
    final note = notes[index % notes.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            note['title'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          // 内容
          Text(
            note['content'] as String,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 底部信息
          Row(
            children: [
              Text(
                note['time'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                '编辑',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 章节标签底部操作栏
  Widget _buildChapterBottomBar() {
    return BottomActionBar(
      config: BottomActionBarConfig(
        backgroundColor: Colors.white,
        topBorderColor: Colors.grey.withValues(alpha: 0.2),
        topBorderWidth: 1,
        horizontalPadding: 16,
        verticalPadding: 12,
        buttonSpacing: 16,
        primaryButton: PrimaryButtonConfig(
          icon: Icons.edit_note_outlined,
          label: '记笔记',
          iconSize: 20,
          iconColor: Colors.black,
          labelColor: Colors.black,
          labelFontSize: 16,
          borderColor: Colors.grey.withValues(alpha: 0.3),
          borderWidth: 1,
          borderRadius: 8,
          horizontalPadding: 24,
          verticalPadding: 12,
          iconTextSpacing: 8,
          onTap: () async {
            // 暂停视频
            _videoController?.pause();

            // 导航到笔记编辑器页面（从右侧滑入）
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const NoteEditorPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // 从右侧滑入
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );

            // 如果用户发布了笔记，result 会包含 Delta JSON
            if (result != null && result is String) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('笔记已保存'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        ),
        actionButtons: [
          ActionButtonConfig(
            icon: Icons.list_alt,
            label: '课表',
            isVertical: true,
            iconSize: 22,
            iconColor: Colors.black,
            labelColor: Colors.black,
            labelFontSize: 12,
            horizontalPadding: 8,
            verticalPadding: 8,
            verticalSpacing: 4,
            borderRadius: 8,
            onTap: () async {
              // 暂停视频播放
              _videoController?.pause();

              // 导航到课程表主页面
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CourseSchedulePage(),
                ),
              );
            },
          ),
          ActionButtonConfig(
            icon: Icons.download_outlined,
            label: '下载',
            isVertical: true,
            iconSize: 22,
            iconColor: Colors.black,
            labelColor: Colors.black,
            labelFontSize: 12,
            horizontalPadding: 8,
            verticalPadding: 8,
            verticalSpacing: 4,
            borderRadius: 8,
            onTap: () async {
              // 暂停视频播放
              _videoController?.pause();

              // 导航到下载页面
              await Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const CourseDownloadPage(),
                ),
              );
            },
          ),
          ActionButtonConfig(
            icon: Icons.share_outlined,
            label: '分享',
            isVertical: true,
            iconSize: 22,
            iconColor: Colors.black,
            labelColor: Colors.black,
            labelFontSize: 12,
            horizontalPadding: 8,
            verticalPadding: 8,
            verticalSpacing: 4,
            borderRadius: 8,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('分享课程'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 评论标签底部输入栏
  Widget _buildCommentBottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 输入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _commentController,
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '说点什么吧',
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('评论已提交: $text'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      _commentController.clear();
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 发送按钮
            _PublishButton(controller: _commentController),
          ],
        ),
      ),
    );
  }

  /// 问答标签底部输入栏
  Widget _buildQABottomBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 输入框
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '写下你的问题...',
                    hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('问题已提交: $text'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 提问按钮
            Text(
              '提问',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 笔记标签底部操作栏
  Widget _buildNoteBottomBar() {
    return BottomActionBar(
      config: BottomActionBarConfig(
        backgroundColor: Colors.white,
        topBorderColor: Colors.grey.withValues(alpha: 0.2),
        topBorderWidth: 1,
        horizontalPadding: 16,
        verticalPadding: 12,
        buttonSpacing: 16,
        primaryButton: PrimaryButtonConfig(
          icon: Icons.edit_note_outlined,
          label: '记笔记',
          iconSize: 20,
          iconColor: Colors.black,
          labelColor: Colors.black,
          labelFontSize: 16,
          borderColor: Colors.grey.withValues(alpha: 0.3),
          borderWidth: 1,
          borderRadius: 8,
          horizontalPadding: 24,
          verticalPadding: 12,
          iconTextSpacing: 8,
          onTap: () async {
            // 暂停视频
            _videoController?.pause();

            // 导航到笔记编辑器页面（从右侧滑入）
            final result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const NoteEditorPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // 从右侧滑入
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );

            // 如果用户发布了笔记，result 会包含 Delta JSON
            if (result != null && result is String) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('笔记已保存'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

/// 章节标题栏代理（用于吸顶效果）
class _ChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChapterHeaderDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 48.0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_ChapterHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

/// 评论发送按钮
class _PublishButton extends StatefulWidget {
  final TextEditingController? controller;

  const _PublishButton({this.controller});

  @override
  State<_PublishButton> createState() => _PublishButtonState();
}

class _PublishButtonState extends State<_PublishButton> {
  @override
  void initState() {
    super.initState();
    // 监听输入框变化
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // 刷新按钮状态
  }

  bool get _isEmpty {
    return widget.controller?.text.trim().isEmpty ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '发送',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: _isEmpty ? Colors.grey.shade500 : Colors.red,
      ),
    );
  }
}

/// 点赞按钮
class _LikeButton extends StatefulWidget {
  const _LikeButton();

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 16,
            color: _isLiked ? Colors.red : Colors.grey.shade500,
          ),
          if (_likeCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$_likeCount',
              style: TextStyle(
                fontSize: 12,
                color: _isLiked ? Colors.red : Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
