library;

import 'package:flutter/material.dart';
import 'controlled_animation.dart';
import 'multi_track_tween.dart';

/// 数字滚动动画组件
///
/// 从 0 逐帧滚动到目标数字
/// 适用于：粉丝数、点赞数、金额等数字展示场景
class NumberRollingAnimation extends StatelessWidget {
  /// 目标数字（最终显示值）
  final int targetNumber;

  /// 数字样式
  final TextStyle? style;

  /// 动画时长
  final Duration duration;

  /// 动画延迟
  final Duration delay;

  /// 动画曲线
  final Curve curve;

  /// 动画播放模式
  final Playback playback;

  const NumberRollingAnimation({
    super.key,
    required this.targetNumber,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.playback = Playback.playForward,
  }) : assert(targetNumber >= 0, '目标数字必须 >= 0');

  @override
  Widget build(BuildContext context) {
    // 构建数字动画 Tween（从 0 到目标数字）
    final tween = MultiTrackTween([
      Track('number').add(
        duration,
        IntTween(begin: 0, end: targetNumber),
        curve: curve,
      ),
    ]);

    return ControlledAnimation(
      playback: playback,
      tween: tween,
      duration: tween.duration,
      delay: delay,
      curve: curve,
      startPosition: 0.0,
      builder: (context, animationValues) {
        // 获取当前动画数字
        final currentNumber = animationValues['number'] as int? ?? 0;

        return Text(
          '$currentNumber',
          style: style ??
              const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }
}
