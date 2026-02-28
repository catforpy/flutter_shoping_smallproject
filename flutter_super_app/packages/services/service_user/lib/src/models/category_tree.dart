library;

/// 分类树系统模型
///
/// 支持无限层级的树形分类结构
/// - 话题分类（1-3级或更多）
/// - 行业分类
/// - 商品分类
/// - 完全自定义分类树

// ==================== 分类树 ====================

/// 分类树 - 支持无限层级
final class CategoryTree {
  /// 分类ID
  final String id;

  /// 分类名称
  final String name;

  /// 父分类ID
  final String? parentId;

  /// 层级 (1, 2, 3...)
  final int level;

  /// 完整路径 - 从根到当前节点
  ///
  /// 示例：
  /// ```dart
  /// ["技术", "前端", "Flutter"]
  /// ["教育", "在线教育", "编程"]
  /// ```
  final List<String> path;

  /// 排序顺序
  final int sortOrder;

  /// 自定义配置
  ///
  /// 示例：
  /// ```dart
  /// customConfig: {
  ///   'icon': 'https://...',
  ///   'color': '#00FF00',
  ///   'description': '分类描述',
  ///   'isHot': true,
  ///   'tags': ['热门', '推荐'],
  /// }
  /// ```
  final Map<String, dynamic>? customConfig;

  /// 子分类列表
  final List<CategoryTree> children;

  /// 创建时间
  final DateTime? createdAt;

  const CategoryTree({
    required this.id,
    required this.name,
    this.parentId,
    required this.level,
    required this.path,
    this.sortOrder = 0,
    this.customConfig,
    this.children = const [],
    this.createdAt,
  });

  /// 从 JSON 创建
  factory CategoryTree.fromJson(Map<String, dynamic> json) {
    return CategoryTree(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      level: json['level'] as int,
      path: (json['path'] as List<dynamic>).map((e) => e as String).toList(),
      sortOrder: json['sortOrder'] as int? ?? 0,
      customConfig: json['customConfig'] as Map<String, dynamic>?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => CategoryTree.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'level': level,
      'path': path,
      'sortOrder': sortOrder,
      'customConfig': customConfig,
      'children': children.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 获取自定义配置值
  T? getConfig<T>(String key) {
    final value = customConfig?[key];
    if (value == null) return null;
    return value as T;
  }

  /// 是否有子分类
  bool get hasChildren => children.isNotEmpty;

  /// 是否叶子节点（没有子分类）
  bool get isLeaf => children.isEmpty;

  /// 是否为根分类（没有父级）
  bool get isRoot => parentId == null;

  /// 获取图标
  String? get icon => getConfig<String>('icon');

  /// 获取颜色
  String? get color => getConfig<String>('color');

  /// 获取描述
  String? get description => getConfig<String>('description');

  /// 是否热门
  bool get isHot => getConfig<bool>('isHot') ?? false;

  /// 获取标签
  List<String>? get tags {
    final tagsData = getConfig<List<dynamic>>('tags');
    if (tagsData == null) return null;
    return tagsData.cast<String>();
  }

  /// 查找子分类
  CategoryTree? findChild(String id) {
    for (final child in children) {
      if (child.id == id) return child;
      final found = child.findChild(id);
      if (found != null) return found;
    }
    return null;
  }

  /// 添加子分类
  CategoryTree addChild(CategoryTree child) {
    return copyWith(children: [...children, child]);
  }

  /// 移除子分类
  CategoryTree removeChild(String childId) {
    return copyWith(
      children: children.where((c) => c.id != childId).toList(),
    );
  }

  CategoryTree copyWith({
    String? id,
    String? name,
    String? parentId,
    int? level,
    List<String>? path,
    int? sortOrder,
    Map<String, dynamic>? customConfig,
    List<CategoryTree>? children,
    DateTime? createdAt,
  }) {
    return CategoryTree(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      path: path ?? this.path,
      sortOrder: sortOrder ?? this.sortOrder,
      customConfig: customConfig ?? this.customConfig,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryTree && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CategoryTree(id: $id, name: $name, level: $level)';
}

// ==================== 分类树构建器 ====================

/// 分类树构建器 - 用于从扁平列表构建树形结构
final class CategoryTreeBuilder {
  /// 从扁平列表构建树
  static List<CategoryTree> build(List<CategoryTree> categories) {
    final Map<String, CategoryTree> categoryMap = {};
    final List<CategoryTree> roots = [];

    // 第一遍：创建所有节点的映射
    for (final category in categories) {
      categoryMap[category.id] = category.copyWith(children: []);
    }

    // 第二遍：建立父子关系
    for (final category in categories) {
      final node = categoryMap[category.id]!;
      if (category.parentId == null) {
        roots.add(node);
      } else {
        final parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.children.add(node);
        }
      }
    }

    return roots;
  }

  /// 将树展平为列表（广度优先）
  static List<CategoryTree> flatten(CategoryTree tree) {
    final List<CategoryTree> result = [];
    final queue = <CategoryTree>[tree];

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      result.add(node);
      queue.addAll(node.children);
    }

    return result;
  }

  /// 获取完整路径字符串
  static String getPathString(CategoryTree category, {String separator = ' > '}) {
    return category.path.join(separator);
  }
}

// ==================== 分类查询条件 ====================

/// 分类查询条件
final class CategoryQuery {
  /// 父分类ID（null表示查询根分类）
  final String? parentId;

  /// 分类类型
  final String? type;

  /// 关键字搜索
  final String? keyword;

  /// 层级
  final int? level;

  /// 排序字段
  final String? sortBy;

  /// 排序方向
  final bool ascending;

  /// 分页参数
  final int page;
  final int pageSize;

  const CategoryQuery({
    this.parentId,
    this.type,
    this.keyword,
    this.level,
    this.sortBy = 'sortOrder',
    this.ascending = true,
    this.page = 1,
    this.pageSize = 20,
  });

  /// 转换为查询参数
  Map<String, dynamic> toQueryParams() {
    return {
      if (parentId != null) 'parentId': parentId,
      if (type != null) 'type': type,
      if (keyword != null) 'keyword': keyword,
      if (level != null) 'level': level,
      'sortBy': sortBy,
      'ascending': ascending,
      'page': page,
      'pageSize': pageSize,
    };
  }

  CategoryQuery copyWith({
    String? parentId,
    String? type,
    String? keyword,
    int? level,
    String? sortBy,
    bool? ascending,
    int? page,
    int? pageSize,
  }) {
    return CategoryQuery(
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      keyword: keyword ?? this.keyword,
      level: level ?? this.level,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
