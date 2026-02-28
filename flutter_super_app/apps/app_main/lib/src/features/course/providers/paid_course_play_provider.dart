library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== 收费课程播放页状态 Providers ====================

/// 收费课程播放页购买状态 Provider
///
/// 管理指定课程是否已购买的状态
/// Key: courseId
final paidCoursePlayPurchaseProvider = StateProvider.family<bool, String>((ref, courseId) => false);

/// 收费课程播放页加载状态 Provider
///
/// 管理购买过程中的加载状态
final paidCoursePlayLoadingProvider = StateProvider<bool>((ref) => false);
