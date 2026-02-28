# core_router 技术对比与应用指南

> **核心目标**：深入理解 Flutter 路由系统，掌握 go_router + Riverpod 的最佳实践

---

## 目录

1. [core_router 架构原理](#1-corerouter-架构原理)
2. [go_router 核心概念](#2-go_router-核心概念)
3. [技术方案对比](#3-技术方案对比)
4. [为什么选择 go_router](#4-为什么选择-go_router)
5. [实际应用示例](#5-实际应用示例)
6. [常见问题解答](#6-常见问题解答)

---

## 1. core_router 架构原理

### 1.1 设计理念

```
┌─────────────────────────────────────────────────────────────┐
│                      core_router                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           AppRouter (路由器)                         │    │
│  │  - 封装 go_router                                     │    │
│  │  - 提供统一 API                                       │    │
│  │  - 集成守卫系统                                       │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                    │
│                          ▼                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │        RouteConfig (路由配置)                        │    │
│  │  - 集中管理路由                                       │    │
│  │  - 不可变数据结构                                     │    │
│  │  - 支持动态添加/删除                                  │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                    │
│          ┌───────────────┴───────────────┐                    │
│          ▼                               ▼                    │
│  ┌──────────────────┐          ┌──────────────────┐         │
│  │   AppRoute       │          │ ShellRouteConfig │         │
│  │  (普通路由)       │          │  (外壳路由)       │         │
│  │  - 支持嵌套       │          │  - 固定布局       │         │
│  │  - 页面构建器     │          │  - 动态内容       │         │
│  └──────────────────┘          └──────────────────┘         │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │    RouteGuardManager (守卫管理器)                    │    │
│  │  - AuthGuard (认证守卫)                               │    │
│  │  - RoleGuard (角色守卫)                               │    │
│  │  - 自定义守卫                                         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 核心组件职责

| 组件 | 职责 | 关键方法 |
|------|------|----------|
| **AppRouter** | 路由器，提供导航 API | `go()`, `push()`, `pop()` |
| **RouteConfig** | 路由配置管理 | `addRoute()`, `getRoute()` |
| **AppRoute** | 单个路由定义 | `toGoRoute()` |
| **ShellRouteConfig** | 外壳路由配置 | - |
| **RouteGuard** | 路由守卫基类 | `canAccess()` |
| **RouteGuardManager** | 守卫管理器 | `checkAll()` |

### 1.3 数据流向

```
用户操作
    │
    ▼
调用导航方法 (router.go / router.push)
    │
    ▼
RouteGuard 检查 (如果配置了守卫)
    │
    ├── 通过 ──▶ go_router 处理
    │              │
    │              ▼
    │         匹配路由配置
    │              │
    │              ▼
    │         执行页面构建器
    │              │
    │              ▼
    │         显示新页面
    │
    └── 失败 ──▶ 重定向到指定页面
```

---

## 2. go_router 核心概念

### 2.1 什么是 go_router？

[go_router](https://pub.dev/packages/go_router) 是 Flutter 官方推荐的声明式路由库，基于 URL 导航。

**核心特点**：
- ✅ **声明式**：通过配置定义路由
- ✅ **类型安全**：编译时检查路由路径
- ✅ **深度链接**：原生支持 URL 参数
- ✅ **嵌套路由**：支持复杂的导航结构
- ✅ **官方支持**：Flutter 团队维护

### 2.2 核心概念对比

| 概念 | Navigator 1.0 | Navigator 2.0 | go_router |
|------|---------------|---------------|-----------|
| **API 风格** | 命令式 | 声明式 | 声明式 |
| **路由定义** | 分散在代码中 | 集中配置 | 集中配置 |
| **URL 同步** | ❌ | ✅ | ✅ |
| **深度链接** | 手动处理 | 自动处理 | 自动处理 |
| **嵌套路由** | 复杂 | 较简单 | 简单 |
| **学习曲线** | 低 | 高 | 中 |

### 2.3 go_router 核心类型

```dart
// GoRoute - 单个路由定义
GoRoute(
  path: '/user/:id',           // 路径（支持参数）
  name: 'user',                // 命名路由
  pageBuilder: (context, state) => MaterialPage(
    key: state.pageKey,
    child: UserPage(id: state.pathParameters['id']!),
  ),
)

// ShellRoute - 外壳路由
ShellRoute(
  builder: (context, state, child) => Scaffold(
    body: child,
    bottomNavigationBar: MyNavBar(),
  ),
  routes: [...],
)

// GoRouter - 路由器
final router = GoRouter(
  initialLocation: '/',
  routes: [...],
  redirect: (context, state) { ... },  // 重定向逻辑
)
```

---

## 3. 技术方案对比

### 3.1 GetX vs go_router

#### GetX 路由示例

```dart
// GetX 路由定义
final getPages = [
  GetPage(
    name: '/home',
    page: () => HomePage(),
  ),
  GetPage(
    name: '/user/:id',
    page: () => UserDetailPage(),
    // 中间件（守卫）
    middlewares: [
      GetMiddleware(
        redirect: (route) {
          if (!isLoggedIn) return '/login';
          return null;
        },
      ),
    ],
  ),
];

// 导航
Get.toNamed('/user/123');
Get.offNamed('/home');
Get.back();
```

#### go_router 路由示例

```dart
// go_router 路由定义
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: HomePage(),
      ),
    ),
    GoRoute(
      path: '/user/:id',
      name: 'user',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: UserDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ),
  ],
  // 全局重定向（守卫）
  redirect: (context, state) {
    if (!isLoggedIn && state.uri.path != '/login') {
      return '/login';
    }
    return null;
  },
);

// 导航
context.go('/user/123');
context.push('/detail');
context.pop();
```

#### 对比总结

| 特性 | GetX | go_router |
|------|------|-----------|
| **路由定义** | GetPage 列表 | GoRoute 树形结构 |
| **类型安全** | ❌ 字符串路径 | ✅ 编译时检查 |
| **参数传递** | `Get.arguments` | `state.pathParameters` |
| **中间件** | GetMiddleware | redirect 函数 |
| **URL 同步** | ❌ 需要手动处理 | ✅ 自动同步 |
| **测试友好** | ❌ 依赖全局状态 | ✅ 可注入依赖 |
| **官方支持** | ❌ 第三方 | ✅ 官方推荐 |

### 3.2 BLoC + go_router

#### BLoC 不管理路由

BLoC（Business Logic Component）专注于状态管理，不负责路由。

**典型模式**：
```dart
// BLoC 处理业务逻辑
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  on<LoginEvent>((event) async {
    // 处理登录逻辑
    final success = await authService.login();
    if (success) {
      // ❌ 不在这里导航
      // Get.toNamed('/home');  // 错误做法

      // ✅ 发送状态变化，由 UI 层处理导航
      emit(AuthLoggedInState());
    }
  });
}

// UI 层监听状态变化
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthLoggedInState) {
      context.go('/home');  // ✅ 在 UI 层处理导航
    }
  },
  child: ...,
)
```

**优势**：
- 职责分离：BLoC 只管状态，UI 层管导航
- 易于测试：不需要 mock 路由
- 可复用：BLoC 可在不同导航场景使用

### 3.3 Provider + go_router

#### Provider 只管理状态

```dart
// Provider 提供状态
final authProvider = Provider<bool>((ref) => false);

