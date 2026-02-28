library;

import 'package:flutter/material.dart';

/// 课程简介标签页
///
/// 显示课程的详细介绍信息
class CourseIntroTab extends StatelessWidget {
  const CourseIntroTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 白色背景，确保不透明
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 课程简介
          _buildSectionTitle('课程简介'),
          const SizedBox(height: 12),
          _buildSectionContent(
            '本课程将从零开始，系统地讲解 Flutter 开发的方方面面。'
            '无论你是初学者还是有经验的开发者，都能从中学到实用的知识和技巧。',
          ),
          const SizedBox(height: 24),

          // 适合人群
          _buildSectionTitle('适合人群'),
          const SizedBox(height: 12),
          _buildBulletPoint('Flutter 初学者'),
          _buildBulletPoint('跨平台移动应用开发者'),
          _buildBulletPoint('希望提升技能的前端工程师'),
          const SizedBox(height: 24),

          // 课程亮点
          _buildSectionTitle('课程亮点'),
          const SizedBox(height: 12),
          _buildBulletPoint('系统化知识体系'),
          _buildBulletPoint('实战项目驱动'),
          _buildBulletPoint('最新技术栈覆盖'),
          _buildBulletPoint('详细代码注释'),
          const SizedBox(height: 24),

          // 你将学到
          _buildSectionTitle('你将学到'),
          const SizedBox(height: 12),
          _buildBulletPoint('Flutter 基础到进阶'),
          _buildBulletPoint('Dart 语言核心概念'),
          _buildBulletPoint('状态管理最佳实践'),
          _buildBulletPoint('性能优化技巧'),
          _buildBulletPoint('项目架构设计'),
          const SizedBox(height: 24),
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

  /// 构建小节内容
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.6,
      ),
    );
  }

  /// 构建列表项
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
