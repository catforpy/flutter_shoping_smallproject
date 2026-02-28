library;

import 'package:flutter/material.dart';

/// 关注标签页
///
/// 特性：
/// - 显示关注的内容列表
/// - 支持下拉刷新
/// - 支持上拉加载更多
class FollowTab extends StatefulWidget {
  const FollowTab({super.key});

  @override
  State<FollowTab> createState() => _FollowTabState();
}

class _FollowTabState extends State<FollowTab> {
  /// 是否正在加载
  bool _isLoading = false;

  /// 关注内容列表
  final List<String> _followItems = List.generate(10, (index) => '关注内容 ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _followItems.length + (_isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // 加载更多指示器
          if (index == _followItems.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 列表项
          return _buildFollowItem(_followItems[index]);
        },
      ),
    );
  }

  /// 构建关注内容项
  Widget _buildFollowItem(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 30),
          ),
          const SizedBox(width: 12),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '这是关注的详细内容描述...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 箭头
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  /// 处理下拉刷新
  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }
}
