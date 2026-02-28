library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import 'package:service_interaction/service_interaction.dart';
import '../models/comment.dart';
import '../repositories/comment_repository.dart';

/// 评论服务 - 高度可扩展的评论系统
///
/// 核心功能：
/// 1. 发布评论 - 适用于内容、话题、商品等
/// 2. 回复评论 - 支持多级回复
/// 3. 删除/编辑评论
/// 4. 点赞评论
/// 5. 评论查询（热门、最新、最早）
///
/// 扩展性：
/// - 通过 Comment.metadata 存储自定义评论数据
/// - 支持图片评论、语音评论、评分评论等
/// - 适用于所有领域
final class CommentService {
  final CommentRepository _repository;
  final ApiClient _apiClient;

  CommentService({
    required CommentRepository repository,
    required ApiClient apiClient,
  })  : _repository = repository,
        _apiClient = apiClient;

  // ==================== 发布评论 ====================

  /// 创建评论
  ///
  /// 参数：
  /// - [userId] 用户ID
  /// - [target] 目标引用（内容、话题、商品等）
  /// - [content] 评论内容
  /// - [parentId] 父评论ID（回复时填写）
  /// - [replyToUserId] 回复给的用户ID（用于@提醒）
  /// - [metadata] 自定义元数据（图片、语音、评分等）
  ///
  /// 使用示例：
  /// ```dart
  /// // 普通评论
  /// await service.createComment(
  ///   userId: 'user123',
  ///   target: TargetRef.content('content123'),
  ///   content: '这是我的评论',
  /// );
  ///
  /// // 图片评论
  /// await service.createComment(
  ///   userId: 'user123',
  ///   target: TargetRef.product('product123'),
  ///   content: '商品不错',
  ///   metadata: {
  ///     'images': ['url1', 'url2'],
  ///     'rating': 5,
  ///   },
  /// );
  ///
  /// // 回复评论
  /// await service.createComment(
  ///   userId: 'user123',
  ///   target: TargetRef.content('content123'),
  ///   content: '同意你的观点',
  ///   parentId: 'comment456',
  ///   replyToUserId: 'user789',
  /// );
  /// ```
  Future<Result<Comment>> createComment({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
    String? replyToUserId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Log.i('创建评论: ${target.type.value}/${target.id}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/comments',
        body: {
          'userId': userId,
          'target': target.toJson(),
          'content': content,
          if (parentId != null) 'parentId': parentId,
          if (replyToUserId != null) 'replyToUserId': replyToUserId,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final commentData = response.data!['data'] as Map<String, dynamic>;
        final comment = Comment.fromJson(commentData);

        Log.i('创建评论成功: ${comment.id}');
        return Result.success(comment);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '创建评论失败'),
      );
    } catch (e) {
      Log.e('创建评论失败', error: e);
      return Result.failure(Exception('创建评论失败: $e'));
    }
  }

  /// 回复评论 - 便捷方法
  ///
  /// 参数：
  /// - [userId] 用户ID
  /// - [commentId] 要回复的评论ID
  /// - [content] 回复内容
  /// - [replyToUserId] 回复给的用户ID
  /// - [metadata] 自定义元数据
  Future<Result<Comment>> replyComment({
    required String userId,
    required String commentId,
    required String content,
    String? replyToUserId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Log.i('回复评论: $commentId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/comments/$commentId/reply',
        body: {
          'userId': userId,
          'content': content,
          if (replyToUserId != null) 'replyToUserId': replyToUserId,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final commentData = response.data!['data'] as Map<String, dynamic>;
        final comment = Comment.fromJson(commentData);

        Log.i('回复评论成功: ${comment.id}');
        return Result.success(comment);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '回复评论失败'),
      );
    } catch (e) {
      Log.e('回复评论失败', error: e);
      return Result.failure(Exception('回复评论失败: $e'));
    }
  }

  // ==================== 编辑/删除 ====================

