library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../course_detail_page.dart';

/// 课程推荐标签页
///
/// 显示相关推荐课程
class CourseRecommendTab extends StatelessWidget {
  const CourseRecommendTab({super.key});

  /// 推荐课程数据
  final List<Map<String, dynamic>> _recommendedCourses = const [
    {
      'id': 'course_flutter_advanced',
      'imageUrl': 'https://picsum.photos/200/200?random=201',
      'title': 'Flutter 进阶实战',
      'subtitle': '大型项目开发经验',
      'price': 29900,
      'originalPrice': 39900,
      'studyCount': 5678,
      'tagType': ProductTagType.hot,
      'tagText': '热销',
    },
    {
      'id': 'course_flutter_performance',
      'imageUrl': 'https://picsum.photos/200/200?random=202',
      'title': 'Flutter 性能优化',
      'subtitle': '让你的应用丝滑流畅',
      'price': 19900,
      'originalPrice': 29900,
      'studyCount': 3456,
      'tagType': ProductTagType.discount,
      'tagText': '限时优惠',
    },
    {
      'id': 'course_dart_deep_dive',
      'imageUrl': 'https://picsum.photos/200/200?random=203',
      'title': 'Dart 深入解析',
      'subtitle': '理解语言核心机制',
      'price': 14900,
      'originalPrice': null,
      'studyCount': 2345,
      'tagType': ProductTagType.new_,
      'tagText': '新课',
    },
    {
      'id': 'course_flutter_hybrid',
      'imageUrl': 'https://picsum.photos/200/200?random=204',
      'title': 'Flutter 混合开发',
      'subtitle': '与原生平台交互',
      'price': 24900,
      'originalPrice': 34900,
      'studyCount': 4567,
      'tagType': ProductTagType.vip,
      'tagText': 'VIP专享',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 推荐标题
          _buildSectionTitle('相关推荐'),
          const SizedBox(height: 12),

          // 推荐课程列表
          ...List.generate(
            _recommendedCourses.length,
            (index) => _buildCourseCard(_recommendedCourses[index]),
          ),
        ],
      ),
    ),
  );
}

  /// 构建小节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// 构建课程卡片
  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Builder(
        builder: (context) => ProductCard(
          imageUrl: course['imageUrl'] as String,
          title: course['title'] as String,
          subtitle: course['subtitle'] as String,
          tag: ProductTag(
            type: course['tagType'] as ProductTagType,
            text: course['tagText'] as String,
          ),
          price: course['price'] as int,
          originalPrice: course['originalPrice'] as int?,
          studyCount: course['studyCount'] as int?,
          onTap: () {
            // 跳转到课程详情页（从右边滑入动画）
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => CourseDetailPage(
                  courseId: course['id'] as String,
                  imageUrl: course['imageUrl'] as String,
                  title: course['title'] as String,
                  subtitle: course['subtitle'] as String?,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
