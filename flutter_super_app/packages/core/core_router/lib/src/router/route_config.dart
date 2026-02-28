library;

import 'package:flutter/material.dart';
import 'package:core_logging/core_logging.dart';
import '../models/app_route.dart';

// ============================================================
// 路由配置层
// ============================================================
// 设计理念：
// 1. 不可变数据结构（每次操作返回新实例）
// 2. 集中式路由管理
// 3. 支持动态添加/删除路由（适用于微前端、模块化场景）
// 4. 递归查找嵌套路由

// ============================================================
// 路由配置
// ============================================================

/// 路由配置
///
/// 集中管理应用的所有路由配置。
/// 提供路由的增删改查操作，支持嵌套路由递归查找。
///
/// ## 设计理念
/// - 不可变性：所有修改操作返回新实例，不修改原对象
/// - 声明式：配置即代码，易于维护和测试
/// - 可扩展：支持动态添加路由（微前端、模块化场景）
///
/// ## 使用示例
/// ```dart
/// // 创建初始配置
/// final config = RouteConfig(
///   initialPath: '/',
///   routes: [
///     AppRoute(path: '/', name: 'home', builder: HomePage()),
///     AppRoute(path: '/login', name: 'login', builder: LoginPage()),
///   ],
/// );
///
/// // 添加新路由（返回新配置）
/// final newConfig = config.addRoute(
///   AppRoute(path: '/settings', name: 'settings', builder: SettingsPage()),
/// );
///
/// // 查找路由
/// final route = config.getRoute('/settings');
/// final routeByName = config.getRouteByName('settings');
/// ```
///
/// ## 与其他框架对比
///
/// ### GetX
/// ```dart
/// // GetX 使用全局路由表
/// final getPages = [
///   GetPage(name: '/', page: () => HomePage()),
///   GetPage(name: '/login', page: () => LoginPage()),
/// ];
///
/// // 问题：
/// // 1. 可变性：直接修改全局数组
/// // 2. 无类型：使用字符串 name
/// // 3. 难以测试：全局状态难以 mock
/// ```
///
/// ### BLoC + go_router
/// ```dart
/// // BLoC 不管理路由配置
/// // 直接使用 go_router 的配置方式
/// final router = GoRouter(
///   routes: [...],
/// );
///
/// // 我们的方案：提供额外的配置管理层
/// final config = RouteConfig(...);
/// final router = AppRouter(config: config);
/// ```
///
/// ### Provider
/// ```dart
/// // Provider 只做状态管理
/// // 路由配置由其他库处理
/// ```
final class RouteConfig {
  // ========== 路由列表 ==========

  /// 普通路由列表（支持嵌套）
  final List<AppRoute> routes;

  /// 外壳路由列表（固定布局 + 动态内容）
  final List<ShellRouteConfig> shellRoutes;

  // ========== 特殊路由 ==========

  /// 应用初始路径（启动时显示的页面）
  final String initialPath;

  /// 404 页面路径（路由未找到时显示）
  final String notFoundPath;

  /// 错误页路径（路由错误时显示）
  final String errorPath;

  // ========== 构造函数 ==========

  const RouteConfig({
    this.routes = const [],                // 默认空列表
    this.shellRoutes = const [],            // 默认空列表
    this.initialPath = '/',                 // 默认首页
    this.notFoundPath = '/404',             // 默认 404 路径
    this.errorPath = '/error',              // 默认错误页路径
  });

  // ========== Getter 方法 ==========

