library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import '../models/target_type.dart';
import '../models/interaction_type.dart';
import '../repositories/interaction_repository.dart';

/// 交互服务 - 高度可扩展的通用交互系统
///
/// 核心功能：
/// 1. 点赞/取消点赞 - 适用于内容、话题、商品、评论等
/// 2. 收藏/取消收藏 - 适用于内容、话题、商品等
/// 3. 分享 - 记录分享行为和渠道
/// 4. 自定义交互 - 完全灵活的扩展点
///
/// 扩展性：
/// - 通过 InteractionType.custom 实现自定义交互类型
/// - 通过 metadata 存储任意扩展数据
/// - 适用于所有领域（内容、话题、商品、用户等）
final class InteractionService {
  final InteractionRepository _repository;
  final ApiClient _apiClient;

  InteractionService({
    required InteractionRepository repository,
    required ApiClient apiClient,
  })  : _repository = repository,
        _apiClient = apiClient;

  // ==================== 点赞系统 ====================

  /// 点赞目标
  ///
  /// 适用于：内容、话题、商品、评论、用户等
  Future<Result<void>> like({
    required String userId,
    required TargetRef target,
  }) async {
    try {
      Log.i('点赞: ${target.type.value}/${target.id}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/like',
        body: {
          'userId': userId,
          'target': target.toJson(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('点赞成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '点赞失败'),
      );
    } catch (e) {
      Log.e('点赞失败', error: e);
      return Result.failure(Exception('点赞失败: $e'));
    }
  }

  /// 取消点赞
  Future<Result<void>> unlike({
    required String userId,
    required TargetRef target,
  }) async {
    try {
      Log.i('取消点赞: ${target.type.value}/${target.id}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/unlike',
        body: {
          'userId': userId,
          'target': target.toJson(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('取消点赞成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '取消点赞失败'),
      );
    } catch (e) {
      Log.e('取消点赞失败', error: e);
      return Result.failure(Exception('取消点赞失败: $e'));
    }
  }

  /// 切换点赞状态
  ///
  /// 返回切换后的状态（true=已点赞，false=未点赞）
  Future<Result<bool>> toggleLike({
    required String userId,
    required TargetRef target,
  }) async {
    final checkResult = await hasLiked(userId: userId, target: target);
    if (checkResult.isFailure) {
      return Result.failure(checkResult.error ?? Exception('检查点赞状态失败'));
    }

    final isLiked = checkResult.valueOrThrow;
    if (isLiked) {
      final result = await unlike(userId: userId, target: target);
      if (result.isFailure) return Result.failure(result.error ?? Exception('操作失败'));
      return Result.success(false);
    } else {
      final result = await like(userId: userId, target: target);
      if (result.isFailure) return Result.failure(result.error ?? Exception('操作失败'));
      return Result.success(true);
    }
  }

  /// 检查是否已点赞
  Future<Result<bool>> hasLiked({
    required String userId,
    required TargetRef target,
  }) async {
    return await _repository.hasInteracted(
      userId: userId,
      target: target,
      type: InteractionType.like,
    );
  }

  // ==================== 收藏系统 ====================

  /// 收藏目标
  ///
  /// 适用于：内容、话题、商品、用户等
  Future<Result<void>> favorite({
    required String userId,
    required TargetRef target,
  }) async {
    try {
      Log.i('收藏: ${target.type.value}/${target.id}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/favorite',
        body: {
          'userId': userId,
          'target': target.toJson(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('收藏成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '收藏失败'),
      );
    } catch (e) {
      Log.e('收藏失败', error: e);
      return Result.failure(Exception('收藏失败: $e'));
    }
  }

  /// 取消收藏
  Future<Result<void>> unfavorite({
    required String userId,
    required TargetRef target,
  }) async {
    try {
      Log.i('取消收藏: ${target.type.value}/${target.id}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/unfavorite',
        body: {
          'userId': userId,
          'target': target.toJson(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('取消收藏成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '取消收藏失败'),
      );
    } catch (e) {
      Log.e('取消收藏失败', error: e);
      return Result.failure(Exception('取消收藏失败: $e'));
    }
  }

  /// 切换收藏状态
  Future<Result<bool>> toggleFavorite({
    required String userId,
    required TargetRef target,
  }) async {
    final checkResult = await hasFavorited(userId: userId, target: target);
    if (checkResult.isFailure) {
      return Result.failure(checkResult.error ?? Exception('检查收藏状态失败'));
    }

    final isFavorited = checkResult.valueOrThrow;
    if (isFavorited) {
      final result = await unfavorite(userId: userId, target: target);
      if (result.isFailure) return Result.failure(result.error ?? Exception('操作失败'));
      return Result.success(false);
    } else {
      final result = await favorite(userId: userId, target: target);
      if (result.isFailure) return Result.failure(result.error ?? Exception('操作失败'));
      return Result.success(true);
    }
  }

  /// 检查是否已收藏
  Future<Result<bool>> hasFavorited({
    required String userId,
    required TargetRef target,
  }) async {
    return await _repository.hasInteracted(
      userId: userId,
      target: target,
      type: InteractionType.favorite,
    );
  }

  // ==================== 分享系统 ====================

  /// 分享目标
  ///
  /// 参数：
  /// - [channel] 分享渠道（如：wechat、moments、weibo等）
  /// - [customMessage] 自定义分享文案（可选）
  /// - [platform] 平台信息（如：timeline、friend等，可选）
  ///
  /// 使用示例：
  /// ```dart
  /// await service.share(
  ///   userId: 'user123',
  ///   target: TargetRef.content('content123'),
  ///   channel: 'wechat',
  ///   platform: 'timeline',
  ///   customMessage: '推荐这个内容',
  /// );
  /// ```
  Future<Result<void>> share({
    required String userId,
    required TargetRef target,
    required String channel,
    String? platform,
    String? customMessage,
  }) async {
    try {
      Log.i('分享: ${target.type.value}/${target.id} 到 $channel');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/share',
        body: {
          'userId': userId,
          'target': target.toJson(),
          'metadata': {
            'channel': channel,
            if (platform != null) 'platform': platform,
            if (customMessage != null) 'customMessage': customMessage,
          },
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('分享成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '分享失败'),
      );
    } catch (e) {
      Log.e('分享失败', error: e);
      return Result.failure(Exception('分享失败: $e'));
    }
  }

  // ==================== 通用交互接口 ====================

  /// 执行自定义交互
  ///
  /// 用于扩展自定义交互类型
  ///
  /// 使用示例：
  /// ```dart
  /// // 打赏
  /// await service.interact(
  ///   userId: 'user123',
  ///   target: TargetRef.content('content123'),
  ///   type: InteractionType.custom,
  ///   metadata: {
  ///     'action': 'reward',
  ///     'currency': 'coin',
  ///     'amount': 100,
  ///   },
  /// );
  ///
  /// // 举报
  /// await service.interact(
  ///   userId: 'user123',
  ///   target: TargetRef.content('content123'),
  ///   type: InteractionType.report,
  ///   metadata: {
  ///     'reason': 'spam',
  ///     'description': '垃圾内容',
  ///   },
  /// );
  /// ```
  Future<Result<void>> interact({
    required String userId,
    required TargetRef target,
    required InteractionType type,
    Map<String, dynamic>? metadata,
  }) async {
    return await _repository.interact(
      userId: userId,
      target: target,
      type: type,
      metadata: metadata,
    );
  }

  /// 取消自定义交互
  Future<Result<void>> uninteract({
    required String userId,
    required TargetRef target,
    required InteractionType type,
  }) async {
    return await _repository.uninteract(
      userId: userId,
      target: target,
      type: type,
    );
  }

  // ==================== 统计查询 ====================

  /// 获取单个目标的统计数据
  ///
  /// 返回：点赞数、收藏数、分享数等
  /// 同时包含当前用户的交互状态
  Future<Result<InteractionStats>> getStats(TargetRef target) async {
    return await _repository.getStats(target);
  }

  /// 批量获取多个目标的统计数据
  ///
  /// 使用场景：
  /// - 列表页面批量显示统计信息
  /// - 减少网络请求次数
  ///
  /// 返回：`Map<String, InteractionStats>`，key 为 targetId
  Future<Result<Map<String, InteractionStats>>> getBatchStats(
    List<TargetRef> targets,
  ) async {
    try {
      Log.i('批量获取统计数据: ${targets.length} 个目标');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/stats/batch',
        body: {
          'targets': targets.map((t) => t.toJson()).toList(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final statsData = response.data!['data'] as Map<String, dynamic>;
        final statsMap = <String, InteractionStats>{};

        statsData.forEach((key, value) {
          statsMap[key] = InteractionStats.fromJson(value as Map<String, dynamic>);
        });

        Log.i('批量获取统计数据成功');
        return Result.success(statsMap);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量获取统计数据失败'),
      );
    } catch (e) {
      Log.e('批量获取统计数据失败', error: e);
      return Result.failure(Exception('批量获取统计数据失败: $e'));
    }
  }

  // ==================== 交互记录查询 ====================

  /// 获取用户的交互列表
  ///
  /// 参数：
  /// - [userId] 用户ID
  /// - [type] 交互类型过滤（可选）
  /// - [targetType] 目标类型过滤（可选）
  /// - [page] 页码
  /// - [pageSize] 每页数量
  ///
  /// 使用场景：
  /// - 查看用户的点赞列表
  /// - 查看用户的收藏列表
  /// - 查看用户的分享历史
  Future<Result<PagedResult<Interaction>>> getUserInteractions({
    required String userId,
    InteractionType? type,
    TargetType? targetType,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getUserInteractions(
      userId: userId,
      type: type,
      targetType: targetType,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 获取目标的交互记录列表
  ///
  /// 参数：
  /// - [target] 目标引用
  /// - [type] 交互类型过滤（可选）
  /// - [page] 页码
  /// - [pageSize] 每页数量
  ///
  /// 使用场景：
  /// - 查看谁点赞了这条内容
  /// - 查看谁收藏了这个商品
  Future<Result<PagedResult<Interaction>>> getTargetInteractions({
    required TargetRef target,
    InteractionType? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getTargetInteractions(
      target: target,
      type: type,
      page: page,
      pageSize: pageSize,
    );
  }

  // ==================== 批量操作 ====================

  /// 批量点赞
  Future<Result<void>> batchLike({
    required String userId,
    required List<TargetRef> targets,
  }) async {
    try {
      Log.i('批量点赞: ${targets.length} 个目标');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/like/batch',
        body: {
          'userId': userId,
          'targets': targets.map((t) => t.toJson()).toList(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('批量点赞成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量点赞失败'),
      );
    } catch (e) {
      Log.e('批量点赞失败', error: e);
      return Result.failure(Exception('批量点赞失败: $e'));
    }
  }

  /// 批量收藏
  Future<Result<void>> batchFavorite({
    required String userId,
    required List<TargetRef> targets,
  }) async {
    try {
      Log.i('批量收藏: ${targets.length} 个目标');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/interactions/favorite/batch',
        body: {
          'userId': userId,
          'targets': targets.map((t) => t.toJson()).toList(),
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('批量收藏成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量收藏失败'),
      );
    } catch (e) {
      Log.e('批量收藏失败', error: e);
      return Result.failure(Exception('批量收藏失败: $e'));
    }
  }
}
