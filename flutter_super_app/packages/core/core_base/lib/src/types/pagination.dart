/// 分页信息
///
/// 用于分页查询
final class Pagination {
  /// 当前页码（从1开始）
  final int page;

  /// 每页数量
  final int pageSize;

  /// 总数量
  final int total;

  const Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// 总页数
  int get totalPages {
    if (pageSize <= 0) return 0;
    return (total / pageSize).ceil();
  }

  /// 是否有下一页
  bool get hasNext => page * pageSize < total;

  /// 是否有上一页
  bool get hasPrevious => page > 1;

  /// 创建第一页
  factory Pagination.first({
    required int pageSize,
    required int total,
  }) {
    return Pagination(
      page: 1,
      pageSize: pageSize,
      total: total,
    );
  }

  /// 创建下一页
  Pagination? next() {
    if (!hasNext) return null;
    return Pagination(
      page: page + 1,
      pageSize: pageSize,
      total: total,
    );
  }

  /// 创建上一页
  Pagination? previous() {
    if (!hasPrevious) return null;
    return Pagination(
      page: page - 1,
      pageSize: pageSize,
      total: total,
    );
  }

  /// 更新总数量
  Pagination withTotal(int newTotal) {
    return Pagination(
      page: page,
      pageSize: pageSize,
      total: newTotal,
    );
  }

  /// 跳转到指定页
  Pagination goToPage(int targetPage) {
    if (targetPage < 1 || targetPage > totalPages) {
      throw ArgumentError('页码超出范围: $targetPage');
    }
    return Pagination(
      page: targetPage,
      pageSize: pageSize,
      total: total,
    );
  }

  /// 偏移量（用于数据库查询）
  int get offset => (page - 1) * pageSize;

  /// 限制数量（用于数据库查询）
  int get limit => pageSize;

  /// 是否为第一页
  bool get isFirst => page == 1;

  /// 是否为最后一页
  bool get isLast => page == totalPages;

  /// 分页信息（JSON 友好）
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'pageSize': pageSize,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
    };
  }

  /// 从 JSON 创建
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      pageSize: json['pageSize'] as int,
      total: json['total'] as int,
    );
  }

  @override
  String toString() {
    return 'Pagination(page: $page, pageSize: $pageSize, total: $total, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pagination &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.total == total;
  }

  @override
  int get hashCode => Object.hash(page, pageSize, total);
}

/// 分页请求参数
final class PaginationRequest {
  /// 页码（从1开始）
  final int page;

  /// 每页数量
  final int pageSize;

  const PaginationRequest({
    this.page = 1,
    this.pageSize = 20,
  })  : assert(page >= 1, '页码必须 >= 1'),
        assert(pageSize > 0, '每页数量必须 > 0'),
        assert(pageSize <= 100, '每页数量不能超过 100');

  /// 默认请求（第一页，每页20条）
  static const defaultRequest = PaginationRequest();

  /// 第一页
  PaginationRequest first() {
    return const PaginationRequest(page: 1);
  }

  /// 下一页
  PaginationRequest next() {
    return PaginationRequest(page: page + 1, pageSize: pageSize);
  }

  /// 上一页
  PaginationRequest? previous() {
    if (page <= 1) return null;
    return PaginationRequest(page: page - 1, pageSize: pageSize);
  }

  /// 转换为分页信息
  Pagination toPagination(int total) {
    return Pagination(
      page: page,
      pageSize: pageSize,
      total: total,
    );
  }

  @override
  String toString() => 'PaginationRequest(page: $page, pageSize: $pageSize)';
}
