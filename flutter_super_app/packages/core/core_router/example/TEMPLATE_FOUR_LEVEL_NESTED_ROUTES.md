# 四级嵌套路由 + 瀑布流错落卡片 - 核心模板

> 📌 **重要性**: ⭐⭐⭐⭐⭐
> 这是一个非常通用且重要的组合模板，可以在很多项目中直接套用！

---

## 📦 依赖配置

### 1. pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.6.2
  flutter_staggered_grid_view: ^0.7.0  # 瀑布流错落布局
```

---

## 🎯 完整实现代码

### 核心结构

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
```

### 1. 数据模型类

```dart
// ========== 数据模型 ==========

/// Level 1 项（顶部横向标签）
class Level1Item {
  final String label;
  final String path;
  const Level1Item({required this.label, required this.path});
}

/// Level 2 项（左侧纵向菜单）
class Level2Item {
  final String label;
  final IconData icon;
  final String path;
  const Level2Item({required this.label, required this.icon, required this.path});
}

/// Level 3 项（内容区横向标签）
class Level3Item {
  final String label;
  final String path;
  const Level3Item({required this.label, required this.path});
}

/// Level 4 瀑布流卡片项
class WaterfallCardItem {
  final String id;
  final String title;
  final String? description;  // 可选描述
  final int height;           // 卡片高度
  final MaterialColor color;
  final String imageUrl;

  WaterfallCardItem({
    required this.id,
    required this.title,
    this.description,
    required this.height,
    required this.color,
    required this.imageUrl,
  });
}
```

### 2. 路由配置

```dart
// ========== 路由配置 ==========

class FourLevelNestedApp extends StatefulWidget {
  const FourLevelNestedApp({super.key});

  @override
  State<FourLevelNestedApp> createState() => _FourLevelNestedAppState();
}

class _FourLevelNestedAppState extends State<FourLevelNestedApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '四级嵌套路由',
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/recommend/home/latest',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FourLevelShell(),
          ),
          routes: [
            GoRoute(
              path: ':level1/:level2/:level3',
              pageBuilder: (context, state) {
                final level1 = state.pathParameters['level1'] ?? 'recommend';
                final level2 = state.pathParameters['level2'] ?? 'home';
                final level3 = state.pathParameters['level3'] ?? 'latest';

                return NoTransitionPage(
                  child: FourLevelPage(
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
```

### 3. 四级页面主组件

```dart
// ========== 四级页面主组件 ==========

class FourLevelPage extends StatefulWidget {
  final String level1Path;
  final String level2Path;
  final String level3Path;

  const FourLevelPage({
    super.key,
    required this.level1Path,
    required this.level2Path,
    required this.level3Path,
  });

  @override
  State<FourLevelPage> createState() => _FourLevelPageState();
}

class _FourLevelPageState extends State<FourLevelPage> {
  // ========== 配置数据 ==========

  // Level 1 数据
  final List<Level1Item> level1Items = const [
    Level1Item(label: '推荐', path: 'recommend'),
    Level1Item(label: '关注', path: 'following'),
    Level1Item(label: '直播', path: 'live'),
  ];

  // Level 2 数据
  final List<Level2Item> level2Items = const [
    Level2Item(label: '首页', icon: Icons.home, path: 'home'),
    Level2Item(label: '视频', icon: Icons.video_library, path: 'video'),
    Level2Item(label: '游戏', icon: Icons.sports_esports, path: 'game'),
    Level2Item(label: '生活', icon: Icons.local_dining, path: 'life'),
    Level2Item(label: '科技', icon: Icons.science, path: 'tech'),
    Level2Item(label: '体育', icon: Icons.sports_basketball, path: 'sports'),
  ];

  // Level 3 数据
  final List<Level3Item> level3Items = const [
    Level3Item(label: '最新', path: 'latest'),
    Level3Item(label: '最热', path: 'hottest'),
    Level3Item(label: '精选', path: 'selected'),
    Level3Item(label: '关注', path: 'following'),
  ];

  // 当前选中索引
  late int level1Index;
  late int level2Index;
  late int level3Index;

  @override
  void initState() {
    super.initState();
    _updateIndexes();
  }

  @override
  void didUpdateWidget(FourLevelPage oldWidget) {
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
    level1Index = level1Items.indexWhere((item) => item.path == widget.level1Path);
    if (level1Index < 0) level1Index = 0;

    level2Index = level2Items.indexWhere((item) => item.path == widget.level2Path);
    if (level2Index < 0) level2Index = 0;

    level3Index = level3Items.indexWhere((item) => item.path == widget.level3Path);
    if (level3Index < 0) level3Index = 0;
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
                        child: WaterfallContent(
                          level3Tab: level3Items[level3Index].label,
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

  // ========== Level 1: 顶部横向滑动标签 ==========
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
        itemCount: level1Items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final item = level1Items[index];
          final isSelected = level1Index == index;
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

  // ========== Level 2: 左侧纵向滑动标签 ==========
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
          itemCount: level2Items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final item = level2Items[index];
            final isSelected = level2Index == index;

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

  // ========== Level 3: 内容区顶部横向标签 ==========
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
        itemCount: level3Items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = level3Items[index];
          final isSelected = level3Index == index;

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

  // ========== 导航方法 ==========
  void _navigateLevel1(int index) {
    final level2 = level2Items[level2Index].path;
    final level3 = level3Items[level3Index].path;
    context.go('/${level1Items[index].path}/$level2/$level3');
  }

  void _navigateLevel2(int index) {
    final level1 = level1Items[level1Index].path;
    final level3 = level3Items[level3Index].path;
    context.go('/$level1/${level2Items[index].path}/$level3');
  }

  void _navigateLevel3(int index) {
    final level1 = level1Items[level1Index].path;
    final level2 = level2Items[level2Index].path;
    context.go('/$level1/$level2/${level3Items[index].path}');
  }
}
```

