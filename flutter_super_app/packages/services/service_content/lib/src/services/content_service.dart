library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import 'package:service_interaction/service_interaction.dart';
import 'package:service_comment/service_comment.dart';
import '../models/content.dart';
import '../repositories/content_repository.dart';

/// 内容服务 - 高度可扩展的内容管理系统
///
/// 核心功能：
/// 1. 发布内容 - 文章、帖子、动态、视频等
/// 2. 内容管理 - 编辑、删除、发布
/// 3. 内容查询 - 按作者、话题、关键字等查询
/// 4. 交互集成 - 点赞、收藏、评论
///
/// 扩展性：
/// - 通过 Content.metadata 存储自定义数据
/// - 通过 ContentType.custom 实现自定义内容类型
/// - 适用于各种内容场景
final class ContentService {
  final ContentRepository _repository;
  final ApiClient _apiClient;
  final InteractionService? _interactionService;
  final CommentService? _commentService;

  ContentService({
    required ContentRepository repository,
    required ApiClient apiClient,
    InteractionService? interactionService,
    CommentService? commentService,
  })  : _repository = repository,
        _apiClient = apiClient,
        _interactionService = interactionService,
        _commentService = commentService;

  // ==================== 发布内容 ====================

  /// 创建内容
  ///
  /// 使用示例：
  /// ```dart
  /// // 普通文章
  /// await service.createContent(
  ///   authorId: 'user123',
  ///   type: ContentType.article,
  ///   title: '标题',
  ///   content: '正文内容',
  /// );
  ///
  /// // 图片动态
  /// await service.createContent(
  ///   authorId: 'user123',
  ///   type: ContentType.moment,
  ///   content: '分享图片',
  ///   images: ['url1', 'url2'],
  ///   topicIds: ['topic1'],
  /// );
  ///
  /// // 视频内容
  /// await service.createContent(
  ///   authorId: 'user123',
  ///   type: ContentType.video,
  ///   title: '视频标题',
  ///   content: '视频描述',
  ///   video: VideoInfo(url: '...', duration: 120),
  /// );
  /// ```
  Future<Result<Content>> createContent({
    required String authorId,
    required ContentType type,
    String? title,
    required String content,
    String? coverImage,
    List<String>? images,
    VideoInfo? video,
    LinkInfo? link,
    List<String> topicIds = const [],
    List<String> mentions = const [],
    LocationInfo? location,
    ContentVisibility visibility = ContentVisibility.public,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Log.i('创建内容: ${type.value}');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/contents',
        body: {
          'authorId': authorId,
          'type': type.value,
          if (title != null) 'title': title,
          'content': content,
          if (coverImage != null) 'coverImage': coverImage,
          if (images != null) 'images': images,
          if (video != null) 'video': video.toJson(),
          if (link != null) 'link': link.toJson(),
          if (topicIds.isNotEmpty) 'topicIds': topicIds,
          if (mentions.isNotEmpty) 'mentions': mentions,
          if (location != null) 'location': location.toJson(),
          'visibility': visibility.value,
          'status': ContentStatus.draft.value,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final contentData = response.data!['data'] as Map<String, dynamic>;
        final newContent = Content.fromJson(contentData);

        Log.i('创建内容成功: ${newContent.id}');
        return Result.success(newContent);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '创建内容失败'),
      );
    } catch (e) {
      Log.e('创建内容失败', error: e);
      return Result.failure(Exception('创建内容失败: $e'));
    }
  }

  /// 更新内容
  Future<Result<Content>> updateContent({
    required String contentId,
    String? title,
    String? content,
    String? coverImage,
    List<String>? images,
    VideoInfo? video,
    LinkInfo? link,
    List<String>? topicIds,
    List<String>? mentions,
    LocationInfo? location,
    ContentVisibility? visibility,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      Log.i('更新内容: $contentId');

      final response = await _apiClient.put<Map<String, dynamic>>(
        '/contents/$contentId',
        body: {
          if (title != null) 'title': title,
          if (content != null) 'content': content,
          if (coverImage != null) 'coverImage': coverImage,
          if (images != null) 'images': images,
          if (video != null) 'video': video.toJson(),
          if (link != null) 'link': link.toJson(),
          if (topicIds != null) 'topicIds': topicIds,
          if (mentions != null) 'mentions': mentions,
          if (location != null) 'location': location.toJson(),
          if (visibility != null) 'visibility': visibility.value,
          if (metadata != null) 'metadata': metadata,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final contentData = response.data!['data'] as Map<String, dynamic>;
        final updatedContent = Content.fromJson(contentData);

        Log.i('更新内容成功');
        return Result.success(updatedContent);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '更新内容失败'),
      );
    } catch (e) {
      Log.e('更新内容失败', error: e);
      return Result.failure(Exception('更新内容失败: $e'));
    }
  }

  /// 删除内容
  Future<Result<void>> deleteContent(String contentId) async {
    try {
      Log.i('删除内容: $contentId');

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/contents/$contentId',
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('删除内容成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '删除内容失败'),
      );
    } catch (e) {
      Log.e('删除内容失败', error: e);
      return Result.failure(Exception('删除内容失败: $e'));
    }
  }

  /// 发布内容（草稿->已发布）
  Future<Result<Content>> publishContent(String contentId) async {
    return await _repository.publishContent(contentId);
  }

  // ==================== 查询内容 ====================

  /// 获取内容详情
  Future<Result<Content>> getContent(String contentId) async {
    return await _repository.getContent(contentId);
  }

  /// 获取内容列表
  ///
  /// 使用示例：
  /// ```dart
  /// // 获取最新内容
  /// final result = await service.getContents(
  ///   ContentQuery(sortType: ContentSortType.latest),
  /// );
  ///
  /// // 获取热门内容
  /// final result = await service.getContents(
  ///   ContentQuery(sortType: ContentSortType.hot),
  /// );
  ///
  /// // 获取指定作者的内容
  /// final result = await service.getContents(
  ///   ContentQuery(authorId: 'user123'),
  /// );
  ///
  /// // 获取指定话题的内容
  /// final result = await service.getContents(
  ///   ContentQuery(topicId: 'topic123'),
  /// );
  ///
  /// // 搜索内容
  /// final result = await service.getContents(
  ///   ContentQuery(keyword: 'Flutter'),
  /// );
  /// ```
  Future<Result<PagedResult<Content>>> getContents(ContentQuery query) async {
    try {
      Log.i('获取内容列表');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/contents',
        queryParameters: query.toQueryParams(),
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final contentsData = data['items'] as List;
        final contents = contentsData
            .map((json) => Content.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取内容列表成功: ${contents.length} 条');
        return Result.success(
          PagedResult(
            data: contents,
            pagination: Pagination(
              page: query.page,
              pageSize: query.pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取内容列表失败'),
      );
    } catch (e) {
      Log.e('获取内容列表失败', error: e);
      return Result.failure(Exception('获取内容列表失败: $e'));
    }
  }

  /// 增加浏览量
  Future<Result<void>> incrementViewCount(String contentId) async {
    return await _repository.incrementViewCount(contentId);
  }

  // ==================== 交互功能（可选） ====================

  /// 点赞内容（依赖 InteractionService）
  Future<Result<void>> likeContent({
    required String userId,
    required String contentId,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.like(
      userId: userId,
      target: TargetRef.content(contentId),
    );
  }

  /// 取消点赞
  Future<Result<void>> unlikeContent({
    required String userId,
    required String contentId,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.unlike(
      userId: userId,
      target: TargetRef.content(contentId),
    );
  }

  /// 收藏内容
  Future<Result<void>> favoriteContent({
    required String userId,
    required String contentId,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.favorite(
      userId: userId,
      target: TargetRef.content(contentId),
    );
  }

  /// 分享内容
  Future<Result<void>> shareContent({
    required String userId,
    required String contentId,
    required String channel,
    String? platform,
    String? customMessage,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.share(
      userId: userId,
      target: TargetRef.content(contentId),
      channel: channel,
      platform: platform,
      customMessage: customMessage,
    );
  }

  /// 获取内容的评论
  Future<Result<PagedResult<Comment>>> getContentComments({
    required String contentId,
    CommentSortType sortType = CommentSortType.hot,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (_commentService == null) {
      return Result.failure(Exception('CommentService 未初始化'));
    }
    return await _commentService!.getComments(
      CommentQuery(
        target: TargetRef.content(contentId),
        sortType: sortType,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// 对内容发表评论
  Future<Result<Comment>> createComment({
    required String userId,
    required String contentId,
    required String commentContent,
    String? parentId,
    String? replyToUserId,
  }) async {
    if (_commentService == null) {
      return Result.failure(Exception('CommentService 未初始化'));
    }
    return await _commentService!.createComment(
      userId: userId,
      target: TargetRef.content(contentId),
      content: commentContent,
      parentId: parentId,
      replyToUserId: replyToUserId,
    );
  }
}
