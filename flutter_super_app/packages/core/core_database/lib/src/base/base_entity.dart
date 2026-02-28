/// 数据库实体基类
abstract base class DatabaseEntity {
  /// 表名
  String get tableName;

  /// 主键ID（可为空，新建时为空）
  final String? id;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  const DatabaseEntity({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// 转换为 Map（用于数据库存储）
  Map<String, dynamic> toMap();

  /// 获取创建表的 SQL 语句
  String get createTableSql;

  /// 获取字段列表
  List<String> get columns;
}
