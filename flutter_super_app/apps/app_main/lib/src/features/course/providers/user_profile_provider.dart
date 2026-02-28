library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_components/ui_components.dart';

// ==================== 用户资料页状态 Providers ====================

/// 用户资料页滚动进度 Provider
///
/// 管理用户资料页的滚动进度状态（0.0 - 1.0）
/// 用于导航栏毛玻璃渐显动画
final userProfileScrollProgressProvider = StateProvider<double>((ref) => 0.0);

/// 用户资料页选中标签索引 Provider
///
/// 管理用户资料页当前选中的标签索引
/// 0: 主页, 1: 在学课程, 2: 参与评价, 3: 文章
final userProfileSelectedTabProvider = StateProvider<int>((ref) => 0);

/// 用户资料页标签列表
final userProfileTabs = [
  const UnderlineTabItem(id: '0', title: '主页'),
  const UnderlineTabItem(id: '1', title: '在学课程'),
  const UnderlineTabItem(id: '2', title: '参与评价'),
  const UnderlineTabItem(id: '3', title: '文章'),
];