### 4. 瀑布流内容组件（Level 4）

```dart
// ========== Level 4: 瀑布流错落式卡片内容 ==========

class WaterfallContent extends StatefulWidget {
  final String level3Tab;

  const WaterfallContent({super.key, required this.level3Tab});

  @override
  State<WaterfallContent> createState() => _WaterfallContentState();
}

class _WaterfallContentState extends State<WaterfallContent> {
  final ScrollController _scrollController = ScrollController();
  final List<WaterfallCardItem> _items = [];
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

  // ========== 滚动监听 ==========
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  // ========== 加载数据 ==========
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求
    await Future.delayed(const Duration(milliseconds: 500));

    final newItems = List.generate(
      20,
      (index) {
        // 🔑 关键：生成不同高度的卡片，实现错落式布局
        final heightVariants = [140, 180, 220, 260, 300];
        final height = heightVariants[index % heightVariants.length];

        // 🔑 关键：只有部分卡片有描述，增加错落感
        final hasDescription = index % 3 == 0;
        final descriptions = [
          '这是一个非常有趣的内容分享',
          '热门推荐，不容错过',
          '精彩内容，值得关注',
          null,  // 无描述
          null,
        ];
        final description = hasDescription
            ? descriptions[index % descriptions.length]
            : null;

        return WaterfallCardItem(
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
          // 🔑 核心：使用 MasonryGridView 实现错落式瀑布流
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,           // 2列
            mainAxisSpacing: 8,           // 垂直间距
            crossAxisSpacing: 8,          // 水平间距
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildCard(_items[index]);
            },
          ),
          // 加载更多指示器
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

  // ========== 卡片组件 ==========
  Widget _buildCard(WaterfallCardItem item) {
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
          mainAxisSize: MainAxisSize.min,  // 🔑 重要：避免内容溢出
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
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,  // 🔑 重要：避免内容溢出
                children: [
                  // 标题 - 限制行数避免溢出
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,  // 🔑 最多2行
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // 描述 - 可选
                  if (item.description != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,  // 🔑 最多2行
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // 统计信息
                  Row(
                    mainAxisSize: MainAxisSize.min,  // 🔑 重要：避免溢出
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

  // ========== 辅助方法 ==========

  IconData _getIconForColor(MaterialColor color) {
    if (color == Colors.red) return Icons.favorite;
    if (color == Colors.blue) return Icons.beach_access;
    if (color == Colors.green) return Icons.nature;
    if (color == Colors.orange) return Icons.local_fire_department;
    if (color == Colors.purple) return Icons.auto_awesome;
    if (color == Colors.teal) return Icons.wb_sunny;
    return Icons.stars;
  }

  String _formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}k';
    }
    return num.toString();
  }

  int _randomLikes(WaterfallCardItem item) => 100 + (item.id.hashCode % 900);
  int _randomComments(WaterfallCardItem item) => 10 + (item.id.hashCode % 100);

  void _onCardTap(WaterfallCardItem item) {
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
```

---

## 🔑 关键要点总结

### 1. 瀑布流错落布局（最重要！）

```dart
// 依赖
flutter_staggered_grid_view: ^0.7.0

// 使用
MasonryGridView.count(
  crossAxisCount: 2,              // 列数
  mainAxisSpacing: 8,              // 行间距
  crossAxisSpacing: 8,             // 列间距
  itemBuilder: (context, index) {
    return _buildCard(items[index]);
  },
)
```

### 2. 实现错落效果的技巧

```dart
// 技巧1：定义多种高度
final heightVariants = [140, 180, 220, 260, 300];
final height = heightVariants[index % heightVariants.length];

// 技巧2：部分卡片有描述，部分没有
final hasDescription = index % 3 == 0;
final description = hasDescription ? "描述文字" : null;
```

### 3. 避免内容溢出

```dart
// 关键3个设置：
Column(
  mainAxisSize: MainAxisSize.min,  // 1. Column使用min
  children: [
    Text(..., maxLines: 2, overflow: TextOverflow.ellipsis),  // 2. 文字限制行数
    Row(mainAxisSize: MainAxisSize.min),  // 3. Row也使用min
  ],
)
```

