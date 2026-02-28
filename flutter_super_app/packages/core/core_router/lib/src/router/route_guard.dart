library;

import 'package:core_logging/core_logging.dart';

// ============================================================
// 路由守卫层
// ============================================================
// 设计理念：
// 1. 职责单一：每个守卫只负责一种权限检查
// 2. 可组合：多个守卫可以串联使用
// 3. 可扩展：轻松添加自定义守卫
// 4. 声明式：通过配置而非代码逻辑控制权限

// ============================================================
// 路由守卫基类
// ============================================================

/// 路由守卫
///
/// 在路由跳转前进行权限检查，决定是否允许访问。
/// 类似于后端的中间件或拦截器。
///
/// ## 什么是路由守卫？
///
/// 路由守卫是一种权限控制机制：
/// ```
/// 用户请求访问路由
///        ↓
///   路由守卫检查
///        ↓
///   通过？ ← 否 → 重定向到登录页/错误页
///        ↓ 是
///   继续导航
/// ```
///
/// ## 使用场景
/// - 认证检查：用户是否登录
/// - 角色检查：用户是否有权限访问
/// - 条件检查：是否完成特定流程（如填写资料）
/// - 自定义检查：任何业务逻辑判断
///
/// ## 使用示例
/// ```dart
/// // 定义认证守卫
/// final authGuard = AuthGuard(
///   isAuthenticated: () => userSession.isLoggedIn,
///   loginPath: '/login',
/// );
///
/// // 定义角色守卫
/// final adminGuard = RoleGuard(
///   getUserRoles: () => userSession.roles,
///   requiredRoles: ['admin'],
///   errorPath: '/forbidden',
/// );
///
/// // 创建守卫管理器
/// final guardManager = RouteGuardManager([
///   authGuard,
///   adminGuard,
/// ]);
///
/// // 应用到路由
/// final router = AppRouter(
///   config: routeConfig,
///   guardManager: guardManager,
/// );
/// ```
///
/// ## 与其他框架对比
///
/// ### GetX
/// ```dart
/// // GetX 使用 GetPage 的 middlewares
/// GetPage(
///   name: '/admin',
///   page: () => AdminPage(),
///   middlewares: [
///     GetMiddleware(
///       redirect: (route) {
///         if (!isAuthenticated) return '/login';
///         return null;
///       },
///     ),
///   ],
/// )
///
/// // 问题：
/// // 1. 守卫逻辑分散在各个页面
/// // 2. 难以复用和测试
/// // 3. 类型安全性差
/// ```
///
/// ### BLoC
/// ```dart
/// // BLoC 本身不提供守卫机制
/// // 需要在每个页面的 build 方法中检查
/// // 或配合 go_router 的 redirect
/// ```
///
/// ### React Router (Web 对比)
/// ```typescript
/// // React Router v6+ 的概念类似
/// const ProtectedRoute = ({ children }) => {
///   const auth = useAuth();
///   return auth.user ? children : <Navigate to="/login" />;
/// };
/// ```
abstract base class RouteGuard {
  // ========== 抽象属性 ==========

  /// 守卫名称（用于日志和调试）
  String get name;

  // ========== 抽象方法 ==========

  /// 检查是否允许访问
  ///
  /// 参数：
  /// - path: 目标路由路径
  ///
  /// 返回：true 表示允许访问，false 表示拒绝
  ///
  /// 示例：
  /// ```dart
  /// @override
  /// Future<bool> canAccess(String path) async {
  ///   // 检查用户是否登录
  ///   return await authService.isAuthenticated();
  /// }
  /// ```
  Future<bool> canAccess(String path);

  // ========== 可选属性 ==========

  /// 拒绝时的重定向路径
  ///
  /// 如果用户无权限访问，将重定向到该路径。
  /// 返回 null 表示不重定向（显示错误）。
  ///
  /// 示例：
  /// ```dart
  /// @override
  /// String get redirectTo => '/login'; // 重定向到登录页
  /// ```
  String? get redirectTo => null;
}

// ============================================================
// 内置守卫实现
// ============================================================

/// 认证守卫
///
/// 检查用户是否已登录。
///
/// ## 使用示例
/// ```dart
/// final authGuard = AuthGuard(
///   isAuthenticated: () {
///     // 从任何地方获取认证状态
///     return UserSession.isLoggedIn;
///   },
///   loginPath: '/login',
/// );
/// ```
///
/// ## 与 Riverpod 集成
/// ```dart
/// final authGuard = AuthGuard(
///   isAuthenticated: () {
///     final container = ProviderContainer();
///     final authState = container.read(authProvider);
///     return authState.isAuthenticated;
///   },
///   loginPath: '/login',
/// );
/// ```
final class AuthGuard extends RouteGuard {
  // ========== 属性 ==========

  /// 认证状态检查函数
  ///
  /// 返回 true 表示已登录，false 表示未登录。
  final bool Function() isAuthenticated;

  /// 登录页路径
  ///
  /// 未登录时重定向到此路径。
  final String loginPath;

  // ========== 构造函数 ==========

  AuthGuard({
    required this.isAuthenticated,            // 必填：认证检查函数
    this.loginPath = '/login',               // 默认登录页路径
  });

  // ========== RouteGuard 实现 ==========

  @override
  String get name => 'AuthGuard';

  @override
  Future<bool> canAccess(String path) async {
    final authenticated = isAuthenticated();
    if (!authenticated) {
      Log.w('用户未登录，重定向到登录页: $loginPath');
    }
    return authenticated;
  }

