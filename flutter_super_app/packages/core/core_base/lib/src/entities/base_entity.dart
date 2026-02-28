/// 基础实体类
///
/// 所有实体类的基类，提供公共属性和方法
abstract base class BaseEntity {
  /// 实体唯一标识
  final String id;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const BaseEntity({
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// 转换为 JSON
  Map<String, dynamic> toJson();

  /// 创建副本
  BaseEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BaseEntity(id: $id)';
}

/// 带有软删除功能的实体
base class SoftDeletableEntity extends BaseEntity {
  /// 是否已删除
  final bool isDeleted;

  /// 删除时间
  final DateTime? deletedAt;

  const SoftDeletableEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  @override
  BaseEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return SoftDeletableEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() =>
      'SoftDeletableEntity(id: $id, isDeleted: $isDeleted)';
}
