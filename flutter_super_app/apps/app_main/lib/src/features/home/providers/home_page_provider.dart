library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data.dart';

// ==================== 首页状态 Providers ====================

/// 首页数据仓库 Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return DataConfig.homeRepository;
});

/// 首页标签列表 Provider
///
/// 使用 FutureProvider 自动处理加载状态和错误状态
final homeTabsProvider = FutureProvider<List<HomeTabModel>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return await repository.getHomeTabs();
});

/// 首页当前选中标签索引 Provider
final homeCurrentIndexProvider = StateProvider<int>((ref) => 0);

/// 首页 PageView 滚动位置 Provider（0.0 - 1.0，用于动画插值）
final homeScrollPositionProvider = StateProvider<double>((ref) => 0.0);
