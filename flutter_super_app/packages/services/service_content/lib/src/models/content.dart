library;


/// 内容类型枚举 - 完全可扩展
enum ContentType {
  /// 文章
  article('article'),

  /// 帖子
  post('post'),

  /// 动态
  moment('moment'),

  /// 视频
  video('video'),

  /// 图片
  image('image'),

  /// 音频
  audio('audio'),

  /// 链接
  link('link'),

  /// 自定义内容
  custom('custom');

  const ContentType(this.value);
  final String value;

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ContentType.custom,
    );
  }
}

/// 内容实体 - 高度可扩展
///
/// 设计原则：
/// 1. 核心字段极少且稳定
/// 2. 所有扩展通过 metadata 实现
/// 3. 适用于各种内容类型
final class Content {
  /// 内容ID
  final String id;

  /// 作者ID
  final String authorId;

  /// 作者信息（冗余字段，用于快速显示）
  final String? authorNickname;
  final String? authorAvatar;

  /// 内容类型
  final ContentType type;

  /// 标题
  final String? title;

  /// 正文/摘要
  final String content;

  /// 封面图
  final String? coverImage;

  /// 图片列表
  final List<String>? images;

  /// 视频信息
  final VideoInfo? video;

  /// 链接信息
  final LinkInfo? link;

  /// 话题ID列表
  final List<String> topicIds;

  /// 话题信息（冗余字段）
  final List<TopicInfo>? topics;

  /// 提及的用户ID列表
  final List<String> mentions;

  /// 位置信息
  final LocationInfo? location;

  /// 可见性
  final ContentVisibility visibility;

  /// 状态
  final ContentStatus status;

  /// 自定义元数据 - 完全灵活的扩展点
  ///
  /// 使用场景：
  /// - 文章：`{'wordCount': 1000, 'readTime': 5}`
  /// - 商品推广：`{'productId': 'xxx', 'commission': 0.1}`
  /// - 活动内容：`{'eventId': 'xxx', 'startTime': '...'}`
  /// - 投票：`{'pollId': 'xxx', 'options': [...]}`
  final Map<String, dynamic>? metadata;

  /// 统计数据（冗余，用于快速显示）
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int favoriteCount;

  /// 当前用户的交互状态
  final bool isLiked;
  final bool isFavorited;

  /// 排序分数（用于时间线排序）
  final double? score;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 发布时间
  final DateTime? publishedAt;

