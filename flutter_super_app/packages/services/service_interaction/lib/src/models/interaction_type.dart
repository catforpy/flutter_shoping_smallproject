library;

import 'target_type.dart';

/// 交互类型枚举 - 完全可扩展
///
/// 定义用户与目标的所有交互行为
///
/// 扩展说明：
/// - 预定义类型覆盖常见交互
/// - custom 类型用于自定义交互行为
/// - metadata 提供额外的交互上下文
enum InteractionType {
  /// 点赞
  like('like'),

  /// 收藏
  favorite('favorite'),

  /// 分享
  share('share'),

  /// 踩/不喜欢
  dislike('dislike'),

  /// 关注
  follow('follow'),

  /// 订阅
  subscribe('subscribe'),

  /// 举报
  report('report'),

  /// 自定义交互 - 完全灵活的扩展点
  ///
  /// 使用示例：
  /// ```dart
  /// final customInteraction = InteractionType.custom;
  /// final metadata = {
  ///   'action': 'reward',      // 打赏
  ///   'currency': 'coin',      // 虚拟币
  ///   'amount': 100,
  /// };
  /// ```
  custom('custom');

  const InteractionType(this.value);
  final String value;

  /// 从字符串解析
  static InteractionType fromString(String value) {
    return InteractionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InteractionType.custom,
    );
  }

  /// 是否为预定义类型
  bool get isPredefined => this != InteractionType.custom;
}

/// 交互记录 - 记录用户与目标的交互
///
/// 设计原则：
/// 1. 通用性 - 适用于所有领域的交互
/// 2. 可追溯 - 记录时间、用户、目标
/// 3. 可扩展 - metadata 支持自定义交互属性
final class Interaction {
  /// 交互ID
  final String id;

  /// 用户ID
  final String userId;

  /// 目标引用
  final TargetRef target;

  /// 交互类型
  final InteractionType type;

  /// 创建时间
  final DateTime createdAt;

  /// 自定义元数据 - 扩展点
  ///
  /// 使用场景：
  /// - like: metadata 可为空
  /// - share: metadata 可以记录分享渠道、分享文案等
  /// - custom: metadata 记录自定义交互的详细参数
  ///
  /// 示例：
  /// ```dart
  /// // 分享到微信
  /// metadata: {
  ///   'channel': 'wechat',
  ///   'platform': 'timeline',
  ///   'customMessage': '推荐内容',
  /// }
  ///
  /// // 自定义打赏
  /// metadata: {
  ///   'action': 'reward',
  ///   'currency': 'coin',
  ///   'amount': 100,
  /// }
  /// ```
  final Map<String, dynamic>? metadata;

  const Interaction({
    required this.id,
    required this.userId,
    required this.target,
    required this.type,
    required this.createdAt,
    this.metadata,
  });

