library;

import 'package:flutter/widgets.dart';
import 'controlled_animation.dart';
import 'multi_track_tween.dart';

/// 淡入淡出动画组件
///
/// 同时控制透明度和位移
/// 适用于：列表项逐个显示、页面进入动画等场景
class FadeAnimation extends StatelessWidget {
  /// 延迟倍数（用于多个动画依次执行）
  final double delay;

  /// 子组件
  final Widget child;

  const FadeAnimation({
    super.key,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track('opacity').add(
        const Duration(milliseconds: 500),
        Tween<double>(begin: 0.0, end: 1.0),
      ),
      Track('translateX').add(
        const Duration(milliseconds: 500),
        Tween<double>(begin: 120.0, end: 0.0),
        curve: Curves.easeOut,
      ),
    ]);

    return ControlledAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      builderWithChild: (context, child, animation) {
        final opacity = animation['opacity'] as double? ?? 0.0;
        final translateX = animation['translateX'] as double? ?? 0.0;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(translateX, 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
