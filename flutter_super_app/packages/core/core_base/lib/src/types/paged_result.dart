import 'pagination.dart' show Pagination;

/// 分页结果
///
/// 包含数据列表和分页信息
final class PagedResult<T> {
  /// 数据列表
  final List<T> data;

  /// 分页信息
  final Pagination pagination;

  const PagedResult({
    required this.data,
    required this.pagination,
  });

  /// 是否为空
  bool get isEmpty => data.isEmpty;

  /// 是否不为空
  bool get isNotEmpty => data.isNotEmpty;

  /// 数据数量
  int get length => data.length;

  /// 创建空的分页结果
  factory PagedResult.empty({
    required int pageSize,
  }) {
    return PagedResult(
      data: const [],
      pagination: Pagination(
        page: 1,
        pageSize: pageSize,
        total: 0,
      ),
    );
  }

  /// 映射数据类型
  PagedResult<R> map<R>(R Function(T item) mapper) {
    return PagedResult<R>(
      data: data.map(mapper).toList(),
      pagination: pagination,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'pagination': pagination.toJson(),
    };
  }

  @override
  String toString() {
    return 'PagedResult(count: ${data.length}, total: ${pagination.total}, page: ${pagination.page})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PagedResult<T> &&
        other.data == data &&
        other.pagination == pagination;
  }

  @override
  int get hashCode => Object.hash(data, pagination);
}
