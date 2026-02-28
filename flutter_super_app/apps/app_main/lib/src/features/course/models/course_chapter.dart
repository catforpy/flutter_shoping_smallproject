import 'course_lesson.dart';

/// 章节数据模型
class CourseChapter {
  /// 章节ID
  final String id;

  /// 章节标题
  final String title;

  /// 章节总时长
  final String duration;

  /// 课时列表
  final List<CourseLesson> lessons;

  const CourseChapter({
    required this.id,
    required this.title,
    required this.duration,
    required this.lessons,
  });

  /// 复制并修改部分属性
  CourseChapter copyWith({
    String? id,
    String? title,
    String? duration,
    List<CourseLesson>? lessons,
  }) {
    return CourseChapter(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      lessons: lessons ?? this.lessons,
    );
  }
}