  /// 获取初始路由
  ///
  /// 根据 initialPath 查找对应的路由配置。
  /// 如果未找到，返回一个默认的占位路由。
  AppRoute get initialRoute {
    return routes.firstWhere(
      (route) => route.path == initialPath,
      orElse: () => AppRoute(
        path: initialPath,
        name: 'initial',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Initial Route Not Found')),
        ),
      ),
    );
  }

  // ========== 查询方法 ==========

  /// 根据路径查找路由
  ///
  /// 支持递归查找子路由（多层嵌套）。
  ///
  /// 参数：
  /// - path: 路由路径（如 '/home', '/user/profile'）
  ///
  /// 返回：找到的路由，未找到返回 null
  ///
  /// 示例：
  /// ```dart
  /// final route = config.getRoute('/user/profile');
  /// if (route != null) {
  ///   print('找到路由: ${route.name}');
  /// }
  /// ```
  AppRoute? getRoute(String path) {
    return _searchRoute(routes, path);
  }

  /// 递归搜索路由（按路径）
  ///
  /// 深度优先搜索，支持多层嵌套。
  AppRoute? _searchRoute(List<AppRoute> routeList, String path) {
    for (final route in routeList) {
      // 找到匹配的路由
      if (route.path == path) {
        return route;
      }
      // 递归搜索子路由
      if (route.children != null) {
        final found = _searchRoute(route.children!, path);
        if (found != null) {
          return found;
        }
      }
    }
    Log.w('路由未找到: $path');
    return null;
  }

  /// 根据名称查找路由
  ///
  /// 支持递归查找子路由（多层嵌套）。
  ///
  /// 参数：
  /// - name: 路由名称（如 'home', 'userProfile'）
  ///
  /// 返回：找到的路由，未找到返回 null
  ///
  /// 示例：
  /// ```dart
  /// final route = config.getRouteByName('userProfile');
  /// if (route != null) {
  ///   context.go(route.path);
  /// }
  /// ```
  AppRoute? getRouteByName(String name) {
    return _searchRouteByName(routes, name);
  }

  /// 递归搜索路由（按名称）
  ///
  /// 深度优先搜索，支持多层嵌套。
  AppRoute? _searchRouteByName(List<AppRoute> routeList, String name) {
    for (final route in routeList) {
      // 找到匹配的路由
      if (route.name == name) {
        return route;
      }
      // 递归搜索子路由
      if (route.children != null) {
        final found = _searchRouteByName(route.children!, name);
        if (found != null) {
          return found;
        }
      }
    }
    Log.w('路由名称未找到: $name');
    return null;
  }

  // ========== 修改方法（不可变） ==========

  /// 添加单个路由
  ///
  /// 返回新的配置实例，原配置不变。
  ///
  /// 参数：
  /// - route: 要添加的路由
  ///
  /// 返回：包含新路由的新配置
  ///
  /// 示例：
  /// ```dart
  /// final newConfig = config.addRoute(
  ///   AppRoute(
  ///     path: '/settings',
  ///     name: 'settings',
  ///     builder: (context, state) => SettingsPage(),
  ///   ),
  /// );
  /// ```
  RouteConfig addRoute(AppRoute route) {
    return RouteConfig(
      routes: [...routes, route],            // 创建新列表
      shellRoutes: shellRoutes,
      initialPath: initialPath,
      notFoundPath: notFoundPath,
      errorPath: errorPath,
    );
  }

  /// 批量添加路由
  ///
  /// 返回新的配置实例，原配置不变。
  ///
  /// 参数：
  /// - newRoutes: 要添加的路由列表
  ///
  /// 返回：包含新路由的新配置
  ///
  /// 示例：
  /// ```dart
  /// final userRoutes = [
  ///   AppRoute(path: '/profile', name: 'profile', ...),
  ///   AppRoute(path: '/settings', name: 'settings', ...),
  /// ];
  /// final newConfig = config.addRoutes(userRoutes);
  /// ```
  RouteConfig addRoutes(List<AppRoute> newRoutes) {
    return RouteConfig(
      routes: [...routes, ...newRoutes],       // 合并列表
      shellRoutes: shellRoutes,
      initialPath: initialPath,
      notFoundPath: notFoundPath,
      errorPath: errorPath,
    );
  }

  /// 添加外壳路由
  ///
  /// 返回新的配置实例，原配置不变。
  ///
  /// 参数：
  /// - shellRoute: 要添加的外壳路由
  ///
  /// 返回：包含新外壳路由的新配置
  ///
  /// 示例：
  /// ```dart
  /// final newConfig = config.addShellRoute(
  ///   ShellRouteConfig(
  ///     path: '/',
  ///     name: 'main',
  ///     shellBuilder: (context, state, child) => MainShell(child),
  ///     children: [...],
  ///     defaultChildPath: '/home',
  ///   ),
  /// );
  /// ```
  RouteConfig addShellRoute(ShellRouteConfig shellRoute) {
    return RouteConfig(
      routes: routes,
      shellRoutes: [...shellRoutes, shellRoute], // 创建新列表
      initialPath: initialPath,
      notFoundPath: notFoundPath,
      errorPath: errorPath,
    );
  }

  /// 移除路由
  ///
  /// 返回新的配置实例，原配置不变。
  ///
  /// 参数：
  /// - path: 要移除的路由路径
  ///
  /// 返回：移除指定路由后的新配置
  ///
  /// 示例：
  /// ```dart
  /// final newConfig = config.removeRoute('/temp-route');
  /// ```
  RouteConfig removeRoute(String path) {
    return RouteConfig(
      routes: routes.where((route) => route.path != path).toList(), // 过滤
      shellRoutes: shellRoutes,
      initialPath: initialPath,
      notFoundPath: notFoundPath,
      errorPath: errorPath,
    );
  }

  // ========== 重写方法 ==========

  @override
  String toString() =>
      'RouteConfig(routes: ${routes.length}, shells: ${shellRoutes.length}, initial: $initialPath)';
}
