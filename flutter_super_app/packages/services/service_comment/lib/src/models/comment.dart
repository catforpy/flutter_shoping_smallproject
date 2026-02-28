library;

import 'package:service_interaction/service_interaction.dart';

/// 评论实体 - 完全可扩展
///
/// 设计原则：
/// 1. 通用性 - 适用于内容、话题、商品等所有领域
/// 2. 层级性 - 支持多级回复
/// 3. 可扩展 - metadata 支持自定义评论属性
final class Comment {
  /// 评论ID
  final String id;

  /// 目标引用 - 评论所属的目标
  final TargetRef target;

  /// 用户ID
  final String userId;

  /// 用户昵称（冗余字段，用于快速显示）
  final String? userNickname;

  /// 用户头像（冗余字段，用于快速显示）
  final String? userAvatar;

  /// 评论内容
  final String content;

  /// 父评论ID - null 表示根评论，有值表示回复
  final String? parentId;

  /// 回复给的用户ID - 用于 @提醒
  final String? replyToUserId;

  /// 回复给的用户昵称
  final String? replyToUserNickname;

  /// 层级深度 - 0=根评论, 1=一级回复, 2=二级回复...
  final int depth;

  /// 点赞数
  final int likeCount;

  /// 回复数
  final int replyCount;

  /// 当前用户是否点赞
  final bool isLiked;

  /// 状态
  final CommentStatus status;

  /// 是否置顶
  final bool isPinned;

  /// 自定义元数据 - 完全灵活的扩展点
  ///
  /// 使用场景：
  /// - 图片评论：`{'images': ['url1', 'url2']}`
  /// - 语音评论：`{'audio': {'url': '...', 'duration': 30}}`
  /// - 表情评论：`{'emoji': '👍'}`
  /// - 评分评论：`{'rating': 5}`
  /// - 附加数据：`{'productId': 'xxx', 'order': true}`
  final Map<String, dynamic>? metadata;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const Comment({
    required this.id,
    required this.target,
    required this.userId,
    this.userNickname,
    this.userAvatar,
    required this.content,
    this.parentId,
    this.replyToUserId,
    this.replyToUserNickname,
    this.depth = 0,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLiked = false,
    this.status = CommentStatus.normal,
    this.isPinned = false,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从 JSON 创建
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      target: TargetRef.fromJson(json['target'] as Map<String, dynamic>),
      userId: json['userId'] as String,
      userNickname: json['userNickname'] as String?,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      parentId: json['parentId'] as String?,
      replyToUserId: json['replyToUserId'] as String?,
      replyToUserNickname: json['replyToUserNickname'] as String?,
      depth: json['depth'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      replyCount: json['replyCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      status: json['status'] != null
          ? CommentStatus.values.firstWhere(
              (s) => s.name == json['status'],
              orElse: () => CommentStatus.normal,
            )
          : CommentStatus.normal,
      isPinned: json['isPinned'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target': target.toJson(),
      'userId': userId,
      'userNickname': userNickname,
      'userAvatar': userAvatar,
      'content': content,
      'parentId': parentId,
      'replyToUserId': replyToUserId,
      'replyToUserNickname': replyToUserNickname,
      'depth': depth,
      'likeCount': likeCount,
      'replyCount': replyCount,
      'isLiked': isLiked,
      'status': status.name,
      'isPinned': isPinned,
      if (metadata != null) 'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 获取元数据值
  T? getMetadata<T>(String key) {
    final value = metadata?[key];
    if (value == null) return null;
    return value as T;
  }

  /// 是否为根评论
  bool get isRoot => parentId == null;

  /// 是否为回复
  bool get isReply => parentId != null;

  /// 是否包含图片
  bool get hasImages {
    final images = getMetadata<List<dynamic>>('images');
    return images != null && images.isNotEmpty;
  }

  /// 是否包含音频
  bool get hasAudio => getMetadata<String>('audio') != null;

  /// 是否包含评分
  int? get rating => getMetadata<int>('rating');

  /// 获取图片列表
  List<String>? get images {
    final imagesData = getMetadata<List<dynamic>>('images');
    if (imagesData == null) return null;
    return imagesData.cast<String>();
  }

  Comment copyWith({
    String? id,
    TargetRef? target,
    String? userId,
    String? userNickname,
    String? userAvatar,
    String? content,
    String? parentId,
    String? replyToUserId,
    String? replyToUserNickname,
    int? depth,
    int? likeCount,
    int? replyCount,
    bool? isLiked,
    CommentStatus? status,
    bool? isPinned,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      target: target ?? this.target,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToUserNickname: replyToUserNickname ?? this.replyToUserNickname,
      depth: depth ?? this.depth,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isLiked: isLiked ?? this.isLiked,
      status: status ?? this.status,
      isPinned: isPinned ?? this.isPinned,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Comment(id: $id, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 评论状态
enum CommentStatus {
  /// 正常
  normal('normal'),

  /// 待审核
  pending('pending'),

  /// 已拒绝
  rejected('rejected'),

  /// 已删除
  deleted('deleted'),

  /// 已隐藏
  hidden('hidden');

  const CommentStatus(this.value);
  final String value;
}

/// 评论树 - 用于构建层级评论结构
final class CommentTree {
  /// 根评论
  final Comment root;

  /// 直接回复列表（一级回复）
  final List<Comment> replies;

  /// 是否展开显示
  final bool isExpanded;

  /// 是否加载了所有回复
  final bool hasLoadedAll;

  const CommentTree({
    required this.root,
    this.replies = const [],
    this.isExpanded = false,
    this.hasLoadedAll = false,
  });

  /// 总回复数（包括子回复）
  int get totalReplies => root.replyCount;

  CommentTree copyWith({
    Comment? root,
    List<Comment>? replies,
    bool? isExpanded,
    bool? hasLoadedAll,
  }) {
    return CommentTree(
      root: root ?? this.root,
      replies: replies ?? this.replies,
      isExpanded: isExpanded ?? this.isExpanded,
      hasLoadedAll: hasLoadedAll ?? this.hasLoadedAll,
    );
  }
}

/// 评论查询条件
final class CommentQuery {
  /// 目标引用 - 必填
  final TargetRef target;

  /// 排序方式
  final CommentSortType sortType;

  /// 是否只看作者
  final String? authorUserId;

  /// 状态过滤
  final CommentStatus? status;

  /// 分页参数
  final int page;
  final int pageSize;

  const CommentQuery({
    required this.target,
    this.sortType = CommentSortType.hot,
    this.authorUserId,
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });

  /// 转换为查询参数
  Map<String, dynamic> toQueryParams() {
    return {
      'targetType': target.type.value,
      'targetId': target.id,
      'sortType': sortType.value,
      if (authorUserId != null) 'authorUserId': authorUserId,
      if (status != null) 'status': status!.value,
      'page': page,
      'pageSize': pageSize,
    };
  }

  CommentQuery copyWith({
    TargetRef? target,
    CommentSortType? sortType,
    String? authorUserId,
    CommentStatus? status,
    int? page,
    int? pageSize,
  }) {
    return CommentQuery(
      target: target ?? this.target,
      sortType: sortType ?? this.sortType,
      authorUserId: authorUserId ?? this.authorUserId,
      status: status ?? this.status,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

/// 评论排序类型
enum CommentSortType {
  /// 热门 - 按点赞数+回复数排序
  hot('hot'),

  /// 最新 - 按时间倒序
  latest('latest'),

  /// 最早 - 按时间正序
  earliest('earliest');

  const CommentSortType(this.value);
  final String value;
}