  @override
  String get redirectTo => loginPath;
}

// ============================================================

/// 角色守卫
///
/// 检查用户是否拥有指定角色。
///
/// ## 使用示例
/// ```dart
/// final adminGuard = RoleGuard(
///   getUserRoles: () => UserSession.roles,
///   requiredRoles: ['admin', 'superadmin'],
///   errorPath: '/forbidden',
/// );
/// ```
///
/// ## 常见角色
/// - admin: 管理员
/// - user: 普通用户
/// - guest: 访客
/// - superadmin: 超级管理员
///
/// ## 与认证守卫的区别
/// - AuthGuard: 检查是否登录
/// - RoleGuard: 检查是否有特定权限
///
/// 通常先检查认证，再检查角色：
/// ```dart
/// final guards = [
///   AuthGuard(...),  // 先检查是否登录
///   RoleGuard(...),  // 再检查是否有权限
/// ];
/// ```
final class RoleGuard extends RouteGuard {
  // ========== 属性 ==========

  /// 获取用户角色列表的函数
  ///
  /// 返回用户拥有的所有角色。
  final List<String> Function() getUserRoles;

  /// 需要的角色列表（满足任一即可）
  ///
  /// 用户拥有列表中的任一角色即可通过检查。
  final List<String> requiredRoles;

  /// 权限不足时的错误页路径
  ///
  /// 角色不足时重定向到此路径。
  final String? errorPath;

  // ========== 构造函数 ==========

  RoleGuard({
    required this.getUserRoles,               // 必填：获取角色函数
    required this.requiredRoles,              // 必填：需要的角色
    this.errorPath,                          // 可选：错误页路径
  });

  // ========== RouteGuard 实现 ==========

  @override
  String get name => 'RoleGuard';

  @override
  Future<bool> canAccess(String path) async {
    final userRoles = getUserRoles();
    // 检查用户是否拥有任一所需角色
    final hasRole = requiredRoles.any((role) => userRoles.contains(role));
    if (!hasRole) {
      Log.w('用户角色不足: 需要角色 $requiredRoles, 拥有角色 $userRoles');
    }
    return hasRole;
  }

  @override
  String? get redirectTo => errorPath;
}

// ============================================================
// 守卫管理器
// ============================================================

/// 路由守卫管理器
///
/// 管理多个路由守卫，按顺序执行检查。
///
/// ## 工作流程
/// ```
/// 用户请求访问路由
///        ↓
///   Guard 1 检查 → 失败? → 重定向
///        ↓ 通过
///   Guard 2 检查 → 失败? → 重定向
///        ↓ 通过
///   Guard 3 检查 → 失败? → 重定向
///        ↓ 通过
///   允许访问
/// ```
///
/// ## 使用示例
/// ```dart
/// // 创建守卫管理器
/// final guardManager = RouteGuardManager([
///   AuthGuard(
///     isAuthenticated: () => UserSession.isLoggedIn,
///     loginPath: '/login',
///   ),
///   RoleGuard(
///     getUserRoles: () => UserSession.roles,
///     requiredRoles: ['admin'],
///     errorPath: '/forbidden',
///   ),
/// ]);
///
/// // 添加到路由配置
/// final router = AppRouter(
///   config: routeConfig,
///   guardManager: guardManager,
/// );
/// ```
///
/// ## 动态添加守卫
/// ```dart
/// // 添加新守卫（返回新管理器）
/// final newManager = guardManager.addGuard(
///   CustomGuard(...),
/// );
///
/// // 移除守卫（返回新管理器）
/// final newManager = guardManager.removeGuard(authGuard);
/// ```
final class RouteGuardManager {
  // ========== 属性 ==========

  /// 守卫列表（按执行顺序）
  final List<RouteGuard> guards;

  // ========== 构造函数 ==========

  const RouteGuardManager(this.guards);

  // ========== 方法 ==========

  /// 检查所有守卫
  ///
  /// 按顺序执行所有守卫检查，任一守卫返回 false 则停止。
  ///
  /// 参数：
  /// - path: 目标路由路径
  ///
  /// 返回：
  /// - null: 所有守卫通过，允许访问
  /// - String: 第一个失败的守卫的重定向路径
  ///
  /// 示例：
  /// ```dart
  /// final result = await guardManager.checkAll('/admin');
  /// if (result != null) {
  ///   // 重定向到 result
  ///   context.go(result);
  /// }
  /// ```
  Future<String?> checkAll(String path) async {
    for (final guard in guards) {
      final canAccess = await guard.canAccess(path);
      if (!canAccess) {
        // 返回重定向路径
        return guard.redirectTo ?? '/login';
      }
    }
    // 所有守卫通过
    return null;
  }

  /// 添加守卫
  ///
  /// 返回包含新守卫的新管理器实例。
  ///
  /// 参数：
  /// - guard: 要添加的守卫
  ///
  /// 返回：新的守卫管理器
  RouteGuardManager addGuard(RouteGuard guard) {
    return RouteGuardManager([...guards, guard]);
  }

  /// 移除守卫
  ///
  /// 返回移除指定守卫后的新管理器实例。
  ///
  /// 参数：
  /// - guard: 要移除的守卫
  ///
  /// 返回：新的守卫管理器
  RouteGuardManager removeGuard(RouteGuard guard) {
    return RouteGuardManager(
      guards.where((g) => g.name != guard.name).toList(),
    );
  }
}
