import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:core_media/core_media.dart';

/// 视频播放器 UI 组件
///
/// 这是 core_ui 包的组件，提供带 UI 的视频播放器
/// 底层控制器由 core_media 的 AppVideoPlayerController 提供
///
/// 设计理念：
/// - 保持最简单的播放功能
/// - 预留扩展插槽，不包含具体业务逻辑
/// - 业务层通过回调/Builder 模式自定义功能
class AppVideoPlayer extends StatefulWidget {
  /// 视频控制器（必需）
  final AppVideoPlayerController controller;

  /// 尺寸
  final double? width;
  final double? height;

  /// 是否显示控制条（使用默认控制条）
  final bool showControls;

  /// ========== 扩展插槽 ==========

  /// 自定义控制条构建器
  /// 如果提供此参数，将忽略 showControls
  final Widget Function(BuildContext, AppVideoPlayerController)? controlsBuilder;

  /// 悬浮层构建器
  /// 用于放置弹幕、点赞、礼物等业务组件
  final Widget Function(BuildContext, AppVideoPlayerController)? overlayBuilder;

  /// 背景点击回调
  /// 业务层可以用于全屏/退出全屏等操作
  final VoidCallback? onBackgroundTap;

  /// 加载中的占位组件
  final Widget? loadingWidget;

  /// 自定义控制条显示/隐藏逻辑
  /// 返回 true 显示控制条，false 隐藏
  final bool Function(AppVideoPlayerController)? controlsVisibilityBuilder;

  const AppVideoPlayer({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.showControls = true,
    this.controlsBuilder,      // 扩展点1: 自定义控制条
    this.overlayBuilder,       // 扩展点2: 悬浮层
    this.onBackgroundTap,      // 扩展点3: 背景点击
    this.loadingWidget,
    this.controlsVisibilityBuilder,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  Timer? _positionUpdateTimer;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    // 延迟启动 Timer，避免在初始化期间频繁更新
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _startPositionUpdateTimer();
      }
    });
  }

  void _startPositionUpdateTimer() {
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;

      // 检查控制器是否仍然有效
      if (!widget.controller.isInitialized) {
        _positionUpdateTimer?.cancel();
        return;
      }

      // 只更新 UI
      setState(() {});
    });
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.controller.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    setState(() {});
  }

  void _handleTap() {
    // 如果提供了背景点击回调，使用它
    if (widget.onBackgroundTap != null) {
      widget.onBackgroundTap!();
      return;
    }

    // 默认行为：切换控制条显示
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isInitialized) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? 200,
        child: widget.loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 视频显示
          RepaintBoundary(
            child: GestureDetector(
              onTap: _handleTap,
              child: AbsorbPointer(
                absorbing: widget.onBackgroundTap != null,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: widget.controller.aspectRatio,
                    child: VideoPlayer(widget.controller.controller),
                  ),
                ),
              ),
            ),
          ),

          // 悬浮层插槽（弹幕、礼物、点赞等）
          if (widget.overlayBuilder != null)
            widget.overlayBuilder!(context, widget.controller),

          // 控制层
          if (_shouldShowControls())
            _buildControlsLayer(),
        ],
      ),
    );
  }

  /// 判断是否应该显示控制条
  bool _shouldShowControls() {
    // 如果提供了自定义控制条构建器，使用它
    if (widget.controlsBuilder != null) return true;

    // 如果提供了自定义显示逻辑，使用它
    if (widget.controlsVisibilityBuilder != null) {
      return widget.controlsVisibilityBuilder!(widget.controller);
    }

    // 默认逻辑：showControls 为 true 且 _showOverlay 为 true
    return widget.showControls && _showOverlay;
  }

  /// 构建控制层
  Widget _buildControlsLayer() {
    // 如果提供了自定义控制条构建器，使用它
    if (widget.controlsBuilder != null) {
      return widget.controlsBuilder!(context, widget.controller);
    }

    // 否则使用默认控制条
    return _DefaultControls(
      controller: widget.controller,
      isVisible: _showOverlay,
      onTogglePlayPause: _togglePlayPause,
    );
  }
}

/// 默认控制条组件
///
/// 这是一个内部组件，提供最简单的播放控制
/// 业务层可以通过 controlsBuilder 完全替换
class _DefaultControls extends StatelessWidget {
  final AppVideoPlayerController controller;
  final bool isVisible;
  final VoidCallback onTogglePlayPause;

  const _DefaultControls({
    required this.controller,
    required this.isVisible,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.isPlaying;
    final position = controller.position;

    return GestureDetector(
      onTap: () {}, // 阻止事件冒泡
      child: Opacity(
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 中央播放按钮
              GestureDetector(
                onTap: onTogglePlayPause,
                child: Center(
                  child: isPlaying
                      ? const SizedBox.shrink()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              // 底部进度信息
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(controller.duration),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
