# 嵌套路由使用指南

> 本指南介绍如何使用 core_router 的嵌套路由功能

---

## 📚 目录

1. [什么是嵌套路由](#什么是嵌套路由)
2. [基础嵌套路由](#基础嵌套路由)
3. [外壳路由（ShellRoute）](#外壳路由shellroute)
4. [多层嵌套](#多层嵌套)
5. [实际案例](#实际案例)

---

## 什么是嵌套路由？

**嵌套路由** = 父路由提供外壳布局，子路由提供内容

```
┌─────────────────────────────────┐
│ 外壳（固定不重建）               │
│ ┌─────────────────────────────┐ │
│ │ 左侧导航栏（固定）           │ │
│ ├─────────────────────────────┤ │
│ │ 内容区域（子路由切换）       │ │
│ │ - /home → HomePage          │ │
│ │ - /video → VideoPage        │ │
│ │ - /profile → ProfilePage    │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**好处：**
- ✅ 左侧导航栏不重建，性能更好
- ✅ 导航栏状态（滚动位置、选中项）保持
- ✅ URL 自动同步
- ✅ 支持深度链接

---

## 基础嵌套路由

### 配置父路由和子路由

```dart
import 'package:core_router/core_router.dart';

// 定义子路由
final homeRoute = AppRoute(
  path: 'home',
  name: 'home',
  builder: (context, state) => const HomePage(),
);

final videoRoute = AppRoute(
  path: 'video',
  name: 'video',
  builder: (context, state) => const VideoPage(),
);

final profileRoute = AppRoute(
  path: 'profile',
  name: 'profile',
  builder: (context, state) => const ProfilePage(),
);

// 定义父路由（带子路由）
final mainRoute = AppRoute(
  path: '/',
  name: 'main',
  builder: (context, state) {
    // 父路由提供外壳布局
    return Scaffold(
      body: Row([
        // 左侧导航栏（固定）
        Container(
          width: 200,
          color: Colors.grey[200],
          child: Column([
            ListTile(
              title: Text('首页'),
              onTap: () => context.go('/home'),
            ),
            ListTile(
              title: Text('视频'),
              onTap: () => context.go('/video'),
            ),
            ListTile(
              title: Text('我的'),
              onTap: () => context.go('/profile'),
            ),
          ]),
        ),
        // 子路由出口
        Expanded(
          child: child,  // 注意：这里需要特殊处理
        ),
      ]),
    );
  },
  children: [
    homeRoute,
    videoRoute,
    profileRoute,
  ],
);

// 创建路由配置
final config = RouteConfig(
  routes: [mainRoute],
  initialPath: '/',
);

// 创建路由器
final router = AppRouter(config: config);
```

---

## 外壳路由（ShellRoute）

### 使用场景：底部导航栏

```dart
// 定义子路由
final homeRoute = AppRoute(
  path: '/home',
  name: 'home',
  builder: (context, state) => const HomePage(),
);

final exploreRoute = AppRoute(
  path: '/explore',
  name: 'explore',
  builder: (context, state) => const ExplorePage(),
);

final profileRoute = AppRoute(
  path: '/profile',
  name: 'profile',
  builder: (context, state) => const ProfilePage(),
);

// 创建底部导航栏外壳
final bottomNavShell = ShellRouteConfig(
  path: '/',
  name: 'main',
  shellBuilder: (context, state, child) {
    // 外壳：底部导航栏 + 子路由内容
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(state.uri.path),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/explore');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  },
  children: [
    homeRoute,
    exploreRoute,
    profileRoute,
  ],
  defaultChildPath: '/home',
);

// 创建路由配置
final config = RouteConfig(
  shellRoutes: [bottomNavShell],
  initialPath: '/',
);
```

### 使用便捷方法创建底部导航

```dart
// 使用 ShellRouteHelper 简化创建
final bottomNavShell = ShellRouteHelper.createBottomNavShell(
  path: '/',
  name: 'main',
  items: [
    BottomNavItem(
      icon: Icons.home,
      label: '首页',
      route: homeRoute,
    ),
    BottomNavItem(
      icon: Icons.explore,
      label: '发现',
      route: exploreRoute,
    ),
    BottomNavItem(
      icon: Icons.person,
      label: '我的',
      route: profileRoute,
    ),
  ],
  defaultPath: '/home',
);
```

---

### 使用场景：左右布局

```dart
// 左侧导航栏组件
class LeftNavigationBar extends StatelessWidget {
  final String currentPath;

  const LeftNavigationBar({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.grey[100],
      child: Column([
        _buildItem(context, Icons.home, '首页', '/home', currentPath),
        _buildItem(context, Icons.video_library, '视频', '/video', currentPath),
        _buildItem(context, Icons.message, '消息', '/message', currentPath),
        _buildItem(context, Icons.person, '我的', '/profile', currentPath),
      ]),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, String path, String currentPath) {
    final isSelected = currentPath.startsWith(path);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue,
      onTap: () => context.go(path),
    );
  }
}

// 使用便捷方法创建左右布局
final leftRightShell = ShellRouteHelper.createLeftRightShell(
  path: '/',
  name: 'main',
  leftBar: const LeftNavigationBar(currentPath: '/home'),
  routes: [
    homeRoute,
    videoRoute,
    messageRoute,
    profileRoute,
  ],
  defaultPath: '/home',
  leftBarWidth: 200,
);
```

---

## 多层嵌套

### 三层嵌套示例

```
/ (根路由 - 顶部横向滑动标签)
└─ shell (左侧+右侧容器)
   ├─ /home (右侧：首页)
   │  ├─ shell (顶部横向滑动)
   │  │  ├─ /home/recommend
   │  │  ├─ /home/following
   │  │  └─ /home/hot
   │  └─ content (纵向滑动列表)
   │
   ├─ /video (右侧：视频)
   │  ├─ shell (顶部横向滑动)
   │  │  ├─ /video/short
   │  │  └─ /video/live
   │  └─ content (瀑布流)
   │
   └─ /profile (右侧：我的)
      └─ content
```

```dart
// 第一层：顶部横向滑动标签的外壳
final topTabShell = ShellRouteConfig(
  path: '/',
  name: 'root',
  shellBuilder: (context, state, child) {
    return Scaffold(
      body: Column([
        // 顶部横向滑动标签
        SizedBox(
          height: 50,
          child: ListView.horizontal(
            children: [
              _buildTab(context, '推荐', '/'),
              _buildTab(context, '视频', '/video'),
              _buildTab(context, '直播', '/live'),
            ],
          ),
        ),
        // 子路由内容
        Expanded(child: child),
      ]),
    );
  },
  children: [
    recommendRoute,
    videoRoute,
    liveRoute,
  ],
  defaultChildPath: '/',
);

// 第二层：左侧+右侧容器
final leftRightShell = ShellRouteConfig(
  path: '/',
  name: 'main',
  shellBuilder: (context, state, child) {
    return Scaffold(
      body: Row([
        const LeftNavigationBar(),
        Expanded(child: child),
      ]),
    );
  },
  children: [
    homeRoute,
    videoRoute,
    profileRoute,
  ],
  defaultChildPath: '/home',
);

// 第三层：首页的顶部横向滑动
final homeTabShell = ShellRouteConfig(
  path: '/home',
  name: 'home',
  shellBuilder: (context, state, child) {
    return Column([
      // 顶部横向滑动标签
      SizedBox(
        height: 50,
        child: ListView.horizontal(
          children: [
            _buildHomeTab(context, '推荐', '/home/recommend'),
            _buildHomeTab(context, '关注', '/home/following'),
            _buildHomeTab(context, '热门', '/home/hot'),
          ],
        ),
      ),
      // 内容
      Expanded(child: child),
    ]);
  },
  children: [
    recommendRoute,
    followingRoute,
    hotRoute,
  ],
  defaultChildPath: '/home/recommend',
);

// 定义所有子路由
final recommendRoute = AppRoute(
  path: 'recommend',
  name: 'recommend',
  builder: (context, state) => const RecommendContent(),
);

final followingRoute = AppRoute(
  path: 'following',
  name: 'following',
  builder: (context, state) => const FollowingContent(),
);

final hotRoute = AppRoute(
  path: 'hot',
  name: 'hot',
  builder: (context, state) => const HotContent(),
);

// 组装配置
final config = RouteConfig(
  shellRoutes: [
    topTabShell,
    leftRightShell,
    homeTabShell,
  ],
);
```

---

## 实际案例

### 案例 1：类似小红书的复杂布局

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = RouteConfig(
      shellRoutes: [
        // 第一层：顶部标签（推荐、关注、...）
        ShellRouteConfig(
          path: '/',
          name: 'root',
          shellBuilder: (context, state, child) {
            return Scaffold(
              body: Column([
                _buildTopTabs(context, state.uri.path),
                Expanded(child: child),
              ]),
            );
          },
          children: [
            // 第二层：左侧+右侧容器
            ShellRouteConfig(
              path: '/',
              name: 'main',
              shellBuilder: (context, state, child) {
                return Scaffold(
                  body: Row([
                    _buildLeftNav(context, state.uri.path),
                    Expanded(child: child),
                  ]),
                );
              },
              children: [
                // 第三层：首页
                AppRoute(
                  path: 'home',
                  name: 'home',
                  builder: (context, state) {
                    return Scaffold(
                      body: Column([
                        _buildHomeTabs(context), // 首页的横向滑动标签
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return ContentCard();
                            },
                          ),
                        ),
                      ]),
                    );
                  },
                  children: [
                    AppRoute(path: 'recommend', name: 'recommend', builder: (_, __) => RecommendPage()),
                    AppRoute(path: 'following', name: 'following', builder: (_, __) => FollowingPage()),
                  ],
                ),
                // 第三层：视频
                AppRoute(
                  path: 'video',
                  name: 'video',
                  builder: (context, state) {
                    return Scaffold(
                      body: MasonryGridView.count(
                        crossAxisCount: 2,
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          return VideoCard();
                        },
                      ),
                    );
                  },
                ),
              ],
              defaultChildPath: '/home',
            ),
          ],
          defaultChildPath: '/',
        ),
      ],
    );

    final router = AppRouter(config: config);

    return MaterialApp.router(
      routerConfig: router.createRouter(),
    );
  }
}
```

---

## 🎯 最佳实践

### 1. 外壳路由的职责

**✅ 应该做：**
- 提供固定的布局（导航栏、Tab栏）
- 显示子路由的内容
- 处理导航逻辑（点击切换路由）

**❌ 不应该做：**
- 不应该包含具体的业务内容
- 不应该直接访问数据

### 2. 路由路径设计

**推荐：**
```
/                     ← 根
└─ /home               ← 一级
   ├─ /home/recommend  ← 二级
   └─ /home/following  ← 二级
```

**避免：**
```
/                    ← 太抽象
/main               ← 冗余
/main/home/recommend  ← 太深（一般不超过 3 层）
```

### 3. 状态管理

```dart
// 不要在外壳路由中保存子路由的状态
class ShellPage extends StatelessWidget {
  // ❌ 不好：在外壳保存状态
  final int selectedIndex;

  // ✅ 好：根据当前路径计算选中状态
  int _calculateSelectedIndex(String path) {
    if (path.startsWith('/home')) return 0;
    if (path.startsWith('/video')) return 1;
    return 0;
  }
}
```

---

## 📝 完整示例

参见 `example/lib/main.dart` 获取完整可运行的示例。

---

**相关文档：**
- [API 文档](./API.md)
- [路由守卫](./route_guard.md)
