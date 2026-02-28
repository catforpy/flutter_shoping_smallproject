library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';

// ==================== 课程详情页状态 Providers ====================

/// 课程详情页滚动进度 Provider
///
/// 管理课程详情页的垂直滚动进度（0.0 - 1.0）
/// 用于导航栏标题淡入淡出和毛玻璃效果
final courseDetailScrollProgressProvider = StateProvider<double>((ref) => 0.0);

/// 课程详情页当前标签索引 Provider
///
/// 管理当前选中的标签索引（0: 简介, 1: 目录, 2: 评价, 3: 推荐）
final courseDetailCurrentTabIndexProvider = StateProvider<int>((ref) => 0);

/// 课程详情页 PageView 滚动位置 Provider
///
/// 管理标签页横向滑动的进度（0.0 - 1.0）
/// 用于下划线动画插值
final courseDetailScrollPositionProvider = StateProvider<double>((ref) => 0.0);

/// 课程详情页收藏状态 Provider
///
/// 管理当前课程的收藏状态
final courseDetailFavoriteProvider = StateProvider<bool>((ref) => false);

/// 课程详情页标签列表
final courseDetailTabs = [
  const UnderlineTabItem(id: '0', title: '简介'),
  const UnderlineTabItem(id: '1', title: '目录'),
  const UnderlineTabItem(id: '2', title: '评价'),
  const UnderlineTabItem(id: '3', title: '推荐'),
];