  /// 从 JSON 创建
  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      target: TargetRef.fromJson(json['target'] as Map<String, dynamic>),
      type: InteractionType.fromString(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'target': target.toJson(),
      'type': type.value,
      'createdAt': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// 获取元数据值
  T? getMetadata<T>(String key) {
    final value = metadata?[key];
    if (value == null) return null;
    return value as T;
  }

  @override
  String toString() =>
      'Interaction(id: $id, userId: $userId, type: ${type.value})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Interaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 交互统计 - 目标的交互统计数据
///
/// 设计原则：
/// 1. 分离统计 - 每种交互类型独立统计
/// 2. 可扩展 - customStats 支持自定义统计维度
/// 3. 高性能 - 一次性获取所有统计数据
final class InteractionStats {
  /// 目标引用
  final TargetRef target;

  /// 点赞数
  final int likeCount;

  /// 收藏数
  final int favoriteCount;

  /// 分享数
  final int shareCount;

  /// 踩数
  final int dislikeCount;

  /// 关注数
  final int followCount;

  /// 订阅数
  final int subscribeCount;

  /// 举报数
  final int reportCount;

  /// 当前用户的交互状态
  ///
  /// 记录当前用户对该目标的交互状态
  ///
  /// 示例：
  /// ```dart
  /// currentUserInteractions: {
  ///   'like': true,          // 已点赞
  ///   'favorite': false,     // 未收藏
  ///   'follow': true,        // 已关注
  /// }
  /// ```
  final Map<String, bool>? currentUserInteractions;

  /// 自定义统计 - 完全灵活的扩展点
  ///
  /// 用于存储自定义交互类型的统计数据
  ///
  /// 示例：
  /// ```dart
  /// customStats: {
  ///   'reward_count': 150,           // 打赏次数
  ///   'reward_total_amount': 15000,  // 打赏总额
  ///   'view_count': 5000,            // 浏览次数
  ///   'download_count': 200,         // 下载次数
  /// }
  /// ```
  final Map<String, dynamic>? customStats;

  /// 更新时间
  final DateTime? updatedAt;

  const InteractionStats({
    required this.target,
    this.likeCount = 0,
    this.favoriteCount = 0,
    this.shareCount = 0,
    this.dislikeCount = 0,
    this.followCount = 0,
    this.subscribeCount = 0,
    this.reportCount = 0,
    this.currentUserInteractions,
    this.customStats,
    this.updatedAt,
  });

  /// 从 JSON 创建
  factory InteractionStats.fromJson(Map<String, dynamic> json) {
    return InteractionStats(
      target: TargetRef.fromJson(json['target'] as Map<String, dynamic>),
      likeCount: json['likeCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      dislikeCount: json['dislikeCount'] as int? ?? 0,
      followCount: json['followCount'] as int? ?? 0,
      subscribeCount: json['subscribeCount'] as int? ?? 0,
      reportCount: json['reportCount'] as int? ?? 0,
      currentUserInteractions:
          json['currentUserInteractions'] as Map<String, bool>?,
      customStats: json['customStats'] as Map<String, dynamic>?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'target': target.toJson(),
      'likeCount': likeCount,
      'favoriteCount': favoriteCount,
      'shareCount': shareCount,
      'dislikeCount': dislikeCount,
      'followCount': followCount,
      'subscribeCount': subscribeCount,
      'reportCount': reportCount,
      if (currentUserInteractions != null)
        'currentUserInteractions': currentUserInteractions,
      if (customStats != null) 'customStats': customStats,
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 获取自定义统计值
  T? getCustomStat<T>(String key) {
    final value = customStats?[key];
    if (value == null) return null;
    return value as T;
  }

  /// 获取总交互数
  int get totalInteractions =>
      likeCount +
      favoriteCount +
      shareCount +
      dislikeCount +
      followCount +
      subscribeCount;

  /// 当前用户是否点赞
  bool get isLiked => currentUserInteractions?['like'] ?? false;

  /// 当前用户是否收藏
  bool get isFavorited => currentUserInteractions?['favorite'] ?? false;

  /// 当前用户是否关注
  bool get isFollowing => currentUserInteractions?['follow'] ?? false;

  /// 当前用户是否分享过
  bool get isShared => currentUserInteractions?['share'] ?? false;

  InteractionStats copyWith({
    TargetRef? target,
    int? likeCount,
    int? favoriteCount,
    int? shareCount,
    int? dislikeCount,
    int? followCount,
    int? subscribeCount,
    int? reportCount,
    Map<String, bool>? currentUserInteractions,
    Map<String, dynamic>? customStats,
    DateTime? updatedAt,
  }) {
    return InteractionStats(
      target: target ?? this.target,
      likeCount: likeCount ?? this.likeCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      shareCount: shareCount ?? this.shareCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      followCount: followCount ?? this.followCount,
      subscribeCount: subscribeCount ?? this.subscribeCount,
      reportCount: reportCount ?? this.reportCount,
      currentUserInteractions:
          currentUserInteractions ?? this.currentUserInteractions,
      customStats: customStats ?? this.customStats,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'InteractionStats(target: $target, likeCount: $likeCount, favoriteCount: $favoriteCount)';
}