  const Content({
    required this.id,
    required this.authorId,
    this.authorNickname,
    this.authorAvatar,
    required this.type,
    this.title,
    required this.content,
    this.coverImage,
    this.images,
    this.video,
    this.link,
    this.topicIds = const [],
    this.topics,
    this.mentions = const [],
    this.location,
    this.visibility = ContentVisibility.public,
    this.status = ContentStatus.draft,
    this.metadata,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.favoriteCount = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.score,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorNickname: json['authorNickname'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
      type: ContentType.fromString(json['type'] as String),
      title: json['title'] as String?,
      content: json['content'] as String,
      coverImage: json['coverImage'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      video: json['video'] != null
          ? VideoInfo.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      link: json['link'] != null
          ? LinkInfo.fromJson(json['link'] as Map<String, dynamic>)
          : null,
      topicIds: (json['topicIds'] as List<dynamic>?)?.cast<String>() ?? [],
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => TopicInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] != null
          ? LocationInfo.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      visibility: json['visibility'] != null
          ? ContentVisibility.values.firstWhere(
              (v) => v.name == json['visibility'],
              orElse: () => ContentVisibility.public,
            )
          : ContentVisibility.public,
      status: json['status'] != null
          ? ContentStatus.values.firstWhere(
              (s) => s.name == json['status'],
              orElse: () => ContentStatus.draft,
            )
          : ContentStatus.draft,
      metadata: json['metadata'] as Map<String, dynamic>?,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isFavorited: json['isFavorited'] as bool? ?? false,
      score: json['score'] as double?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorNickname': authorNickname,
      'authorAvatar': authorAvatar,
      'type': type.value,
      'title': title,
      'content': content,
      'coverImage': coverImage,
      'images': images,
      'video': video?.toJson(),
      'link': link?.toJson(),
      'topicIds': topicIds,
      'topics': topics?.map((e) => e.toJson()).toList(),
      'mentions': mentions,
      'location': location?.toJson(),
      'visibility': visibility.name,
      'status': status.name,
      if (metadata != null) 'metadata': metadata,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'favoriteCount': favoriteCount,
      'isLiked': isLiked,
      'isFavorited': isFavorited,
      'score': score,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
      if (publishedAt != null) 'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  T? getMetadata<T>(String key) {
    final value = metadata?[key];
    if (value == null) return null;
    return value as T;
  }

  bool get hasMedia => images?.isNotEmpty == true || video != null;
  bool get hasTopics => topicIds.isNotEmpty;
  bool get isPublished => status == ContentStatus.published;
  bool get isDraft => status == ContentStatus.draft;

  Content copyWith({
    String? id,
    String? authorId,
    String? authorNickname,
    String? authorAvatar,
    ContentType? type,
    String? title,
    String? content,
    String? coverImage,
    List<String>? images,
    VideoInfo? video,
    LinkInfo? link,
    List<String>? topicIds,
    List<TopicInfo>? topics,
    List<String>? mentions,
    LocationInfo? location,
    ContentVisibility? visibility,
    ContentStatus? status,
    Map<String, dynamic>? metadata,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? favoriteCount,
    bool? isLiked,
    bool? isFavorited,
    double? score,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return Content(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorNickname: authorNickname ?? this.authorNickname,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      video: video ?? this.video,
      link: link ?? this.link,
      topicIds: topicIds ?? this.topicIds,
      topics: topics ?? this.topics,
      mentions: mentions ?? this.mentions,
      location: location ?? this.location,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      score: score ?? this.score,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  String toString() => 'Content(id: $id, type: ${type.value}, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Content && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 视频信息
final class VideoInfo {
  final String url;
  final String? thumbnail;
  final int? duration;
  final int? width;
  final int? height;

  const VideoInfo({
    required this.url,
    this.thumbnail,
    this.duration,
    this.width,
    this.height,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      duration: json['duration'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnail': thumbnail,
      'duration': duration,
      'width': width,
      'height': height,
    };
  }
}

/// 链接信息
final class LinkInfo {
  final String url;
  final String? title;
  final String? description;
  final String? thumbnail;

  const LinkInfo({
    required this.url,
    this.title,
    this.description,
    this.thumbnail,
  });

  factory LinkInfo.fromJson(Map<String, dynamic> json) {
    return LinkInfo(
      url: json['url'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
    };
  }
}

/// 位置信息
final class LocationInfo {
  final String name;
  final double? latitude;
  final double? longitude;
  final String? address;

  const LocationInfo({
    required this.name,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

/// 话题信息
final class TopicInfo {
  final String id;
  final String name;
  final String? icon;
  final String? description;

  const TopicInfo({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });

  factory TopicInfo.fromJson(Map<String, dynamic> json) {
    return TopicInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }
}

/// 内容可见性
enum ContentVisibility {
  /// 公开
  public('public'),

  /// 仅好友
  friends('friends'),

  /// 私密
  private('private'),

  /// 指定用户
  specific('specific');

  const ContentVisibility(this.value);
  final String value;
}

/// 内容状态
enum ContentStatus {
  /// 草稿
  draft('draft'),

  /// 已发布
  published('published'),

  /// 审核中
  reviewing('reviewing'),

  /// 已拒绝
  rejected('rejected'),

  /// 已删除
  deleted('deleted'),

  /// 已隐藏
  hidden('hidden');

  const ContentStatus(this.value);
  final String value;
}

/// 内容查询条件
final class ContentQuery {
  /// 作者ID过滤
  final String? authorId;

  /// 内容类型过滤
  final ContentType? type;

  /// 话题ID过滤
  final String? topicId;

  /// 话题ID列表（或关系）
  final List<String>? topicIds;

  /// 关键字搜索
  final String? keyword;

  /// 排序方式
  final ContentSortType sortType;

  /// 状态过滤
  final ContentStatus? status;

  /// 可见性过滤
  final ContentVisibility? visibility;

  /// 是否包含媒体
  final bool? hasMedia;

  /// 分页参数
  final int page;
  final int pageSize;

  const ContentQuery({
    this.authorId,
    this.type,
    this.topicId,
    this.topicIds,
    this.keyword,
    this.sortType = ContentSortType.latest,
    this.status,
    this.visibility,
    this.hasMedia,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (authorId != null) 'authorId': authorId,
      if (type != null) 'type': type!.value,
      if (topicId != null) 'topicId': topicId,
      if (topicIds != null) 'topicIds': topicIds,
      if (keyword != null) 'keyword': keyword,
      'sortType': sortType.value,
      if (status != null) 'status': status!.value,
      if (visibility != null) 'visibility': visibility!.value,
      if (hasMedia != null) 'hasMedia': hasMedia,
      'page': page,
      'pageSize': pageSize,
    };
  }

  ContentQuery copyWith({
    String? authorId,
    ContentType? type,
    String? topicId,
    List<String>? topicIds,
    String? keyword,
    ContentSortType? sortType,
    ContentStatus? status,
    ContentVisibility? visibility,
    bool? hasMedia,
    int? page,
    int? pageSize,
  }) {
    return ContentQuery(
      authorId: authorId ?? this.authorId,
      type: type ?? this.type,
      topicId: topicId ?? this.topicId,
      topicIds: topicIds ?? this.topicIds,
      keyword: keyword ?? this.keyword,
      sortType: sortType ?? this.sortType,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      hasMedia: hasMedia ?? this.hasMedia,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

/// 内容排序类型
enum ContentSortType {
  /// 最新
  latest('latest'),

  /// 热门（综合分数）
  hot('hot'),

  /// 最多浏览
  mostViewed('most_viewed'),

  /// 最多点赞
  mostLiked('most_liked'),

  /// 最多评论
  mostCommented('most_commented');
  
  const ContentSortType(this.value);
  final String value;
}
