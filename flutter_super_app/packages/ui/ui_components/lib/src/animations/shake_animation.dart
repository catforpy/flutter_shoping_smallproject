library;

import 'package:flutter/widgets.dart';
import 'controlled_animation.dart';
import 'multi_track_tween.dart';

/// 抖动动画组件
///
/// 适用于：错误提示、刷新反馈、输入验证等场景
class ShakeAnimation extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 抖动强度（水平偏移像素）
  final double shakeIntensity;

  /// 动画时长
  final Duration duration;

  /// 动画完成回调
  final VoidCallback? onAnimationComplete;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.shakeIntensity = 5.0,
    this.duration = const Duration(milliseconds: 300),
    this.onAnimationComplete,
  });

  @override
  State<ShakeAnimation> createState() => ShakeAnimationState();
}

/// ShakeAnimation 状态类
class ShakeAnimationState extends State<ShakeAnimation> {
  Playback _playback = Playback.pause;

  /// 触发抖动动画（外部可通过 GlobalKey 调用）
  void triggerShake() {
    if (mounted) {
      setState(() {
        _playback = Playback.startOverForward;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 定义抖动动画轨迹（左右偏移）
    final tween = MultiTrackTween([
      Track('translateX')
          .add(
            const Duration(milliseconds: 50),
            Tween<double>(begin: 0.0, end: widget.shakeIntensity),
          )
          .add(
            const Duration(milliseconds: 50),
            Tween<double>(begin: widget.shakeIntensity, end: -widget.shakeIntensity),
          )
          .add(
            const Duration(milliseconds: 50),
            Tween<double>(begin: -widget.shakeIntensity, end: widget.shakeIntensity),
          )
          .add(
            const Duration(milliseconds: 50),
            Tween<double>(begin: widget.shakeIntensity, end: -widget.shakeIntensity),
          )
          .add(
            const Duration(milliseconds: 100),
            Tween<double>(begin: -widget.shakeIntensity, end: 0.0),
          ),
    ]);

    return ControlledAnimation(
      playback: _playback,
      duration: widget.duration,
      tween: tween,
      animationStatusListener: (status) {
        // 动画完成后重置状态并触发回调
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _playback = Playback.pause;
          });
          widget.onAnimationComplete?.call();
        }
      },
      builder: (context, animation) {
        final translateX = animation['translateX'] as double? ?? 0.0;
        return Transform.translate(
          offset: Offset(translateX, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// GlobalKey 扩展方法 - 简化外部调用
extension ShakeAnimationExtension on GlobalKey<ShakeAnimationState> {
  void triggerShake() {
    currentState?.triggerShake();
  }
}
