library;

import 'package:core_base/core_base.dart';
import '../models/target_type.dart';
import '../models/interaction_type.dart';

/// 交互仓库接口
///
/// 定义交互数据访问的抽象层
/// 支持点赞、收藏、分享等通用交互操作
abstract class InteractionRepository {
  /// 执行交互
  ///
  /// 参数：
  /// - [userId] 用户ID
  /// - [target] 目标引用
  /// - [type] 交互类型
  /// - [metadata] 自定义元数据（可选）
  Future<Result<void>> interact({
    required String userId,
    required TargetRef target,
    required InteractionType type,
    Map<String, dynamic>? metadata,
  });

  /// 取消交互
  ///
  /// 参数：
  /// - [userId] 用户ID
  /// - [target] 目标引用
  /// - [type] 交互类型
  Future<Result<void>> uninteract({
    required String userId,
    required TargetRef target,
    required InteractionType type,
  });

  /// 切换交互状态
  ///
  /// 如果已交互则取消，否则执行交互
  Future<Result<bool>> toggleInteraction({
    required String userId,
    required TargetRef target,
    required InteractionType type,
    Map<String, dynamic>? metadata,
  });

  /// 检查用户是否已交互
  Future<Result<bool>> hasInteracted({
    required String userId,
    required TargetRef target,
    required InteractionType type,
  });

  /// 获取单个目标的统计数据
  Future<Result<InteractionStats>> getStats(TargetRef target);

  /// 批量获取多个目标的统计数据
  Future<Result<Map<String, InteractionStats>>> getBatchStats(
    List<TargetRef> targets,
  );

  /// 获取用户的交互列表
  Future<Result<PagedResult<Interaction>>> getUserInteractions({
    required String userId,
    InteractionType? type,
    TargetType? targetType,
    int page = 1,
    int pageSize = 20,
  });

  /// 获取目标的交互记录列表
  Future<Result<PagedResult<Interaction>>> getTargetInteractions({
    required TargetRef target,
    InteractionType? type,
    int page = 1,
    int pageSize = 20,
  });

  /// 清除缓存
  Future<void> clearCache();
}