### 4. 四级嵌套路由结构

```
/ (根路由)
└─ :level1/:level2/:level3  (三个路径参数)
   ├─ level1: 推荐/关注/直播
   ├─ level2: 首页/视频/游戏/生活
   └─ level3: 最新/最热/精选
```

### 5. 导航方法

```dart
// 切换任意一级时，保持其他两级不变
void _navigateLevel1(int index) {
  final level2 = level2Items[level2Index].path;
  final level3 = level3Items[level3Index].path;
  context.go('/${level1Items[index].path}/$level2/$level3');
}
```

### 6. 分页加载

```dart
// 滚动监听
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent * 0.8) {  // 80%位置触发
    _loadMore();
  }
}
```

---

## 📐 布局示意图

```
┌─────────────────────────────────────────────────────┐
│ Level 1: 推荐 | 关注 | 直播 (横向)                  │
├─────────────────────────────────────────────────────┤
│ ┌────────┬─────────────────────────────────────────┐│
│ │Level 2 │ Level 3: 最新 | 最热 | 精选 (横向)    ││
│ │左侧    ├─────────────────────────────────────────┤│
│ │纵向    │ Level 4: 瀑布流内容                  ││
│ │菜单    │ ┌────┐ ┌─────┐                        ││
│ │首页   │ │卡片│ │卡片 │  (错落式布局)        ││
│ │视频   │ │(短)│ │(长) │                        ││
│ │游戏   │ └────┘ └─────┘                        ││
│ │生活   │ ┌─────┐ ┌────┐                        ││
│ │科技   │ │卡片 │ │卡片 │                        ││
│ │体育   │ │(中) │ │(短)│                        ││
│ └────────┴─────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘
```

---

## 🎨 可定制项

### 颜色主题
```dart
// 修改选中颜色
color: isSelected ? Colors.blue : Colors.grey[700]

// 修改背景色
color: isSelected ? Colors.blue[50] : Colors.transparent
```

### 尺寸调整
```dart
// Level 1 高度
height: 50

// Level 2 宽度
width: 90

// Level 3 高度
height: 48

// 网格间距
mainAxisSpacing: 8,
crossAxisSpacing: 8,

// 卡片高度变化
heightVariants = [140, 180, 220, 260, 300];
```

### 分页触发位置
```dart
// 滚动到 80% 触发加载
_scrollController.position.maxScrollExtent * 0.8

// 改为 90% 触发
_scrollController.position.maxScrollExtent * 0.9
```

---

## 🚀 快速使用指南

### 1. 复制整个文件
直接复制 `four_level_nested_routes.dart` 到你的项目

### 2. 修改数据
```dart
// 修改 Level 1 数据
final List<Level1Item> level1Items = const [
  Level1Item(label: '你的标签', path: 'your-path'),
  // ...
];

// 修改 Level 2 数据
final List<Level2Item> level2Items = const [
  Level2Item(label: '你的菜单', icon: Icons.your_icon, path: 'your-path'),
  // ...
];
```

### 3. 接入真实数据
```dart
// 替换 _loadItems() 中的模拟数据
Future<void> _loadItems() async {
  final response = await yourApiService.fetchData(
    page: _currentPage,
    level3: widget.level3Tab,
  );

  final newItems = response.data.map((json) {
    return WaterfallCardItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      height: json['height'] ?? 200,
      color: _getColor(json['color']),
      imageUrl: json['image_url'],
    );
  }).toList();

  setState(() {
    _items.addAll(newItems);
    _isLoading = false;
  });
}
```

---

## 📝 常见问题

### Q1: 如何改变列数？
```dart
MasonryGridView.count(
  crossAxisCount: 2,  // 改为 3 就是3列
)
```

### Q2: 如何改变卡片高度范围？
```dart
final heightVariants = [100, 150, 200, 250];  // 自定义高度
```

### Q3: 如何添加更多级别？
在这个模板基础上，可以继续添加 Level 5、Level 6，原理相同。

### Q4: 如何替换为真实图片？
```dart
Image.network(
  item.imageUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(color: Colors.grey[300]);
  },
)
```

---

## 💡 最佳实践

1. ✅ **使用 MasonryGridView** 实现真正的错落布局
2. ✅ **使用 mainAxisSize: MainAxisSize.min** 避免内容溢出
3. ✅ **限制文字行数** (maxLines: 2) 防止溢出
4. ✅ **使用 TextOverflow.ellipsis** 处理过长文字
5. ✅ **分页加载** 提升性能和用户体验
6. ✅ **URL 路径参数** 传递导航状态

---

**模板位置**: `/example/lib/four_level_nested_routes.dart`
**最后更新**: 2026-02-25
**适用场景**: 内容类应用、电商、社交、媒体等几乎所有需要展示内容列表的应用
