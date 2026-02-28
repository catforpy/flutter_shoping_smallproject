library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== 免费课程播放页状态 Providers ====================

/// 课程播放页当前标签索引 Provider
///
/// 管理当前选中的标签索引（0: 章节, 1: 笔记）
final freeCoursePlayCurrentTabIndexProvider = StateProvider<int>((ref) => 0);

/// 课程播放页收藏状态 Provider
///
/// 管理当前课程的收藏状态
final freeCoursePlayFavoriteProvider = StateProvider<bool>((ref) => false);

/// 课程播放页横屏状态 Provider
///
/// 管理当前是否为横屏模式
final freeCoursePlayIsLandscapeProvider = StateProvider<bool>((ref) => false);

/// 课程播放页展开菜单状态 Provider
///
/// 管理目录菜单是否展开
final freeCoursePlayExpandMenuProvider = StateProvider<bool>((ref) => false);

/// 课程播放页当前章节索引 Provider
///
/// 管理当前选中的章节索引
final freeCoursePlayCurrentChapterIndexProvider = StateProvider<int>((ref) => 0);
