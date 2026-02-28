import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/app_route.dart';

/// 路由出口组件
///
/// 用于在嵌套路由中显示子路由的内容
///
/// 使用场景：
/// - 外壳路由中，用 RouterOutlet() 占位子路由内容显示的位置
/// - 底部导航栏布局中，右侧内容区域
/// - 左右布局中，右侧内容区域
///
/// 示例：
/// ```dart
/// Scaffold(
///   body: Row([
///     // 左侧导航栏（固定）
///     LeftNavigationBar(),
///     // 右侧内容区域（显示子路由）
///     Expanded(
///       child: RouterOutlet(),
///     ),
///   ]),
/// )
/// ```
class RouterOutlet extends StatelessWidget {
  /// 子路由的构建器（可选，用于自定义子路由的显示方式）
  final Widget Function(Widget child)? builder;

  const RouterOutlet({
    super.key,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // 注意：在 GoRouter 中，子路由的内容会自动渲染
    // 这个组件主要是作为一个语义化的占位符
    // 实际使用时，不需要显式使用 RouterOutlet
    // GoRouter 会自动处理子路由的渲染

    // 如果需要自定义子路由的显示方式，可以使用 builder
    final child = const SizedBox.shrink();

    return builder != null ? builder!(child) : child;
  }
}

/// 外壳路由助手类
///
/// 提供创建外壳路由的便捷方法
class ShellRouteHelper {
  /// 创建底部导航栏外壳
  ///
  /// 示例：
  /// ```dart
  /// ShellRouteConfig bottomNav = ShellRouteHelper.createBottomNavShell(
  ///   path: '/',
  ///   name: 'main',
  ///   items: [
  ///     BottomNavItem(icon: Icons.home, label: '首页', route: AppRoute(...)),
  ///     BottomNavItem(icon: Icons.explore, label: '发现', route: AppRoute(...)),
  ///   ],
  ///   defaultPath: '/home',
  /// );
  /// ```
  static ShellRouteConfig createBottomNavShell({
    required String path,
    required String name,
    required List<BottomNavItem> items,
    required String defaultPath,
  }) {
    return ShellRouteConfig(
      path: path,
      name: name,
      shellBuilder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _calculateSelectedIndex(items, state.uri.path),
            onTap: (index) {
              final item = items[index];
              // 导航到对应的路由
              context.go(item.route.path);
            },
            items: items
                .map((item) => BottomNavigationBarItem(
                      icon: Icon(item.icon),
                      label: item.label,
                    ))
                .toList(),
          ),
        );
      },
      children: items.map((item) => item.route).toList(),
      defaultChildPath: defaultPath,
    );
  }

  /// 创建左右布局外壳（左侧导航 + 右侧内容）
  ///
  /// 示例：
  /// ```dart
  /// ShellRouteConfig leftRight = ShellRouteHelper.createLeftRightShell(
  ///   path: '/',
  ///   name: 'main',
  ///   leftBar: LeftNavBar(...),
  ///   routes: [...],
  ///   defaultPath: '/home',
  /// );
  /// ```
  static ShellRouteConfig createLeftRightShell({
    required String path,
    required String name,
    required Widget leftBar,
    required List<AppRoute> routes,
    required String defaultPath,
    double leftBarWidth = 200,
  }) {
    return ShellRouteConfig(
      path: path,
      name: name,
      shellBuilder: (context, state, child) {
        return Scaffold(
          body: Row(
            children: [
              // 左侧导航栏（固定）
              SizedBox(
                width: leftBarWidth,
                child: leftBar,
              ),
              // 右侧内容区域（显示子路由）
              Expanded(child: child),
            ],
          ),
        );
      },
      children: routes,
      defaultChildPath: defaultPath,
    );
  }

  /// 计算当前选中的索引
  static int _calculateSelectedIndex(List<BottomNavItem> items, String currentPath) {
    for (int i = 0; i < items.length; i++) {
      if (currentPath.startsWith(items[i].route.path)) {
        return i;
      }
    }
    return 0;
  }
}

/// 底部导航项
class BottomNavItem {
  final IconData icon;
  final String label;
  final AppRoute route;

  const BottomNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
