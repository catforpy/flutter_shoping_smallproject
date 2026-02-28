library;

/// 首页标签数据模型
///
/// 对应后端返回的 JSON 格式：
/// ```json
/// {
///   "id": "0",
///   "title": "推荐"
/// }
/// ```
class HomeTabModel {
  /// 标签ID
  final String id;

  /// 标签标题
  final String title;

  const HomeTabModel({
    required this.id,
    required this.title,
  });

  /// 从 JSON 创建模型
  factory HomeTabModel.fromJson(Map<String, dynamic> json) {
    return HomeTabModel(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  /// 转换为 UI 组件所需的 TabItem
  /// TODO: 后期接入后端时，删除这个转换方法
  toTabItem() {
    // 这里临时依赖 ui_components 的 TabItem
    // 实际应该在使用时转换，或者让 ui_components 使用 HomeTabModel
    return null; // 暂时返回 null，由使用方处理
  }

  /// 复制并修改部分属性
  HomeTabModel copyWith({
    String? id,
    String? title,
  }) {
    return HomeTabModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  @override
  String toString() => 'HomeTabModel(id: $id, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeTabModel &&
        other.id == id &&
        other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
