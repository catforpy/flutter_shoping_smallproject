library;

/// 目标类型枚举 - 完全可扩展
///
/// 用于标识交互目标所属的领域
///
/// 扩展说明：
/// - 预定义类型覆盖常见场景
/// - custom 类型用于自定义扩展
/// - metadata 中存储自定义类型的详细信息
enum TargetType {
  /// 内容
  content('content'),

  /// 话题
  topic('topic'),

  /// 商品
  product('product'),

  /// 评论
  comment('comment'),

  /// 用户
  user('user'),

  /// 消息
  message('message'),

  /// 自定义 - 完全灵活的扩展点
  ///
  /// 使用示例：
  /// ```dart
  /// final customType = TargetType.custom;
  /// final metadata = {'domain': 'course', 'subType': 'lesson'};
  /// ```
  custom('custom');

  const TargetType(this.value);
  final String value;

  /// 从字符串解析
  static TargetType fromString(String value) {
    return TargetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TargetType.custom,
    );
  }

  /// 是否为预定义类型
  bool get isPredefined => this != TargetType.custom;
}

/// 目标引用 - 标识交互目标的类型和ID
///
/// 设计原则：
/// 1. 完全解耦 - 不依赖具体的业务模型
/// 2. 类型安全 - 使用枚举而非字符串
/// 3. 可扩展 - custom 类型 + metadata 支持任意扩展
final class TargetRef {
  /// 目标类型
  final TargetType type;

  /// 目标ID
  final String id;

  /// 自定义元数据 - 仅在 type == custom 时使用
  ///
  /// 示例：
  /// ```dart
  /// metadata: {
  ///   'domain': 'course',      // 领域
  ///   'subType': 'lesson',     // 子类型
  ///   'version': '2.0',        // 版本
  ///   'anyCustomField': 'any value',
  /// }
  /// ```
  final Map<String, dynamic>? metadata;

  const TargetRef({
    required this.type,
    required this.id,
    this.metadata,
  });

  /// 创建内容引用
  const TargetRef.content(String id) : this(type: TargetType.content, id: id);

  /// 创建话题引用
  const TargetRef.topic(String id) : this(type: TargetType.topic, id: id);

  /// 创建商品引用
  const TargetRef.product(String id) : this(type: TargetType.product, id: id);

  /// 创建评论引用
  const TargetRef.comment(String id) : this(type: TargetType.comment, id: id);

  /// 创建用户引用
  const TargetRef.user(String id) : this(type: TargetType.user, id: id);

  /// 创建自定义引用
  const TargetRef.custom({
    required String id,
    required Map<String, dynamic> metadata,
  }) : this(type: TargetType.custom, id: id, metadata: metadata);

  /// 从 JSON 创建
  factory TargetRef.fromJson(Map<String, dynamic> json) {
    final type = TargetType.fromString(json['type'] as String);
    return TargetRef(
      type: type,
      id: json['id'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'id': id,
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
  String toString() => 'TargetRef(type: ${type.value}, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TargetRef &&
        other.type == type &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}
