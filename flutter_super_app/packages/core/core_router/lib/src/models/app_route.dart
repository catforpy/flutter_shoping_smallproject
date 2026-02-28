library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ============================================================
// 路由模型层
// ============================================================
// 设计理念：
// 1. 提供类型安全的路由定义
// 2. 支持嵌套路由（多层级导航）
// 3. 外壳路由模式（固定布局 + 动态内容）
// 4. 与 go_router 无缝集成

// ============================================================
// 应用路由模型
// ============================================================

/// 应用路由模型
///
/// 定义单个路由的所有信息，包括路径、名称、页面构建器等。
/// 支持嵌套路由，实现多层级导航结构。
///
/// ## 设计理念
/// - 类型安全：使用 Dart 类型系统确保路由定义正确
/// - 声明式：通过配置定义路由，代码即文档
/// - 可组合：支持嵌套和复用
///
/// ## 使用示例
/// ```dart
/// // 简单路由
/// final homeRoute = AppRoute(
///   path: '/',
///   name: 'home',
///   builder: (context, state) => HomePage(),
///   title: '首页',
///   icon: Icons.home,
/// );
///
/// // 嵌套路由（带子路由）
/// final dashboardRoute = AppRoute(
///   path: '/dashboard',
///   name: 'dashboard',
///   builder: (context, state) => DashboardPage(),
///   children: [
///     AppRoute(
///       path: '/analytics',
///       name: 'analytics',
///       builder: (context, state) => AnalyticsPage(),
///     ),
///     AppRoute(
///       path: '/reports',
///       name: 'reports',
///       builder: (context, state) => ReportsPage(),
///     ),
///   ],
/// );
/// ```
///
/// ## 与其他框架对比
///
/// ### GetX
/// ```dart
/// // GetX 使用字符串路径，无类型安全
/// GetPage(
///   name: '/home',
///   page: () => HomePage(),
/// )
///
/// // 我们的方案：类型安全，IDE 支持
/// AppRoute(
///   path: '/home',
///   name: 'home',
///   builder: (context, state) => HomePage(),
/// )
/// ```
///
/// ### BLoC
/// ```dart
/// // BLoC 本身不管理路由，需要配合其他库
/// // 通常使用 Navigator 1.0 或 go_router
/// ```
///
/// ### Provider
/// ```dart
/// // Provider 只做状态管理，不处理路由
/// // 需要配合 Navigator 或 go_router
/// ```
final class AppRoute {
  // ========== 基础属性 ==========

  /// 路由路径（URL 路径）
  ///
  /// 例如：'/home', '/user/:id', '/settings/profile'
  /// 支持路径参数：'/user/:id' -> state.uri.queryParameters['id']
  final String path;

  /// 路由名称（唯一标识符）
  ///
  /// 用于编程式导航：context.goNamed('home')
  /// 比路径更稳定，路径修改时名称可以不变
  final String name;

  /// 页面构建器
  ///
  /// 参数：
  /// - context: BuildContext，用于构建 UI
  /// - state: GoRouterState，包含路由状态信息
  ///   - state.uri: 完整 URI
  ///   - state.path: 当前路径
  ///   - state.params: 路径参数
  ///   - state.queryParams: 查询参数
  final Widget Function(BuildContext context, GoRouterState state) builder;

  // ========== 可选属性 ==========

  /// 页面标题（用于导航栏、Tab 标题等）
  final String? title;

  /// 页面图标（用于底部导航、Tab 图标等）
  final IconData? icon;

  /// 子路由列表（支持嵌套）
  ///
  /// 嵌套路由场景：
  /// - /dashboard/analytics
  /// - /dashboard/reports
  /// - /user/:userId/profile
  final List<AppRoute>? children;

  /// 是否为外壳路由（预留字段，当前使用 ShellRouteConfig）
  ///
  /// 外壳路由：提供固定布局（如底部导航栏）
  /// 子路由内容在外壳内部显示
  final bool isShell;

  // ========== 构造函数 ==========

  const AppRoute({
    required this.path,                       // 必填：路由路径
    required this.name,                       // 必填：路由名称
    required this.builder,                    // 必填：页面构建器
    this.title,                               // 可选：页面标题
    this.icon,                                // 可选：页面图标
    this.children,                            // 可选：子路由
    this.isShell = false,                     // 默认：非外壳路由
  });

  // ========== 方法 ==========

  /// 转换为 GoRoute
  ///
  /// 将自定义的 AppRoute 转换为 go_router 的 GoRoute
  /// 支持递归转换子路由
  ///
  /// 参数：
  /// - routes: 可选的子路由列表（用于外部传入）
  ///
  /// 返回：GoRoute 对象，用于 go_router 配置
  GoRoute toGoRoute({List<GoRoute>? routes}) {
    // 如果有外部传入的子路由，使用外部的
    // 否则递归转换自己的子路由
    final childRoutes = routes ??
        (children?.map((r) => r.toGoRoute()).toList() ?? []);

    return GoRoute(
      path: path,
      name: name,
      // 使用 MaterialPage 保持页面状态
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,                   // 使用 pageKey 保持状态
        child: Builder(
          builder: (context) => builder(context, state),
        ),
      ),
      routes: childRoutes,                     // 递归添加子路由
    );
  }

  @override
  String toString() =>
      'AppRoute(path: $path, name: $name, children: ${children?.length ?? 0})';
}

// ============================================================
// 外壳路由配置
// ============================================================

