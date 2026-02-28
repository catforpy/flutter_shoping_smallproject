library;

import 'package:flutter/material.dart';

/// 课程目录标签页
///
/// 显示课程的章节目录
class CourseCatalogTab extends StatefulWidget {
  const CourseCatalogTab({super.key});

  @override
  State<CourseCatalogTab> createState() => _CourseCatalogTabState();
}

class _CourseCatalogTabState extends State<CourseCatalogTab> {
  /// 章节数据
  final List<Map<String, dynamic>> _chapters = [
    {
      'title': '第一章：Flutter 基础入门',
      'lessons': [
        {'title': '1.1 Flutter 简介与环境搭建', 'duration': '15:30', 'free': true},
        {'title': '1.2 Dart 语言基础', 'duration': '25:00', 'free': true},
        {'title': '1.3 第一个 Flutter 应用', 'duration': '20:15', 'free': false},
      ],
    },
    {
      'title': '第二章：Widget 详解',
      'lessons': [
        {'title': '2.1 常用 Widget 介绍', 'duration': '18:45', 'free': false},
        {'title': '2.2 布局 Widget', 'duration': '22:30', 'free': false},
        {'title': '2.3 容器 Widget', 'duration': '16:20', 'free': false},
      ],
    },
    {
      'title': '第三章：状态管理',
      'lessons': [
        {'title': '3.1 setState 与 InheritedWidget', 'duration': '28:00', 'free': false},
        {'title': '3.2 Provider 入门', 'duration': '32:15', 'free': false},
        {'title': '3.3 Riverpod 实战', 'duration': '35:40', 'free': false},
      ],
    },
    {
      'title': '第四章：网络请求与数据持久化',
      'lessons': [
        {'title': '4.1 HTTP 请求封装', 'duration': '24:30', 'free': false},
        {'title': '4.2 JSON 解析', 'duration': '19:45', 'free': false},
        {'title': '4.3 本地存储方案', 'duration': '27:00', 'free': false},
      ],
    },
  ];

  /// 展开的章节索引
  final Set<int> _expandedChapters = <int>{0};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chapters.length,
        itemBuilder: (context, index) {
          return _buildChapter(index);
        },
      ),
    );
  }

  /// 构建章节
  Widget _buildChapter(int index) {
    final chapter = _chapters[index];
    final isExpanded = _expandedChapters.contains(index);
    final lessons = chapter['lessons'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // 章节标题
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedChapters.remove(index);
                } else {
                  _expandedChapters.add(index);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chapter['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // 课程列表（展开时显示）
          if (isExpanded)
            ...lessons.asMap().entries.map((entry) {
              final lessonIndex = entry.key;
              final lesson = entry.value;
              return _buildLesson(lesson, lessonIndex == lessons.length - 1);
            }).toList(),
        ],
      ),
    );
  }

  /// 构建课程
  Widget _buildLesson(Map<String, dynamic> lesson, bool isLast) {
    final isFree = lesson['free'] as bool;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
              ),
      ),
      child: Row(
        children: [
          // 播放图标
          Icon(
            Icons.play_circle_outline,
            size: 32,
            color: isFree ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 12),

          // 课程信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: isFree ? Colors.black87 : Colors.grey[700],
                    fontWeight: isFree ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson['duration'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // 免费标签
          if (isFree)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '免费',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
