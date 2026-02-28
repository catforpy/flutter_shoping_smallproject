library;

/// 关系/分组系统模型
///
/// 支持高度可扩展的用户关系管理和分组系统
/// - 用户关系（好友、关注、黑名单等）
/// - 分组/分类（好友分组、群组分类等）
/// - 支持树形结构的多级分类

// ==================== 关系类型 ====================

/// 关系类型 - 可扩展
enum RelationType {
  /// 好友
  friend('friend'),

  /// 关注
  following('following'),

  /// 粉丝
  follower('follower'),

  /// 黑名单
  blocked('blocked'),

  /// 免打扰
  muted('muted'),

  /// 特别关注
  favorite('favorite'),

  /// 自定义类型
  custom('custom');

  const RelationType(this.value);
  final String value;

  /// 从字符串创建
  static RelationType fromString(String value) {
    return RelationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RelationType.custom,
    );
  }
}

// ==================== 用户关系 ====================

/// 用户关系 - 统一管理所有关系类型
final class UserRelation {
  /// 用户ID
  final String userId;

  /// 目标用户ID
  final String targetUserId;

  /// 关系类型
  final RelationType type;

  /// 分组列表 - 一个关系可以属于多个分组
  ///
  /// 示例：
  /// - ["同事", "技术部"]
  /// - ["家人", "亲属"]
  /// - ["客户", "VIP客户"]
  final List<String> categories;

  /// 扩展信息
  ///
  /// 示例：
  /// ```dart
  /// metadata: {
  ///   'remark': '备注名称',
  ///   'tags': ['重要', '优先'],
  ///   'lastContactTime': '2026-02-25',
  /// }
  /// ```
  final Map<String, dynamic>? metadata;

  /// 创建时间
  final DateTime createdAt;

  const UserRelation({
    required this.userId,
    required this.targetUserId,
    required this.type,
    this.categories = const [],
    this.metadata,
    required this.createdAt,
  });

  /// 从 JSON 创建
  factory UserRelation.fromJson(Map<String, dynamic> json) {
    return UserRelation(
      userId: json['userId'] as String,
      targetUserId: json['targetUserId'] as String,
      type: RelationType.fromString(json['type'] as String),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetUserId': targetUserId,
      'type': type.value,
      'categories': categories,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取备注名称
  String? get remark => metadata?['remark'] as String?;

  /// 获取标签列表
  List<String>? get tags {
    final tagsData = metadata?['tags'];
    if (tagsData == null) return null;
    return List<String>.from(tagsData as List);
  }

  /// 是否在特定分组中
  bool isInCategory(String categoryId) {
    return categories.contains(categoryId);
  }

  UserRelation copyWith({
    String? userId,
    String? targetUserId,
    RelationType? type,
    List<String>? categories,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return UserRelation(
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserRelation &&
        other.userId == userId &&
        other.targetUserId == targetUserId &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(userId, targetUserId, type);
}

// ==================== 分类类型 ====================

/// 分类类型 - 可扩展
enum CategoryType {
  /// 好友分组
  friendGroup('friend_group'),

  /// 群组分类
  chatGroup('chat_group'),

  /// 话题分类
  topicCategory('topic_category'),

  /// 行业分类
  industry('industry'),

  /// 自定义类型
  custom('custom');

  const CategoryType(this.value);
  final String value;

  /// 从字符串创建
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CategoryType.custom,
    );
  }
}

// ==================== 关系分组/分类 ====================

/// 分组/分类 - 支持多级树形结构
final class RelationCategory {
  /// 分类ID
  final String id;

  /// 分类名称 - 可自定义
  final String name;

  /// 父分类ID - 支持多级
  final String? parentId;

  /// 分类类型
  final CategoryType type;

  /// 排序顺序
  final int sortOrder;

  /// 图标
  final String? icon;

  /// 自定义配置
  ///
  /// 示例：
  /// ```dart
  /// customConfig: {
  ///   'color': '#FF0000',
  ///   'isDefault': false,
  ///   'maxMembers': 500,
  /// }
  /// ```
  final Map<String, dynamic>? customConfig;

  /// 创建时间
  final DateTime createdAt;

  const RelationCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.type,
    this.sortOrder = 0,
    this.icon,
    this.customConfig,
    required this.createdAt,
  });

  /// 从 JSON 创建
  factory RelationCategory.fromJson(Map<String, dynamic> json) {
    return RelationCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      type: CategoryType.fromString(json['type'] as String),
      sortOrder: json['sortOrder'] as int? ?? 0,
      icon: json['icon'] as String?,
      customConfig: json['customConfig'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'type': type.value,
      'sortOrder': sortOrder,
      'icon': icon,
      'customConfig': customConfig,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取自定义配置值
  T? getConfig<T>(String key) {
    final value = customConfig?[key];
    if (value == null) return null;
    return value as T;
  }

  /// 是否为根分类（没有父级）
  bool get isRoot => parentId == null;

  /// 获取颜色
  String? get color => getConfig<String>('color');

  /// 是否为默认分类
  bool get isDefault => getConfig<bool>('isDefault') ?? false;

  RelationCategory copyWith({
    String? id,
    String? name,
    String? parentId,
    CategoryType? type,
    int? sortOrder,
    String? icon,
    Map<String, dynamic>? customConfig,
    DateTime? createdAt,
  }) {
    return RelationCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      icon: icon ?? this.icon,
      customConfig: customConfig ?? this.customConfig,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelationCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ==================== 批量操作结果 ====================

/// 批量关注/取关结果
final class BatchRelationResult {
  /// 成功数量
  final int successCount;

  /// 失败数量
  final int failureCount;

  /// 失败的用户ID列表
  final List<String> failedUserIds;

  /// 错误信息
  final List<String> errors;

  const BatchRelationResult({
    required this.successCount,
    required this.failureCount,
    this.failedUserIds = const [],
    this.errors = const [],
  });

  /// 是否全部成功
  bool get isAllSuccess => failureCount == 0;

  /// 总数量
  int get totalCount => successCount + failureCount;
}