// 在 go_router 的 redirect 中使用状态
final router = GoRouter(
  redirect: (context, state) {
    final isAuthenticated = Provider.of<bool>(context, listen: false);
    if (!isAuthenticated && state.uri.path != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [...],
);
```

#### Riverpod + go_router（推荐）

```dart
// Riverpod 定义状态
final authProvider = StateProvider<bool>((ref) => false);

// 在 go_router 中使用 Riverpod
final router = GoRouter(
  redirect: (context, state) {
    final container = ProviderContainer();
    final isAuthenticated = container.read(authProvider);
    if (!isAuthenticated && state.uri.path != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [...],
);
```

### 3.4 AutoRoute vs go_router

#### AutoRoute 特点

```dart
// AutoRoute 使用注解生成代码
@RoutePage()
class HomePage extends StatelessWidget {}

@RoutePage()
class UserDetailPage extends StatelessWidget {
  final String id;
  const UserDetailPage({required this.id});
}

// 自动生成路由配置
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: UserDetailRoute.page),
  ];
}
```

**优缺点**：

| 特性 | AutoRoute | go_router |
|------|-----------|-----------|
| **代码生成** | ✅ 自动生成 | ❌ 手动编写 |
| **类型安全** | ✅ 强类型 | ✅ 强类型 |
| **学习曲线** | ❌ 陡峭 | ⚠️ 中等 |
| **构建流程** | 需要运行 build_runner | 无需额外步骤 |
| **调试** | 困难（生成代码） | 容易（直观配置） |

---

## 4. 为什么选择 go_router

### 4.1 官方推荐

```
Flutter 官方文档：

> "We recommend using go_router for new projects.
> It provides a declarative, type-safe approach to routing
> that works well with the Flutter navigation system."
```

### 4.2 技术优势

#### 1. 声明式路由

```dart
// ❌ 命令式（Navigator 1.0）
Navigator.push(context, MaterialPageRoute(
  builder: (context) => UserDetailPage(),
));

// ✅ 声明式（go_router）
context.go('/user/123');
```

#### 2. URL 同步

```dart
// go_router 自动管理 URL
// 访问 myapp://user/123 自动显示 UserDetailPage
// 浏览器前进/后退按钮正常工作
```

#### 3. 类型安全

```dart
// ✅ 编译时检查
context.go('/user/123');  // 正确
context.go('/user');     // 警告：缺少参数

// ❌ GetX 运行时错误
Get.toNamed('/user/123');  // 路径错误时崩溃
```

#### 4. 嵌套路由

```dart
// 复杂的嵌套结构
GoRoute(
  path: '/dashboard',
  routes: [
    GoRoute(
      path: 'analytics',
      routes: [
        GoRoute(path: 'traffic'),
        GoRoute(path: 'conversion'),
      ],
    ),
    GoRoute(
      path: 'reports',
      routes: [
        GoRoute(path: 'daily'),
        GoRoute(path: 'monthly'),
      ],
    ),
  ],
)
```

### 4.3 与 Riverpod 完美配合

```dart
// 状态管理：Riverpod
final authProvider = StateProvider<bool>((ref) => false);

// 路由管理：go_router
final router = GoRouter(
  redirect: (context, state) {
    final ref = ProviderScope.containerOf(context);
    final auth = ref.read(authProvider);
    if (!auth) return '/login';
    return null;
  },
  routes: [...],
);
```

**优势**：
- 职责分离：状态和路由独立管理
- 易于测试：可独立测试路由和状态
- 类型安全：编译时检查所有依赖

---

## 5. 实际应用示例

### 5.1 完整的应用配置

```dart
// main.dart
void main() {
  // 1. 创建路由配置
  final config = RouteConfig(
    initialPath: '/',
    routes: [
      AppRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => HomePage(),
      ),
      AppRoute(
        path: '/profile/:id',
        name: 'profile',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProfilePage(userId: id);
        },
      ),
      AppRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(),
      ),
    ],
  );

  // 2. 创建守卫
  final guardManager = RouteGuardManager([
    AuthGuard(
      isAuthenticated: () => UserSession.isLoggedIn,
      loginPath: '/login',
    ),
  ]);

  // 3. 创建路由器
  final router = AppRouter(
    config: config,
    guardManager: guardManager,
  );

  // 4. 运行应用
  runApp(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router.createRouter(),
      ),
    ),
  );
}
```

### 5.2 外壳路由（底部导航）

```dart
// 底部导航栏配置
final bottomNavShell = ShellRouteConfig(
  path: '/',
  name: 'main',
  shellBuilder: (context, state, child) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateIndex(state.uri.path),
        onTap: (index) => _navigateToIndex(context, index),
        items: [
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
    AppRoute(path: '/home', name: 'home', builder: (_, __) => HomePage()),
    AppRoute(path: '/discover', name: 'discover', builder: (_, __) => DiscoverPage()),
    AppRoute(path: '/profile', name: 'profile', builder: (_, __) => ProfilePage()),
  ],
  defaultChildPath: '/home',
);
```

### 5.3 路由守卫（权限控制）

```dart
// 多级权限控制
final guardManager = RouteGuardManager([
  // 1. 认证守卫（检查是否登录）
  AuthGuard(
    isAuthenticated: () => UserSession.isLoggedIn,
    loginPath: '/login',
  ),

  // 2. 角色守卫（检查是否有权限）
  RoleGuard(
    getUserRoles: () => UserSession.roles,
    requiredRoles: ['admin', 'editor'],
    errorPath: '/forbidden',
  ),

  // 3. 自定义守卫（检查特定条件）
  CustomGuard(
    canAccess: (path) async {
      if (path.startsWith('/premium')) {
        return await UserSession.hasPremiumAccess();
      }
      return true;
    },
    errorPath: '/upgrade',
  ),
]);
```

---

## 6. 常见问题解答

### Q1: go_router 和 Navigator 的区别？

| 特性 | Navigator | go_router |
|------|-----------|-----------|
| **API 风格** | 命令式 | 声明式 |
| **路由定义** | 分散 | 集中 |
| **URL 支持** | 手动 | 自动 |
| **适用场景** | 简单应用 | 复杂应用 |

**选择建议**：
- 简单应用 → Navigator 1.0
- 复杂应用 → go_router

### Q2: 为什么不用 GetX？

**GetX 的问题**：
1. 全局状态管理，难以测试
2. 字符串路径，无类型安全
3. 与 Flutter 生态系统不兼容
4. 社区维护不稳定

**go_router 的优势**：
1. 官方支持，长期维护
2. 类型安全，编译时检查
3. 与 Flutter 生态无缝集成
4. 易于测试和调试

### Q3: BLoC / Provider 和 go_router 如何配合？

**正确做法**：
```
BLoC / Provider  →  管理状态
       ↓
    UI 层监听状态
       ↓
   触发 go_router 导航
