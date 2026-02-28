library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/paid_course_play_provider.dart';

/// 收费课程播放页
///
/// 收费课程需要先购买才能播放
/// 未购买时显示购买引导，已购买后显示视频播放器
class PaidCoursePlayPage extends ConsumerStatefulWidget {
  /// 课程ID
  final String courseId;

  /// 课程标题
  final String title;

  /// 视频 URL（购买后可用）
  final String? videoUrl;

  /// 课程封面图
  final String coverImage;

  /// 课程价格（分）
  final int price;

  /// 原价（分，可选）
  final int? originalPrice;

  const PaidCoursePlayPage({
    super.key,
    required this.courseId,
    required this.title,
    this.videoUrl,
    required this.coverImage,
    required this.price,
    this.originalPrice,
  });

  @override
  ConsumerState<PaidCoursePlayPage> createState() => _PaidCoursePlayPageState();
}

class _PaidCoursePlayPageState extends ConsumerState<PaidCoursePlayPage> {

  @override
  void initState() {
    super.initState();
    // TODO: 检查用户是否已购买此课程
    _checkPurchaseStatus();
  }

  /// 检查购买状态
  void _checkPurchaseStatus() async {
    // TODO: 从后端 API 检查购买状态
    // 临时设置，实际需要从 API 获取
    ref.read(paidCoursePlayPurchaseProvider(widget.courseId).notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    // 监听购买状态和加载状态
    final isPurchased = ref.watch(paidCoursePlayPurchaseProvider(widget.courseId));
    final isLoading = ref.watch(paidCoursePlayLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: isPurchased
            ? _buildPlayerView()
            : _buildPurchaseView(isLoading),
      ),
    );
  }

  /// 构建播放器视图（已购买）
  Widget _buildPlayerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.play_circle_outline, size: 100),
        const SizedBox(height: 16),
        Text('视频播放器 - ${widget.title}'),
        const SizedBox(height: 16),
        Text('视频 URL: ${widget.videoUrl ?? "无"}'),
      ],
    );
  }

  /// 构建购买引导视图（未购买）
  Widget _buildPurchaseView(bool isLoading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 100),
        const SizedBox(height: 16),
        const Text('此课程需要购买后观看'),
        const SizedBox(height: 8),
        Text(
          '¥${(widget.price / 100).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading ? null : _onPurchaseTap,
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text('立即购买'),
        ),
      ],
    );
  }

  /// 购买按钮点击事件
  void _onPurchaseTap() async {
    // 更新加载状态
    ref.read(paidCoursePlayLoadingProvider.notifier).state = true;

    // TODO: 调用购买 API
    await Future.delayed(const Duration(seconds: 1));

    // 更新状态
    ref.read(paidCoursePlayLoadingProvider.notifier).state = false;
    ref.read(paidCoursePlayPurchaseProvider(widget.courseId).notifier).state = true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('购买成功！')),
      );
    }
  }
}
