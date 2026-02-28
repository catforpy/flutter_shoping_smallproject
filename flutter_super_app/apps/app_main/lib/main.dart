library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:core_router/core_router.dart';
import 'src/router/app_routes.dart';

/// 全局导航 Key（用于悬浮窗等需要独立 context 的场景）
/// Navigator 的 overlay 在路由变化时会保持存在，因此适合用于悬浮窗
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 创建应用路由器
final appRouter = AppRouter(config: appRouteConfig);

/// 全局悬浮窗管理器
class FloatingOverlayManager extends ChangeNotifier {
  final List<OverlayEntry> _entries = [];

  /// 插入悬浮窗
  void insert(OverlayEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  /// 移除悬浮窗
  void remove(OverlayEntry entry) {
    _entries.remove(entry);
      notifyListeners();
  }

  /// 获取所有悬浮窗
  List<OverlayEntry> get entries => List.unmodifiable(_entries);

  /// 清除所有悬浮窗
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}

/// 全局悬浮窗管理器实例
final FloatingOverlayManager floatingOverlayManager = FloatingOverlayManager();

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: floatingOverlayManager,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              // 主应用
              MaterialApp.router(
                title: 'Flutter 超级应用',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
                ),
                routerConfig: appRouter.createRouter(
                  navigatorKey: navigatorKey,
                ),
                debugShowCheckedModeBanner: false,
              ),
              // 悬浮窗层（独立于路由系统）
              ...floatingOverlayManager.entries.map((entry) => entry.builder(context)),
            ],
          ),
        );
      },
    );
  }
}