```

**错误做法**：
```
BLoC / Provider  →  直接调用路由（耦合）
       ↓
   Get.toNamed() / context.go()
```

### Q4: 如何传递复杂数据？

```dart
// 方案 1：路径参数（简单数据）
context.go('/user/123');

// 方案 2：查询参数（可选数据）
context.go('/search?keyword=flutter&page=1');

// 方案 3：extra 参数（复杂数据）
context.go('/detail', extra: {
  'user': User(...),
  'config': Config(...),
});

// 在目标页面接收
class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map;
    final user = extra['user'] as User;
    final config = extra['config'] as Config;
    ...
  }
}
```

### Q5: 如何处理返回结果？

```dart
// 推入页面并等待结果
final result = await context.push<bool>('/confirmation');

if (result == true) {
  // 用户确认
  await submitData();
} else {
  // 用户取消
  showCancelMessage();
}

// 在确认页面返回结果
class ConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.pop(true),  // 确认
            child: Text('确认'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(false), // 取消
            child: Text('取消'),
          ),
        ],
      ),
    );
  }
}
```

---

## 总结

### 技术选型建议

| 场景 | 推荐方案 | 原因 |
|------|----------|------|
| **状态管理** | Riverpod | 类型安全、测试友好 |
| **路由管理** | go_router | 官方推荐、声明式 |
| **小型项目** | Provider + Navigator | 简单直接 |
| **大型项目** | Riverpod + go_router | 可维护、可测试 |

### 最佳实践

1. **职责分离**：状态管理和路由管理分开
2. **类型安全**：使用强类型，避免字符串
3. **声明式**：优先使用声明式 API
4. **测试友好**：依赖注入，易于 mock
5. **官方优先**：优先选择官方推荐的库

---

**参考资源**：

- [go_router 官方文档](https://pub.dev/packages/go_router)
- [Riverpod 官方文档](https://riverpod.dev/)
- [Flutter 导航文档](https://docs.flutter.dev/ui/navigation)
