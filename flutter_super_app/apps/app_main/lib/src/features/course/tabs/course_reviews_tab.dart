library;

import 'package:flutter/material.dart';

/// 课程评价标签页
///
/// 显示用户评价和评分统计
class CourseReviewsTab extends StatelessWidget {
  const CourseReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 评分统计
          _buildRatingSummary(),
          const SizedBox(height: 24),

          // 评价列表标题
          _buildSectionTitle('学员评价'),
          const SizedBox(height: 12),

          // 评价列表
          ...List.generate(5, (index) => _buildReview(index)),
        ],
      ),
    ),
  );
}

  /// 构建评分统计
  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // 左侧：总评分
          Column(
            children: [
              const Text(
                '4.9',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '12,345 人评价',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(width: 32),

          // 右侧：评分分布
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 85),
                const SizedBox(height: 8),
                _buildRatingBar(4, 10),
                const SizedBox(height: 8),
                _buildRatingBar(3, 3),
                const SizedBox(height: 8),
                _buildRatingBar(2, 1),
                const SizedBox(height: 8),
                _buildRatingBar(1, 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评分条
  Widget _buildRatingBar(int stars, int percentage) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.star, size: 16, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
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

  /// 构建评价卡片
  Widget _buildReview(int index) {
    final reviews = [
      {
        'name': '张三',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'rating': 5,
        'content': '课程内容非常详细，老师讲解很清晰，学到了很多实用的技巧！',
        'time': '2天前',
      },
      {
        'name': '李四',
        'avatar': 'https://i.pravatar.cc/150?img=2',
        'rating': 5,
        'content': '从零基础到能独立开发项目，这门课程功不可没。强烈推荐！',
        'time': '5天前',
      },
      {
        'name': '王五',
        'avatar': 'https://i.pravatar.cc/150?img=3',
        'rating': 4,
        'content': '课程质量很高，但是有些章节可以再深入一点。总体不错！',
        'time': '1周前',
      },
      {
        'name': '赵六',
        'avatar': 'https://i.pravatar.cc/150?img=4',
        'rating': 5,
        'content': '跟着课程做了两个项目，现在对 Flutter 的理解更深了。',
        'time': '2周前',
      },
      {
        'name': '孙七',
        'avatar': 'https://i.pravatar.cc/150?img=5',
        'rating': 5,
        'content': '性价比很高的课程，比很多付费课程都要好。',
        'time': '3周前',
      },
    ];

    final review = reviews[index % reviews.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['avatar'] as String),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        review['rating'] as int,
                        (index) => const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review['time'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 评价内容
          Text(
            review['content'] as String,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
