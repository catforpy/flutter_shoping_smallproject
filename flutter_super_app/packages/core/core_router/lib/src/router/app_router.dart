library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core_logging/core_logging.dart';
import 'route_config.dart';
import 'route_guard.dart';
import '../models/app_route.dart';

/// 自定义页面过渡 - 从右侧滑入
class _SlideFromRightPage extends CustomTransitionPage<void> {
  _SlideFromRightPage({required LocalKey key, required Widget child})
      : super(
          key: key,
          child: child,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 使用从右侧滑入的动画
            const begin = Offset(1.0, 0.0); // 从右侧开始
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

// ============================================================
// 应用路由器
// ============================================================
// 设计理念：
// 1. 封装 go_router，提供统一的 API
// 2. 类型安全的导航方法
// 3. 支持路由守卫（权限控制）
// 4. 自动日志记录
// 5. 错误处理和降级

// ============================================================
// AppRouter - 主路由器
// ============================================================

/// 应用路由器
///
/// 基于 [go_router](https://pub.dev/packages/go_router) 的路由管理器。
/// 提供声明式路由配置、类型安全导航、路由守卫等功能。
///
/// ## 核心功能
/// 1. **声明式路由配置**：通过配置定义路由，代码即文档
/// 2. **路由守卫**：支持认证、角色等权限检查
/// 3. **嵌套路由**：支持多层嵌套，实现复杂布局
/// 4. **外壳路由**：固定布局 + 动态内容（如底部导航栏）
/// 5. **类型安全**：编译时检查路由路径和参数
/// 6. **自动日志**：记录所有导航操作
///
/// ## 基础用法
/// ```dart
/// // 1. 定义路由配置
/// final config = RouteConfig(
///   initialPath: '/',
///   routes: [
///     AppRoute(
///       path: '/',
///       name: 'home',
///       builder: (context, state) => HomePage(),
///     ),
///     AppRoute(
///       path: '/profile/:id',
///       name: 'profile',
///       builder: (context, state) {
///         final id = state.pathParameters['id']!;
///         return ProfilePage(userId: id);
///       },
///     ),
///   ],
/// );
///
/// // 2. 创建路由器
/// final router = AppRouter(config: config);
///
/// // 3. 在 MaterialApp 中使用
/// MaterialApp.router(
///   routerConfig: router.createRouter(),
/// )
/// ```
///
/// ## 路由守卫用法
/// ```dart
/// // 创建守卫管理器
/// final guardManager = RouteGuardManager([
///   AuthGuard(
///     isAuthenticated: () => UserSession.isLoggedIn,
///     loginPath: '/login',
///   ),
/// ]);
///
/// // 应用到路由器
/// final router = AppRouter(
///   config: config,
///   guardManager: guardManager,
/// );
/// ```
///
/// ## 导航方法
/// ```dart
/// // 替换当前路由（类似浏览器行为）
/// router.go(context, '/profile');
///
/// // 推入新页面（添加到导航栈）
/// router.push(context, '/settings');
///
/// // 替换当前页面
/// router.replace(context, '/login');
///
/// // 返回上一页
/// router.pop(context);
///
/// // 返回到指定路径
/// router.popUntil(context, '/home');
/// ```
///
/// ## 与其他框架对比
///
/// ### GetX
/// ```dart
/// // GetX 使用 Get.toNamed() / Get.offNamed()
/// Get.toNamed('/profile');
/// Get.offNamed('/login');
///
/// // 问题：
/// // 1. 字符串路径，无类型安全
/// // 2. 全局状态管理，难以测试
/// // 3. 与 Flutter 导航体系不兼容
/// ```
///
/// ### BLoC
/// ```dart
/// // BLoC 本身不管理路由
/// // 需要配合 Navigator 或 go_router
/// // 通常在事件中调用 Navigator.push()
/// ```
///
/// ### Provider
/// ```dart
/// // Provider 只管理状态
/// // 路由由其他方案处理
/// // 可以在 Consumer 中调用 Navigator
/// ```
///
/// ### AutoRoute
/// ```dart
/// // AutoRoute 使用注解生成路由代码
/// @RoutePage()
/// class HomePage extends StatelessWidget {}
///
/// // 优点：强类型、代码生成
/// // 缺点：构建流程复杂、学习曲线陡峭
/// ```
///
/// ## 为什么选择 go_router？
///
/// | 特性       | go_router  | GetX      | AutoRoute  | Navigator 2.0 |
///|-----------|-----------|----------|-----------|--------------|
///| 官方支持    | ✅ 推荐    | ❌ 第三方  | ✅ 推荐    | ✅ 官方     |
///| 声明式     | ✅        | ✅        | ✅        | ❌          |
///| 类型安全    | ✅        | ❌        | ✅        | ⚠️ 部分     |
///| 深度链接   | ✅        | ⚠️        | ✅        | ✅          |
///| 嵌套路由   | ✅        | ❌        | ✅        | ⚠️ 复杂     |
///| 守卫       | ✅        | ✅        | ✅        | ❌          |
///| 学习曲线   | ⚠️ 中等   | ⚠️ 中等   | ❌ 陡峭   | ⚠️ 中等     |
final class AppRouter {
  // ========== 配置属性 ==========

  /// 路由配置（包含所有路由定义）
  final RouteConfig config;

  /// 路由守卫管理器（可选）
  ///
  /// 如果提供，将在每次路由跳转前执行权限检查。
  final RouteGuardManager? guardManager;

  // ========== 构造函数 ==========

  const AppRouter({
    required this.config,                    // 必填：路由配置
    this.guardManager,                       // 可选：守卫管理器
  });

  // ========== GoRouter 创建 ==========

  /// 创建 GoRouter 实例
  ///
  /// 这是应用路由的入口方法，返回的 GoRouter
  /// 直接传递给 MaterialApp.router。
  ///
  /// 参数：
  /// - navigatorKey: 全局导航 key（用于测试或外部访问）
  /// - initialLocation: 初始路由配置（覆盖 config.initialPath）
  ///
  /// 返回：配置好的 GoRouter 实例
  ///
  /// 示例：
  /// ```dart
  /// final router = AppRouter(config: config);
  ///
  /// MaterialApp.router(
  ///   routerConfig: router.createRouter(
  ///     navigatorKey: GlobalKey(),
  ///     initialLocation: {'path': '/dashboard'},
  ///   ),
  /// )
  /// ```
  GoRouter createRouter({
    GlobalKey<NavigatorState>? navigatorKey,
    Map<String, dynamic>? initialLocation,
  }) {
    return GoRouter(
      // 导航 key（用于测试、Navigator 操作）
      navigatorKey: navigatorKey,

      // 初始路径（优先使用外部传入的）
      initialLocation: initialLocation?['path'] as String? ?? config.initialPath,

      // 开发模式诊断日志
      debugLogDiagnostics: true,

      // 路由重定向（守卫检查）
      redirect: guardManager != null
          ? (context, state) async {
              // 获取目标路径
              final path = state.uri.path;

              // 执行所有守卫检查
              final redirectTo = await guardManager!.checkAll(path);

              // 如果任一守卫失败，返回重定向路径
              if (redirectTo != null) {
                Log.i('路由重定向: $path -> $redirectTo');
                return redirectTo;
              }

              // 所有守卫通过，允许访问
              return null;
            }
          : null,

      // 路由列表
      routes: _buildRoutes(),

      // 错误页面（路由未找到时显示）
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('路由错误: ${state.uri}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => go(context, config.initialPath),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== 路由构建方法 ==========

  /// 构建路由列表
  ///
  /// 将自定义的 AppRoute 和 ShellRouteConfig
  /// 转换为 go_router 的 RouteBase 列表。
  ///
  /// 构建顺序：
  /// 1. 外壳路由（优先级高）
  /// 2. 普通路由（支持嵌套）
  /// 3. 404 页面
  List<RouteBase> _buildRoutes() {
    final List<RouteBase> allRoutes = [];

    // 1. 添加外壳路由（优先级最高，先匹配）
    for (final shellConfig in config.shellRoutes) {
      allRoutes.add(_buildShellRoute(shellConfig));
    }

    // 2. 添加普通路由（支持嵌套）
    for (final route in config.routes) {
      allRoutes.add(_buildNestedRoute(route));
    }

    // 3. 添加 404 页面（兜底）
    allRoutes.add(GoRoute(
      path: config.notFoundPath,
      name: 'notFound',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text('页面未找到'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => go(context, config.initialPath),
                  child: const Text('返回首页'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    return allRoutes;
  }

  /// 构建外壳路由（ShellRoute）
  ///
  /// 外壳路由提供固定的布局框架（如底部导航栏），
  /// 子路由的内容在框架内显示。
  ///
  /// 外壳路由结构示例：
  /// ```
  /// ┌─────────────────────────────┐
  /// │                             │
  /// │      子路由内容区域          │ ← 动态变化
  /// │                             │
  /// ├─────────────────────────────┤
  /// │      固定的底部导航栏        │ ← 保持不变
  /// └─────────────────────────────┘
  /// ```
  RouteBase _buildShellRoute(ShellRouteConfig shellConfig) {
    return GoRoute(
      path: shellConfig.path,
      name: shellConfig.name,
      pageBuilder: (context, state) {
        // 获取默认子路由的内容（初始化时显示）
        final defaultChild = shellConfig.children.isNotEmpty
            ? shellConfig.children.first.builder(context, state)
            : const SizedBox();

        return MaterialPage(
          key: state.pageKey,
          child: shellConfig.shellBuilder(context, state, defaultChild),
        );
      },
      // 递归构建子路由
      routes: [
        for (final child in shellConfig.children)
          _buildNestedRoute(child),
      ],
    );
  }

  /// 构建嵌套路由（递归）
  ///
  /// 支持多层嵌套，实现复杂的导航结构。
  RouteBase _buildNestedRoute(AppRoute route) {
    return GoRoute(
      path: route.path,
      name: route.name,
      pageBuilder: (context, state) => _SlideFromRightPage(
        key: state.pageKey,
        child: Builder(
          builder: (context) => route.builder(context, state),
        ),
      ),
      // 递归构建子路由
      routes: route.children?.map((child) => _buildNestedRoute(child)).toList() ?? [],
    );
  }

  // ========== 导航方法 ==========

  /// 导航到指定路径（替换当前路由）
  ///
  /// 类似于浏览器的 URL 跳转，会替换当前路由栈顶的路由。
  ///
  /// 与其他导航方法对比：
  /// - go()：替换当前路由，用于主导航、底部导航切换
  /// - push()：推入新页面（返回可回退），用于详情页、子页面
  /// - replace()：替换当前页面（清除栈），用于登录后跳转、防止返回
  void go(BuildContext context, String path, {Object? extra}) {
    Log.i('导航到: $path');
    context.go(path, extra: extra);
  }

  /// 推入新页面（添加到导航栈）
  ///
  /// 新页面会被推入导航栈，用户可以返回到上一页。
  ///
  /// 参数：
  /// - context: BuildContext
  /// - path: 目标路径
  /// - extra: 额外数据
  ///
  /// 示例：
  /// ```dart
  /// // 打开详情页（可以返回）
  /// router.push(context, '/product/123');
  /// ```
  void push(BuildContext context, String path, {Object? extra}) {
    Log.i('推入页面: $path');
    context.push(path, extra: extra);
  }

  /// 替换当前页面
  ///
  /// 替换导航栈顶的页面，用户无法返回到被替换的页面。
  ///
  /// 使用场景：
  /// - 登录成功后跳转到首页（防止返回登录页）
  /// - 表单提交后跳转到结果页
  /// - 忘记密码后跳转到登录页
  ///
  /// 示例：
  /// ```dart
  /// // 登录成功后跳转到首页（不能返回登录页）
  /// router.replace(context, '/home');
  /// ```
  void replace(BuildContext context, String path, {Object? extra}) {
    Log.i('替换页面: $path');
    context.replace(path, extra: extra);
  }

  /// 返回上一页
  ///
  /// 从当前页面返回，可以选择性地返回结果给上一页。
  ///
  /// 参数：
  /// - context: BuildContext
  /// - result: 返回给上一页的数据（可选）
  ///
  /// 示例：
  /// ```dart
  /// // 简单返回
  /// router.pop(context);
  ///
  /// // 返回结果
  /// router.pop(context, {'success': true});
  ///
  /// // 在上一页接收结果
  /// final result = await router.push(context, '/detail');
  /// ```
  void pop(BuildContext context, [Object? result]) {
    Log.i('返回上一页');
    context.pop(result);
  }

  /// 返回到指定路径
  ///
  /// 持续弹出页面，直到到达指定路径的页面。
  ///
  /// 参数：
  /// - context: BuildContext
  /// - path: 目标路径（停止弹出的条件）
  ///
  /// 示例：
  /// ```dart
  /// // 返回到首页（弹出中间所有页面）
  /// router.popUntil(context, '/home');
  /// ```
  void popUntil(BuildContext context, String path) {
    Log.i('返回到: $path');
    while (context.canPop() && GoRouterState.of(context).uri.path != path) {
      context.pop();
    }
  }

  /// 刷新当前路由
  ///
  /// 重新加载当前路由的页面，触发页面重建。
  ///
  /// 使用场景：
  /// - 数据更新后刷新页面
  /// - 用户操作后需要重新获取数据
  ///
  /// 示例：
  /// ```dart
  /// // 提交表单后刷新
  /// await submitForm();
  /// router.refresh(context);
  /// ```
  void refresh(BuildContext context) {
    Log.i('刷新当前路由');
    GoRouter.of(context).refresh();
  }

  // ========== 查询方法 ==========

  /// 获取当前路径
  ///
  /// 返回当前页面的路由路径。
  ///
  /// 示例：
  /// ```dart
  /// final path = router.currentPath(context);
  /// print('当前路径: $path'); // /profile
  /// ```
  String currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  /// 获取当前路由名称
  ///
  /// 返回当前页面的路由名称。
  ///
  /// 示例：
  /// ```dart
  /// final name = router.currentRouteName(context);
  /// print('当前路由: $name'); // profile
  /// ```
  String? currentRouteName(BuildContext context) {
    return GoRouterState.of(context).name;
  }

  /// 检查是否可以返回
  ///
  /// 判断当前导航栈是否可以弹出页面。
  ///
  /// 返回：true 表示可以返回，false 表示已是根页面
  ///
  /// 示例：
  /// ```dart
  /// if (router.canPop(context)) {
  ///   router.pop(context);
  /// }
  /// ```
  bool canPop(BuildContext context) {
    return context.canPop();
  }
}
