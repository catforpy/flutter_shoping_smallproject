/// 课时数据模型
class CourseLesson {
  /// 课时ID
  final String id;

  /// 课时标题
  final String title;

  /// 课时时长
  final String duration;

  /// 是否为最近学习
  final bool isRecent;

  const CourseLesson({
    required this.id,
    required this.title,
    required this.duration,
    this.isRecent = false,
  });

  /// 复制并修改部分属性
  CourseLesson copyWith({
    String? id,
    String? title,
    String? duration,
    bool? isRecent,
  }) {
    return CourseLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      isRecent: isRecent ?? this.isRecent,
    );
  }
}
