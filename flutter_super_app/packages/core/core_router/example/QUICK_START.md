# 快速开始 - 嵌套路由示例

## 🚀 一键运行

```bash
cd packages/core/core_router/example
flutter pub get
flutter run
```

## 📱 界面说明

运行后，你会看到一个三级嵌套路由的界面：

```
┌─────────────────────────────────────────────┐
│  ┌──────┐  ┌──────────────────────────────┐ │
│  │ Home │  │  ┌────┐ ┌────┐               │ │
│  │Video │  │  │Lat ││Hot │               │ │
│  │ Msg  │  │  └────┘ └────┘               │ │
│  │ Prof │  │  ┌─────────────────────────┐ │ │
│  │      │  │  │ Latest Item 0          │ │ │
│  └──────┘  │  │ Latest Item 1          │ │ │
│   左侧导航   │  │ Latest Item 2          │ │ │
│  (Level 1)  │  │ ...                    │ │ │
│             │  └─────────────────────────┘ │ │
│             │       内容列表 (Level 3)     │ │
│             └──────────────────────────────┘ │
│               右侧内容区 (Level 2+3)          │
└─────────────────────────────────────────────┘
```

## 🎯 核心概念

### 1. StatefulShellRoute（左侧导航）

```dart
StatefulShellRoute.indexedStack(
  branches: [
    StatefulShellBranch(routes: [homeRoute, ...]), // 索引 0
    StatefulShellBranch(routes: [videoRoute]),     // 索引 1
    StatefulShellBranch(routes: [messageRoute]),   // 索引 2
    StatefulShellBranch(routes: [profileRoute]),   // 索引 3
  ],
)
```

**关键点：**
- 每个分支独立维护状态
- 切换分支不重建 Widget
- 使用 `navigationShell.goBranch(index)` 切换

### 2. GoRoute 嵌套（首页标签）

```dart
GoRoute(
  path: '/home',
  routes: [
    GoRoute(path: 'latest', ...),  // /home/latest
    GoRoute(path: 'hot', ...),     // /home/hot
  ],
)
```

**关键点：**
- 子路由路径是相对路径
- 父路由的 builder 中可以包含共享 UI（标签栏）
- 使用 `context.go('/home/latest')` 导航

### 3. 路由状态管理

```dart
// ❌ 错误：在外壳保存状态
class MyWidget extends StatefulWidget {
  final int selectedIndex; // 不要这样做
}

// ✅ 正确：根据路由状态计算
class MyWidget extends StatefulWidget {
  int getIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return path.contains('latest') ? 0 : 1;
  }
}
```

## 🔍 测试导航

```bash
# 运行测试
flutter test

# 测试覆盖率
flutter test --coverage
```

## 📚 相关文件

- `lib/nested_routes_example.dart` - 主示例代码
- `lib/main.dart` - 应用入口
- `test/nested_routes_test.dart` - 测试文件
- `README.md` - 详细文档
- `pubspec.yaml` - 依赖配置

## 💡 常见问题

### Q: 为什么左侧导航栏切换时不会重建？
A: 使用了 `StatefulShellRoute.indexedStack`，每个分支保持在自己的栈中，切换时不会重建。

### Q: 如何添加更多层级的嵌套？
A: 在子路由中继续使用 `GoRoute` 的 `routes` 参数，支持无限层级嵌套。

### Q: 如何传递参数到子路由？
A: 使用路径参数 `/user/:id` 或查询参数 `/user?id=123`，在 `GoRouterState` 中获取。

## 🎓 下一步

1. 修改 `lib/nested_routes_example.dart`，添加新的左侧导航项
2. 在首页添加更多横向标签
3. 实现第四级嵌套（内容页内部再嵌套）
4. 集成到你的实际项目中

## 📖 更多资源

- [GoRouter 官方文档](https://pub.dev/packages/go_router)
- [Flutter 导航文档](https://docs.flutter.dev/ui/navigation)
- [core_router 使用指南](../EXAMPLE_NESTED_ROUTES.md)
