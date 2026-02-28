import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// 四级嵌套路由示例 - 简化版
///
/// 使用 StatefulShellRoute 正确实现四级嵌套：
/// Level 1: 顶部横向滑动标签（推荐、关注、直播）
/// Level 2: 左侧纵向滑动标签（首页、视频、游戏、生活）
/// Level 3: 内容区顶部横向标签（最新、最热、精选）
/// Level 4: 瀑布流错落式卡片内容
class FourLevelNestedRoutes extends StatefulWidget {
  const FourLevelNestedRoutes({super.key});

  @override
  State<FourLevelNestedRoutes> createState() => _FourLevelNestedRoutesState();
}

class _FourLevelNestedRoutesState extends State<FourLevelNestedRoutes> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '四级嵌套路由示例',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/recommend/home/latest',
      debugLogDiagnostics: true,
      routes: [
        // 最外层 - 使用 GoRoute 而不是 StatefulShellRoute
        // 这样可以更好地控制所有层级的显示
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _FourLevelShell(),
          ),
          routes: [
            // 所有路由都在这个 shell 下面
            GoRoute(
              path: ':level1/:level2/:level3',
              pageBuilder: (context, state) {
                final level1 = state.pathParameters['level1'] ?? 'recommend';
                final level2 = state.pathParameters['level2'] ?? 'home';
                final level3 = state.pathParameters['level3'] ?? 'latest';

                return NoTransitionPage(
                  child: _FourLevelPage(
                    level1Path: level1,
                    level2Path: level2,
                    level3Path: level3,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// 四级外壳 - 显示所有层级
class _FourLevelShell extends StatelessWidget {
  const _FourLevelShell();

  @override
  Widget build(BuildContext context) {
    // 这个 shell 只负责显示子路由
    // 实际的四级导航在 _FourLevelPage 中
    return const SizedBox.shrink();
  }
}

/// 四级页面 - 完整显示所有四级嵌套
class _FourLevelPage extends StatefulWidget {
  final String level1Path;
  final String level2Path;
  final String level3Path;

  const _FourLevelPage({
    required this.level1Path,
    required this.level2Path,
    required this.level3Path,
  });

  @override
  State<_FourLevelPage> createState() => _FourLevelPageState();
}

class _FourLevelPageState extends State<_FourLevelPage> {
  // Level 1 数据
  final List<_Level1Item> _level1Items = const [
    _Level1Item(label: '推荐', path: 'recommend'),
    _Level1Item(label: '关注', path: 'following'),
    _Level1Item(label: '直播', path: 'live'),
  ];

  // Level 2 数据
  final List<_Level2Item> _level2Items = const [
    _Level2Item(label: '首页', icon: Icons.home, path: 'home'),
    _Level2Item(label: '视频', icon: Icons.video_library, path: 'video'),
    _Level2Item(label: '游戏', icon: Icons.sports_esports, path: 'game'),
    _Level2Item(label: '生活', icon: Icons.local_dining, path: 'life'),
    _Level2Item(label: '科技', icon: Icons.science, path: 'tech'),
    _Level2Item(label: '体育', icon: Icons.sports_basketball, path: 'sports'),
  ];

  // Level 3 数据
  final List<_Level3Item> _level3Items = const [
    _Level3Item(label: '最新', path: 'latest'),
    _Level3Item(label: '最热', path: 'hottest'),
    _Level3Item(label: '精选', path: 'selected'),
    _Level3Item(label: '关注', path: 'following'),
  ];

  late int _level1Index;
  late int _level2Index;
  late int _level3Index;

  @override
  void initState() {
    super.initState();
    _updateIndexes();
  }

  @override
  void didUpdateWidget(_FourLevelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level1Path != widget.level1Path ||
        oldWidget.level2Path != widget.level2Path ||
        oldWidget.level3Path != widget.level3Path) {
      setState(() {
        _updateIndexes();
      });
    }
  }

  void _updateIndexes() {
    _level1Index = _level1Items.indexWhere((item) => item.path == widget.level1Path);
    if (_level1Index < 0) _level1Index = 0;

    _level2Index = _level2Items.indexWhere((item) => item.path == widget.level2Path);
    if (_level2Index < 0) _level2Index = 0;

    _level3Index = _level3Items.indexWhere((item) => item.path == widget.level3Path);
    if (_level3Index < 0) _level3Index = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Level 1: 顶部横向滑动标签
          _buildLevel1Tabs(),
          // Level 2 + Level 3 + Level 4
          Expanded(
            child: Row(
              children: [
                // Level 2: 左侧纵向滑动标签
                _buildLevel2Nav(),
                // Level 3 + Level 4
                Expanded(
                  child: Column(
                    children: [
                      // Level 3: 内容区顶部横向标签
                      _buildLevel3Tabs(),
                      // Level 4: 瀑布流内容
                      Expanded(
                        child: _WaterfallContent(
                          level3Tab: _level3Items[_level3Index].label,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Level 1: 顶部横向滑动标签
  Widget _buildLevel1Tabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _level1Items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final item = _level1Items[index];
          final isSelected = _level1Index == index;
          return Center(
            child: InkWell(
              onTap: () => _navigateLevel1(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Level 2: 左侧纵向滑动标签
  Widget _buildLevel2Nav() {
    return SizedBox(
      width: 90,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            right: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _level2Items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final item = _level2Items[index];
            final isSelected = _level2Index == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(
                horizontal: isSelected ? 4 : 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ListTile(
                dense: true,
                leading: Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey[700],
                  ),
                ),
                selected: isSelected,
                selectedTileColor: Colors.transparent,
                onTap: () => _navigateLevel2(index),
              ),
            );
          },
        ),
      ),
    );
  }

  // Level 3: 内容区顶部横向标签
  Widget _buildLevel3Tabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _level3Items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = _level3Items[index];
          final isSelected = _level3Index == index;

          return Center(
            child: InkWell(
              onTap: () => _navigateLevel3(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateLevel1(int index) {
    final level2 = _level2Items[_level2Index].path;
    final level3 = _level3Items[_level3Index].path;
    context.go('/${_level1Items[index].path}/$level2/$level3');
  }

  void _navigateLevel2(int index) {
    final level1 = _level1Items[_level1Index].path;
    final level3 = _level3Items[_level3Index].path;
    context.go('/$level1/${_level2Items[index].path}/$level3');
  }

  void _navigateLevel3(int index) {
    final level1 = _level1Items[_level1Index].path;
    final level2 = _level2Items[_level2Index].path;
    context.go('/$level1/$level2/${_level3Items[index].path}');
  }
}

// 数据模型类
class _Level1Item {
  final String label;
  final String path;
  const _Level1Item({required this.label, required this.path});
}

class _Level2Item {
  final String label;
  final IconData icon;
  final String path;
  const _Level2Item({required this.label, required this.icon, required this.path});
}

class _Level3Item {
  final String label;
  final String path;
  const _Level3Item({required this.label, required this.path});
}

/// Level 4: 瀑布流错落式卡片内容
class _WaterfallContent extends StatefulWidget {
  final String level3Tab;

  const _WaterfallContent({required this.level3Tab});

  @override
  State<_WaterfallContent> createState() => _WaterfallContentState();
}

class _WaterfallContentState extends State<_WaterfallContent> {
  final ScrollController _scrollController = ScrollController();
  final List<_WaterfallItem> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final newItems = List.generate(
      20,
      (index) {
        // 生成不同高度的卡片，真正实现错落式布局
        final heightVariants = [140, 180, 220, 260, 300];
        final height = heightVariants[index % heightVariants.length];

        // 只有部分卡片有描述，增加错落感
        final hasDescription = index % 3 == 0;
        final descriptions = [
          '这是一个非常有趣的内容分享',
          '热门推荐，不容错过',
          '精彩内容，值得关注',
          '最新动态，欢迎观看',
          null,
          null,
        ];
        final description = hasDescription
            ? descriptions[index % descriptions.length]
            : null;

        return _WaterfallItem(
          id: '$_currentPage\_$index',
          title: '${widget.level3Tab}内容 ${(_currentPage - 1) * 20 + index + 1}',
          description: description,
          height: height,
          color: Colors.primaries[index % Colors.primaries.length],
          imageUrl: 'https://picsum.photos/300/$height?random=$_currentPage\_$index',
        );
      },
    );

    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    _currentPage++;
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildCard(_items[index]);
            },
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(_WaterfallItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onCardTap(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片区域 - 高度根据 item.height 变化
            Container(
              height: item.height.toDouble(),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.color.withValues(alpha: 0.6),
                    item.color.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getIconForColor(item.color),
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            // 内容区域 - 使用 IntrinsicHeight 避免溢出
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题 - 限制行数避免溢出
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 描述 - 可选，有些卡片有，有些没有
                  if (item.description != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // 统计信息
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatNumber(_randomLikes(item)),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.comment_outlined,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatNumber(_randomComments(item)),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toString();
  }

  IconData _getIconForColor(MaterialColor color) {
    if (color == Colors.red) return Icons.favorite;
    if (color == Colors.blue) return Icons.beach_access;
    if (color == Colors.green) return Icons.nature;
    if (color == Colors.orange) return Icons.local_fire_department;
    if (color == Colors.purple) return Icons.auto_awesome;
    if (color == Colors.teal) return Icons.wb_sunny;
    return Icons.stars;
  }

  int _randomLikes(_WaterfallItem item) => 100 + (item.id.hashCode % 900);
  int _randomComments(_WaterfallItem item) => 10 + (item.id.hashCode % 100);

  void _onCardTap(_WaterfallItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('点击了：${item.title}'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: '查看',
          onPressed: () {},
        ),
      ),
    );
  }
}

class _WaterfallItem {
  final String id;
  final String title;
  final String? description;
  final int height;
  final MaterialColor color;
  final String imageUrl;

  _WaterfallItem({
    required this.id,
    required this.title,
    this.description,
    required this.height,
    required this.color,
    required this.imageUrl,
  });
}
