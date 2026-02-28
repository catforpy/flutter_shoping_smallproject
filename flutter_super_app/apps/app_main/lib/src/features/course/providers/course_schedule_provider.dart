library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== 课程表页面状态 Providers ====================

/// 课程表页面提醒文本 Provider
///
/// 管理课程提醒设置的显示文本
final courseScheduleTextProvider = StateProvider<String?>((ref) => null);

/// 课程表页面已加入课程列表 Provider
///
/// 管理已加入课表的课程列表
final courseScheduleAddedCoursesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
