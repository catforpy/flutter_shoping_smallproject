library;

import 'package:core_base/core_base.dart';
import 'package:service_interaction/service_interaction.dart';
import '../models/comment.dart';

/// 评论仓库接口
///
/// 定义评论数据访问的抽象层
/// 支持评论、回复、点赞等操作
abstract class CommentRepository {
  /// 创建评论
  Future<Result<Comment>> createComment({
    required String userId,
    required TargetRef target,
    required String content,
    String? parentId,
    String? replyToUserId,
    Map<String, dynamic>? metadata,
  });

  /// 回复评论
  Future<Result<Comment>> replyComment({
    required String userId,
    required String commentId,
    required String content,
    String? replyToUserId,
    Map<String, dynamic>? metadata,
  });

  /// 删除评论
  Future<Result<void>> deleteComment(String commentId);

  /// 更新评论内容
  Future<Result<Comment>> updateComment({
    required String commentId,
    required String content,
    Map<String, dynamic>? metadata,
  });

  /// 获取评论详情
  Future<Result<Comment>> getComment(String commentId);

  /// 获取目标的评论列表（根评论）
  Future<Result<PagedResult<Comment>>> getComments(CommentQuery query);

  /// 获取评论的回复列表
  Future<Result<PagedResult<Comment>>> getReplies({
    required String commentId,
    int page = 1,
    int pageSize = 20,
  });

  /// 点赞评论
  Future<Result<void>> likeComment({
    required String userId,
    required String commentId,
  });

  /// 取消点赞评论
  Future<Result<void>> unlikeComment({
    required String userId,
    required String commentId,
  });

  /// 获取用户的评论列表
  Future<Result<PagedResult<Comment>>> getUserComments({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });

  /// 获取用户收到的回复（通知用）
  Future<Result<PagedResult<Comment>>> getUserReplies({
    required String userId,
    int page = 1,
    int pageSize = 20,
  });

  /// 清除缓存
  Future<void> clearCache();
}
