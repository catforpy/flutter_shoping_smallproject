# 嵌套路由示例 (Nested Routes Example)

这个示例展示了如何使用 GoRouter 实现三级嵌套路由。

## 路由层级结构

```
Level 1: 左侧导航栏（固定不动）- StatefulShellRoute
  ├── Level 2: 首页顶部横向标签栏（固定不动）
  │   ├── Level 3: Latest 内容页
  │   └── Level 3: Hot 内容页
  ├── Video 页面
  ├── Message 页面
  └── Profile 页面
```

## 路径结构

- `/home/latest` - 首页 → 最新
- `/home/hot` - 首页 → 热门
- `/video` - 视频页
- `/message` - 消息页
- `/profile` - 个人资料页

## 运行示例

### 方法 1：使用命令行

```bash
# 进入示例目录
cd packages/core/core_router/example

# 安装依赖
flutter pub get

# 运行示例（iOS 模拟器）
flutter run -d ios

# 或者运行在 Android 模拟器
flutter run -d android

# 或者运行在 Chrome 浏览器
flutter run -d chrome
```

### 方法 2：使用 VS Code

1. 在 VS Code 中打开 `packages/core/core_router/example` 文件夹
2. 按 `F5` 或点击 "Run > Start Debugging"
3. 选择目标设备（iOS/Android/Chrome）

### 方法 3：使用 Android Studio/IntelliJ

1. 打开 `packages/core/core_router/example` 作为 Flutter 项目
2. 点击工具栏的运行按钮
3. 选择目标设备并运行

## 功能特点

### ✅ 三级嵌套路由
- **第一级**: 左侧导航栏（StatefulShellRoute）
  - 固定不动，不重建
  - 保持滚动位置和选中状态
  - 使用 `StatefulNavigationShell.goBranch()` 切换分支

- **第二级**: 首页顶部横向标签（GoRoute 嵌套）
  - 只在首页显示
  - 使用 `context.go()` 导航到子路由
  - 标签栏固定，内容区域切换

- **第三级**: 内容列表页
  - Latest/Hot 两个列表页
  - 使用 `NoTransitionPage` 避免过渡动画

### ✅ 状态保持
- 左侧导航栏状态保持
- 首页标签栏状态保持
- 列表滚动位置保持

### ✅ URL 同步
- URL 路径自动更新
- 支持深度链接
- 支持浏览器前进/后退

## 代码说明

### 1. 主路由配置

使用 `StatefulShellRoute.indexedStack` 创建左侧导航栏：

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return Scaffold(
      body: Row([
        // 左侧导航（固定）
        _buildLeftNav(navigationShell),
        // 右侧内容（子路由）
        Expanded(child: navigationShell),
      ]),
    );
  },
  branches: [
    // 每个分支对应一个左侧导航项
    StatefulShellBranch(routes: [...]),
    StatefulShellBranch(routes: [...]),
    // ...
  ],
)
```

### 2. 左侧导航栏

使用 `StatefulNavigationShell.currentIndex` 判断选中状态：

```dart
Widget _buildNavItem({
  required StatefulNavigationShell navigationShell,
  required int index,
}) {
  final isSelected = navigationShell.currentIndex == index;

  return ListTile(
    selected: isSelected,
    onTap: () => navigationShell.goBranch(index),
    // ...
  );
}
```

### 3. 首页嵌套标签

首页使用嵌套路由实现顶部标签栏：

```dart
GoRoute(
  path: '/home',
  pageBuilder: (context, state) => NoTransitionPage(
    child: HomeWithTabs(), // 包含标签栏的页面
  ),
  routes: [
    GoRoute(path: 'latest', ...),
    GoRoute(path: 'hot', ...),
  ],
)
```

### 4. 标签栏导航

使用 `context.go()` 在子路由间导航：

```dart
_onTap(int index) {
  if (index == 0) {
    context.go('/home/latest');
  } else if (index == 1) {
    context.go('/home/hot');
  }
}
```

## 关键要点

### StatefulShellRoute vs GoRoute

- **StatefulShellRoute**: 用于需要保持状态的并行导航（如底部导航栏、左侧菜单）
  - 每个分支独立维护状态
  - 使用 `goBranch()` 切换，不重建 Widget

- **GoRoute**: 用于层级导航（如标签页、详情页）
  - 支持嵌套子路由
  - 使用 `context.go()` 导航

### NoTransitionPage

使用 `NoTransitionPage` 避免不必要的过渡动画：

```dart
pageBuilder: (context, state) => const NoTransitionPage(
  child: MyPage(),
)
```

### 状态管理

不要在父组件保存子路由的状态：

```dart
// ❌ 错误：在外壳保存状态
class HomeWithTabs extends StatefulWidget {
  final int selectedIndex; // 不要这样做
}

// ✅ 正确：根据路径计算状态
class HomeWithTabs extends StatefulWidget {
  int _calculateIndex(String path) {
    if (path.contains('latest')) return 0;
    if (path.contains('hot')) return 1;
    return 0;
  }
}
```

## 扩展到四级嵌套

如果要添加四级嵌套（例如内容页内部再嵌套标签页），可以在 `ContentPage` 中继续使用 `GoRoute` 嵌套：

```dart
GoRoute(
  path: 'latest',
  pageBuilder: (context, state) => NoTransitionPage(
    child: ContentPage(),
  ),
  routes: [
    // 第四级
    GoRoute(path: 'detail/:id', ...),
  ],
)
```

## 相关文档

- [GoRouter 官方文档](https://pub.dev/packages/go_router)
- [core_router 使用指南](../EXAMPLE_NESTED_ROUTES.md)
- [StatefulShellRoute 示例](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart)