/// 外壳路由配置
///
/// 用于创建固定布局的应用外壳（如底部导航栏、侧边栏）。
/// 外壳部分保持不变，内容区域随路由切换。
///
/// ## 什么是外壳路由？
///
/// 外壳路由是一种常见的 UI 模式：
/// - 外壳（Shell）：固定的导航结构（底部导航栏、侧边栏等）
/// - 内容（Content）：动态的页面内容
///
/// 例如：底部导航栏应用
/// ```
/// ┌─────────────────────────────┐
/// │                             │
/// │      动态内容区域            │ ← 随路由切换
/// │      (RouterOutlet)         │
/// │                             │
/// ├─────────────────────────────┤
/// │ [首页] [发现] [消息] [我的] │ ← 固定不变
/// └─────────────────────────────┘
/// ```
///
/// ## 使用示例
/// ```dart
/// ShellRouteConfig(
///   path: '/',
///   name: 'main',
///   shellBuilder: (context, state, child) {
///     return Scaffold(
///       body: child,                        // 子路由内容
///       bottomNavigationBar: MyBottomNav(), // 固定的底部导航
///     );
///   },
///   children: [
///     AppRoute(path: '/home', ...),
///     AppRoute(path: '/discover', ...),
///     AppRoute(path: '/messages', ...),
///     AppRoute(path: '/profile', ...),
///   ],
///   defaultChildPath: '/home',
/// )
/// ```
///
/// ## 与其他框架对比
///
/// ### GetX
/// ```dart
/// // GetX 使用 ShellRoute 或自定义布局
/// // 没有专门的外壳路由概念
/// GetPage(
///   name: '/',
///   page: () => ShellWithChild(),
/// )
/// ```
///
/// ### Material 3 (NavigationDestination)
/// ```dart
/// // Material 3 使用 Scaffold + destination
/// // 需要手动管理子路由切换
/// ```
final class ShellRouteConfig {
  // ========== 基础属性 ==========

  /// 路由路径
  final String path;

  /// 路由名称
  final String name;

  // ========== 外壳构建器 ==========

  /// 外壳构建器
  ///
  /// 参数：
  /// - context: BuildContext
  /// - state: GoRouterState（当前路由状态）
  /// - child: Widget（子路由的内容，在外壳中显示）
  ///
  /// 返回：完整的外壳页面（包含固定布局 + 子路由内容）
  final Widget Function(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) shellBuilder;

  // ========== 子路由配置 ==========

  /// 子路由列表（在外壳内容区域显示）
  final List<AppRoute> children;

  /// 默认子路由路径（应用启动时显示的子路由）
  final String defaultChildPath;

  // ========== 构造函数 ==========

  const ShellRouteConfig({
    required this.path,                       // 必填：路由路径
    required this.name,                       // 必填：路由名称
    required this.shellBuilder,               // 必填：外壳构建器
    required this.children,                   // 必填：子路由列表
    required this.defaultChildPath,           // 必填：默认子路由
  });

  @override
  String toString() =>
      'ShellRouteConfig(path: $path, name: $name, children: ${children.length})';
}

// ============================================================
// 路由常量
// ============================================================

/// 路由路径常量
///
/// 集中管理应用的路由路径，避免硬编码字符串。
/// 修改路径时只需更新常量定义。
///
/// ## 使用示例
/// ```dart
/// // 定义路由
/// AppRoute(path: RoutePaths.home, ...)
/// AppRoute(path: RoutePaths.profile, ...)
///
/// // 导航跳转
/// context.go(RoutePaths.profile)
/// ```
final class RoutePaths {
  // ========== 首页相关 ==========
  /// 首页路径
  static const String home = '/';

  /// 仪表盘路径
  static const String dashboard = '/dashboard';

  // ========== 用户相关 ==========
  /// 登录页路径
  static const String login = '/login';

  /// 注册页路径
  static const String register = '/register';

  /// 个人资料页路径
  static const String profile = '/profile';

  /// 设置页路径
  static const String settings = '/settings';

  // ========== 错误页面 ==========
  /// 404 页面路径
  static const String notFound = '/404';

  /// 错误页路径
  static const String error = '/error';

  // ========== 私有构造函数 ==========
  /// 私有构造函数，防止实例化
  RoutePaths._();
}

/// 路由名称常量
///
/// 集中管理应用的路由名称，用于编程式导航。
/// 名称比路径更稳定，路径修改时名称可以不变。
///
/// ## 使用示例
/// ```dart
/// // 定义路由
/// AppRoute(name: RouteNames.home, ...)
/// AppRoute(name: RouteNames.profile, ...)
///
/// // 编程式导航
/// context.goNamed(RouteNames.profile)
/// ```
///
/// ## 为什么同时需要 path 和 name？
///
/// | 特性       | Path (路径)          | Name (名称)        |
/// |-----------|---------------------|-------------------|
/// | 用途       | URL 显示            | 编程式导航         |
/// | 示例       | '/user/:id'        | 'userDetail'      |
/// | 稳定性     | 可能变化            | 相对稳定           |
/// | 参数传递    | 路径参数            | 命名参数           |
final class RouteNames {
  /// 首页名称
  static const String home = 'home';

  /// 仪表盘名称
  static const String dashboard = 'dashboard';

  /// 登录页名称
  static const String login = 'login';

  /// 注册页名称
  static const String register = 'register';

  /// 个人资料页名称
  static const String profile = 'profile';

  /// 设置页名称
  static const String settings = 'settings';

  /// 404 页面名称
  static const String notFound = 'notFound';

  /// 错误页名称
  static const String error = 'error';

  /// 私有构造函数，防止实例化
  RouteNames._();
}
