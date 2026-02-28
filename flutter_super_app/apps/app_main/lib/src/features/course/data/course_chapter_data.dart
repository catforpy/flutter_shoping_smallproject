import '../models/course_chapter.dart';
import '../models/course_lesson.dart';

/// 课程章节数据（用于开发测试）
final List<CourseChapter> courseChapterData = const [
  CourseChapter(
    id: '1',
    title: '第1章 初见TypeScript',
    duration: '30:28',
    lessons: [
      CourseLesson(
        id: '1-1',
        title: '1-1 学前准备',
        duration: '06:18',
        isRecent: true,
      ),
      CourseLesson(
        id: '1-2',
        title: '1-2 为什么要学习TypeScript',
        duration: '14:06',
      ),
      CourseLesson(
        id: '1-3',
        title: '1-3 什么是类型',
        duration: '10:04',
      ),
    ],
  ),
  CourseChapter(
    id: '2',
    title: '第2章 TypeScript 基础篇',
    duration: '50:43',
    lessons: [
      CourseLesson(
        id: '2-1',
        title: '2-1 构建TypeScript的开发环境',
        duration: '11:49',
      ),
      CourseLesson(
        id: '2-2',
        title: '2-2 Typescript的基础类型',
        duration: '13:16',
      ),
      CourseLesson(
        id: '2-3',
        title: '2-3 枚举类型与表驱动法',
        duration: '11:24',
      ),
      CourseLesson(
        id: '2-4',
        title: '2-4 interface 接口与type类型别名',
        duration: '14:14',
      ),
    ],
  ),
  CourseChapter(
    id: '3',
    title: '第3章 TypeScript高级篇',
    duration: '1:04:24',
    lessons: [
      CourseLesson(
        id: '3-1',
        title: '3-1 交叉类型与联合类型',
        duration: '10:56',
      ),
      CourseLesson(
        id: '3-2',
        title: '3-2 类型断言与类型保护',
        duration: '07:53',
      ),
      CourseLesson(
        id: '3-3',
        title: '3-3 索引类型与映射类型',
        duration: '06:31',
      ),
      CourseLesson(
        id: '3-4',
        title: '3-4 泛型',
        duration: '12:37',
      ),
      CourseLesson(
        id: '3-5',
        title: '3-5 条件类型与工具类型（上）',
        duration: '',
      ),
      CourseLesson(
        id: '3-6',
        title: '3-6 条件类型与工具类型（下）',
        duration: '',
      ),
    ],
  ),
  CourseChapter(
    id: '4',
    title: '第4章 总结',
    duration: '13:06',
    lessons: [
      CourseLesson(
        id: '4-1',
        title: '4-1 从类型系统到类型变成',
        duration: '13:06',
      ),
    ],
  ),
];
