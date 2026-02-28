library;

import 'package:flutter/widgets.dart';

/// 播放模式枚举
enum Playback {
  /// 暂停
  pause,

  /// 向前播放
  playForward,

  /// 向后播放
  playReverse,

  /// 从头开始向前播放
  startOverForward,

  /// 从尾开始向后播放
  startOverReverse,

  /// 循环播放
  loop,

  /// 镜像播放（来回）
  mirror,
}

/// 通用动画控制器
///
/// 管理动画的生命周期和播放状态
class ControlledAnimation<T> extends StatefulWidget {
  /// 播放模式
  final Playback playback;

  /// 补间动画（定义动画值的变化）
  final Animatable<T> tween;

  /// 动画曲线（缓动函数）
  final Curve curve;

  /// 动画时长
  final Duration duration;

  /// 动画延迟
  final Duration? delay;

  /// 构建器（基于动画值构建 Widget）
  final Widget Function(BuildContext context, T animatedValue)? builder;

  /// 带子组件的构建器（性能优化）
  final Widget Function(BuildContext context, Widget child, T animatedValue)?
      builderWithChild;

  /// 子组件（用于 builderWithChild）
  final Widget? child;

  /// 动画状态监听器
  final AnimationStatusListener? animationStatusListener;

  /// 起始位置 (0.0 - 1.0)
  final double startPosition;

  const ControlledAnimation({
    super.key,
    this.playback = Playback.playForward,
    required this.tween,
    this.curve = Curves.linear,
    required this.duration,
    this.delay,
    this.builder,
    this.builderWithChild,
    this.child,
    this.animationStatusListener,
    this.startPosition = 0.0,
  })  : assert(
          (builderWithChild != null && child != null && builder == null) ||
              (builder != null && builderWithChild == null && child == null),
          'Either use builder OR use builderWithChild with a child.',
        );

  @override
  State<ControlledAnimation<T>> createState() =>
      _ControlledAnimationState<T>();
}

class _ControlledAnimationState<T> extends State<ControlledAnimation<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<T> _animation;
  bool _isDisposed = false;
  bool _waitForDelay = true;
  bool _isCurrentlyMirroring = false;

  @override
  void initState() {
    super.initState();

    // 创建动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {}); // 触发重建
      })
      ..value = widget.startPosition;

    // 创建动画
    _animation = widget.tween
        .chain(CurveTween(curve: widget.curve))
        .animate(_controller);

    // 添加状态监听器
    if (widget.animationStatusListener != null) {
      _controller.addStatusListener(widget.animationStatusListener!);
    }

    // 初始化
    _initialize();
  }

  /// 初始化动画（处理延迟）
  Future<void> _initialize() async {
    if (widget.delay != null) {
      await Future.delayed(widget.delay!);
    }
    if (mounted) {
      setState(() {
        _waitForDelay = false;
      });
      _executeInstruction();
    }
  }

  @override
  void didUpdateWidget(ControlledAnimation<T> oldWidget) {
    // 更新动画时长
    _controller.duration = widget.duration;

    // 重新创建动画
    _animation = widget.tween
        .chain(CurveTween(curve: widget.curve))
        .animate(_controller);

    // 更新状态监听器
    if (widget.animationStatusListener != oldWidget.animationStatusListener) {
      if (oldWidget.animationStatusListener != null) {
        _controller.removeStatusListener(oldWidget.animationStatusListener!);
      }
      if (widget.animationStatusListener != null) {
        _controller.addStatusListener(widget.animationStatusListener!);
      }
    }

    // 执行播放指令
    _executeInstruction();
    super.didUpdateWidget(oldWidget);
  }

  /// 执行播放指令
  void _executeInstruction() {
    if (_isDisposed || _waitForDelay) {
      return;
    }

    switch (widget.playback) {
      case Playback.pause:
        _controller.stop();
        break;
      case Playback.playForward:
        _controller.forward();
        break;
      case Playback.playReverse:
        _controller.reverse();
        break;
      case Playback.startOverForward:
        _controller.forward(from: 0.0);
        break;
      case Playback.startOverReverse:
        _controller.reverse(from: 1.0);
        break;
      case Playback.loop:
        _controller.repeat();
        break;
      case Playback.mirror:
        if (!_isCurrentlyMirroring) {
          _isCurrentlyMirroring = true;
          _controller.repeat(reverse: true);
        }
        break;
    }

    // 重置镜像状态
    if (widget.playback != Playback.mirror) {
      _isCurrentlyMirroring = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(context, _animation.value);
    } else if (widget.builderWithChild != null && widget.child != null) {
      return widget.builderWithChild!(context, widget.child!, _animation.value);
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }
}
