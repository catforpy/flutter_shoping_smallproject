import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:core_router/core_router.dart';

void main() {
  group('AppRoute', () {
    test('should create route with required fields', () {
      final route = AppRoute(
        path: '/test',
        name: 'test',
        builder: (context, state) => const SizedBox(),
      );
      expect(route.path, '/test');
      expect(route.name, 'test');
    });

    test('should create route with all fields', () {
      final route = AppRoute(
        path: '/test',
        name: 'test',
        builder: testBuilder,
        title: 'Test Page',
        icon: Icons.home,
      );
      expect(route.title, 'Test Page');
      expect(route.icon, Icons.home);
    });
  });

  group('RoutePaths', () {
    test('should have correct path constants', () {
      expect(RoutePaths.home, '/');
      expect(RoutePaths.login, '/login');
      expect(RoutePaths.profile, '/profile');
      expect(RoutePaths.settings, '/settings');
    });
  });

  group('RouteNames', () {
    test('should have correct name constants', () {
      expect(RouteNames.home, 'home');
      expect(RouteNames.login, 'login');
      expect(RouteNames.profile, 'profile');
      expect(RouteNames.settings, 'settings');
    });
  });

  group('RouteConfig', () {
    test('should create config with default values', () {
      final config = const RouteConfig();
      expect(config.routes, isEmpty);
      expect(config.initialPath, '/');
      expect(config.notFoundPath, '/404');
    });

    test('should create config with routes', () {
      final routes = [
        AppRoute(
          path: '/',
          name: 'home',
          builder: testBuilder,
        ),
      ];
      final config = RouteConfig(routes: routes);
      expect(config.routes.length, 1);
      expect(config.routes.first.path, '/');
    });

    test('should add route', () {
      final config = const RouteConfig().addRoute(
        AppRoute(
          path: '/test',
          name: 'test',
          builder: testBuilder,
        ),
      );
      expect(config.routes.length, 1);
      expect(config.routes.first.path, '/test');
    });

    test('should add multiple routes', () {
      final config = const RouteConfig().addRoutes([
        AppRoute(
          path: '/test1',
          name: 'test1',
          builder: testBuilder,
        ),
        AppRoute(
          path: '/test2',
          name: 'test2',
          builder: testBuilder,
        ),
      ]);
      expect(config.routes.length, 2);
    });

    test('should remove route', () {
      final config = RouteConfig(routes: [
        AppRoute(
          path: '/test',
          name: 'test',
          builder: testBuilder,
        ),
      ]).removeRoute('/test');
      expect(config.routes, isEmpty);
    });

    test('should find route by path', () {
      final config = RouteConfig(routes: [
        AppRoute(
          path: '/test',
          name: 'test',
          builder: testBuilder,
        ),
      ]);
      final route = config.getRoute('/test');
      expect(route, isNotNull);
      expect(route!.name, 'test');
    });

    test('should return null when route not found', () {
      final config = RouteConfig(routes: [
        AppRoute(
          path: '/test',
          name: 'test',
          builder: testBuilder,
        ),
      ]);
      final route = config.getRoute('/notfound');
      expect(route, isNull);
    });

    test('should find route by name', () {
      final config = RouteConfig(routes: [
        AppRoute(
          path: '/test',
          name: 'testRoute',
          builder: testBuilder,
        ),
      ]);
      final route = config.getRouteByName('testRoute');
      expect(route, isNotNull);
      expect(route!.path, '/test');
    });
  });

  group('AuthGuard', () {
    test('should allow access when authenticated', () async {
      final guard = AuthGuard(
        isAuthenticated: () => true,
      );
      final result = await guard.canAccess('/profile');
      expect(result, true);
    });

    test('should deny access when not authenticated', () async {
      final guard = AuthGuard(
        isAuthenticated: () => false,
      );
      final result = await guard.canAccess('/profile');
      expect(result, false);
    });

    test('should return login path on deny', () async {
      final guard = AuthGuard(
        isAuthenticated: () => false,
        loginPath: '/login',
      );
      await guard.canAccess('/profile');
      expect(guard.redirectTo, '/login');
    });

    test('should use custom login path', () {
      final guard = AuthGuard(
        isAuthenticated: () => false,
        loginPath: '/signin',
      );
      expect(guard.loginPath, '/signin');
      expect(guard.redirectTo, '/signin');
    });
  });

  group('RoleGuard', () {
    test('should allow access when user has role', () async {
      final guard = RoleGuard(
        getUserRoles: () => ['admin', 'user'],
        requiredRoles: ['admin'],
      );
      final result = await guard.canAccess('/admin');
      expect(result, true);
    });

    test('should deny access when user lacks role', () async {
      final guard = RoleGuard(
        getUserRoles: () => ['user'],
        requiredRoles: ['admin'],
      );
      final result = await guard.canAccess('/admin');
      expect(result, false);
    });

    test('should allow access when user has any required role', () async {
      final guard = RoleGuard(
        getUserRoles: () => ['user'],
        requiredRoles: ['admin', 'user'],
      );
      final result = await guard.canAccess('/dashboard');
      expect(result, true);
    });
  });

  group('RouteGuardManager', () {
    test('should pass when all guards allow', () async {
      final manager = RouteGuardManager([
        AuthGuard(isAuthenticated: () => true),
      ]);
      final result = await manager.checkAll('/profile');
      expect(result, isNull);
    });

    test('should redirect when first guard denies', () async {
      final manager = RouteGuardManager([
        AuthGuard(isAuthenticated: () => false),
      ]);
      final result = await manager.checkAll('/profile');
      expect(result, '/login');
    });

    test('should check all guards', () async {
      final manager = RouteGuardManager([
        AuthGuard(isAuthenticated: () => true),
        RoleGuard(
          getUserRoles: () => ['admin'],
          requiredRoles: ['admin'],
        ),
      ]);
      final result = await manager.checkAll('/admin');
      expect(result, isNull);
    });

    test('should stop at first failing guard', () async {
      final manager = RouteGuardManager([
        AuthGuard(isAuthenticated: () => true),
        RoleGuard(
          getUserRoles: () => ['user'],
          requiredRoles: ['admin'],
        ),
      ]);
      final result = await manager.checkAll('/admin');
      expect(result, isNotNull);
    });

    test('should add guard', () {
      final manager = const RouteGuardManager([]);
      final newManager = manager.addGuard(
        AuthGuard(isAuthenticated: () => true),
      );
      expect(newManager.guards.length, 1);
    });

    test('should remove guard', () {
      final guard = AuthGuard(isAuthenticated: () => true);
      final manager = RouteGuardManager([guard]);
      final newManager = manager.removeGuard(guard);
      expect(newManager.guards, isEmpty);
    });
  });

  group('AppRouter', () {
    test('should create router with config', () {
      final config = RouteConfig(routes: [
        AppRoute(
          path: '/',
          name: 'home',
          builder: testBuilder,
        ),
      ]);
      final router = AppRouter(config: config);
      expect(router.config, config);
    });

    test('should create router with guards', () {
      final config = RouteConfig(routes: [
        AppRoute(
          path: '/',
          name: 'home',
          builder: testBuilder,
        ),
      ]);
      final guards = RouteGuardManager([
        AuthGuard(isAuthenticated: () => true),
      ]);
      final router = AppRouter(
        config: config,
        guardManager: guards,
      );
      expect(router.guardManager, guards);
    });
  });
}

// Test helper
Widget testBuilder(BuildContext context, GoRouterState state) {
  return const SizedBox();
}