  /// 删除评论
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      Log.i('删除评论: $commentId');

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/comments/$commentId',
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('删除评论成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '删除评论失败'),
      );
    } catch (e) {
      Log.e('删除评论失败', error: e);
      return Result.failure(Exception('删除评论失败: $e'));
    }
  }

  /// 更新评论内容
  Future<Result<Comment>> updateComment({
    required String commentId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Log.i('更新评论: $commentId');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/comments/$commentId',
        body: {
          'content': content,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final commentData = response.data!['data'] as Map<String, dynamic>;
        final comment = Comment.fromJson(commentData);

        Log.i('更新评论成功');
        return Result.success(comment);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '更新评论失败'),
      );
    } catch (e) {
      Log.e('更新评论失败', error: e);
      return Result.failure(Exception('更新评论失败: $e'));
    }
  }

  // ==================== 点赞评论 ====================

  /// 点赞评论
  Future<Result<void>> likeComment({
    required String userId,
    required String commentId,
  }) async {
    try {
      Log.i('点赞评论: $commentId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/comments/$commentId/like',
        body: {'userId': userId},
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('点赞评论成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '点赞评论失败'),
      );
    } catch (e) {
      Log.e('点赞评论失败', error: e);
      return Result.failure(Exception('点赞评论失败: $e'));
    }
  }

  /// 取消点赞评论
  Future<Result<void>> unlikeComment({
    required String userId,
    required String commentId,
  }) async {
    try {
      Log.i('取消点赞评论: $commentId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/comments/$commentId/unlike',
        body: {'userId': userId},
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('取消点赞评论成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '取消点赞评论失败'),
      );
    } catch (e) {
      Log.e('取消点赞评论失败', error: e);
      return Result.failure(Exception('取消点赞评论失败: $e'));
    }
  }

  // ==================== 查询评论 ====================

  /// 获取评论详情
  Future<Result<Comment>> getComment(String commentId) async {
    return await _repository.getComment(commentId);
  }

  /// 获取目标的评论列表（根评论）
  ///
  /// 参数：
  /// - [query] 评论查询条件
  ///
  /// 使用示例：
  /// ```dart
  /// // 获取内容的评论（热门排序）
  /// final result = await service.getComments(
  ///   CommentQuery(
  ///     target: TargetRef.content('content123'),
  ///     sortType: CommentSortType.hot,
  ///   ),
  /// );
  ///
  /// // 只看作者的评论
  /// final result = await service.getComments(
  ///   CommentQuery(
  ///     target: TargetRef.content('content123'),
  ///     authorUserId: 'author123',
  ///   ),
  /// );
  /// ```
  Future<Result<PagedResult<Comment>>> getComments(CommentQuery query) async {
    try {
      Log.i('获取评论列表: ${query.target.type.value}/${query.target.id}');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/comments',
        queryParameters: query.toQueryParams(),
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final commentsData = data['items'] as List;
        final comments = commentsData
            .map((json) => Comment.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取评论列表成功: ${comments.length} 条');
        return Result.success(
          PagedResult(
            data: comments,
            pagination: Pagination(
              page: query.page,
              pageSize: query.pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取评论列表失败'),
      );
    } catch (e) {
      Log.e('获取评论列表失败', error: e);
      return Result.failure(Exception('获取评论列表失败: $e'));
    }
  }

  /// 获取评论的回复列表
  ///
  /// 参数：
  /// - [commentId] 评论ID
  /// - [page] 页码
  /// - [pageSize] 每页数量
  Future<Result<PagedResult<Comment>>> getReplies({
    required String commentId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Log.i('获取回复列表: $commentId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/comments/$commentId/replies',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final repliesData = data['items'] as List;
        final replies = repliesData
            .map((json) => Comment.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取回复列表成功: ${replies.length} 条');
        return Result.success(
          PagedResult(
            data: replies,
            pagination: Pagination(
              page: page,
              pageSize: pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取回复列表失败'),
      );
    } catch (e) {
      Log.e('获取回复列表失败', error: e);
      return Result.failure(Exception('获取回复列表失败: $e'));
    }
  }

  // ==================== 用户相关 ====================

  /// 获取用户的评论列表
  ///
  /// 使用场景：
  /// - 查看用户发布过的所有评论
  Future<Result<PagedResult<Comment>>> getUserComments({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getUserComments(
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 获取用户收到的回复
  ///
  /// 使用场景：
  /// - 通知中心
  /// - 查看别人对我的评论的回复
  Future<Result<PagedResult<Comment>>> getUserReplies({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getUserReplies(
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }

  // ==================== 批量操作 ====================

  /// 批量删除评论
  Future<Result<void>> batchDeleteComments(List<String> commentIds) async {
    try {
      Log.i('批量删除评论: ${commentIds.length} 条');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/comments/delete/batch',
        body: {'commentIds': commentIds},
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('批量删除评论成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量删除评论失败'),
      );
    } catch (e) {
      Log.e('批量删除评论失败', error: e);
      return Result.failure(Exception('批量删除评论失败: $e'));
    }
  }

  /// 批量点赞评论
  Future<Result<void>> batchLikeComments({
    required String userId,
    required List<String> commentIds,
  }) async {
    try {
      Log.i('批量点赞评论: ${commentIds.length} 条');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/comments/like/batch',
        body: {
          'userId': userId,
          'commentIds': commentIds,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('批量点赞评论成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量点赞评论失败'),
      );
    } catch (e) {
      Log.e('批量点赞评论失败', error: e);
      return Result.failure(Exception('批量点赞评论失败: $e'));
    }
  }
}
