library;

import 'package:flutter/material.dart';

/// 热门标签页
///
/// 特性：
/// - 网格布局展示热门内容
/// - 支持下拉刷新
class HotTab extends StatefulWidget {
  const HotTab({super.key});

  @override
  State<HotTab> createState() => _HotTabState();
}

class _HotTabState extends State<HotTab> {
  /// 热门内容列表
  final List<Map<String, dynamic>> _hotItems = List.generate(20, (index) {
    return {
      'title': '热门内容 ${index + 1}',
      'likes': '${(index + 1) * 123}',
      'color': _getRandomColor(index),
    };
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _hotItems.length,
        itemBuilder: (context, index) {
          return _buildHotItem(_hotItems[index]);
        },
      ),
    );
  }

  /// 构建热门内容项
  Widget _buildHotItem(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: item['color'] as Color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Icon(
                Icons.image,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['likes'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 处理下拉刷新
  Future<void> _handleRefresh() async {
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));
  }

  /// 获取随机颜色（基于索引）
  static Color _getRandomColor(int index) {
    final colors = [
      const Color(0xFF6C63FF), // 紫色
      const Color(0xFFFF6B6B), // 红色
      const Color(0xFF4ECDC4), // 青色
      const Color(0xFFFFA726), // 橙色
      const Color(0xFF66BB6A), // 绿色
    ];
    return colors[index % colors.length];
  }
}
