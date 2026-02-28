library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_media/core_media.dart';

/// 混合媒体轮播图组件
///
/// 支持视频和图片混合展示，第一个位置通常是视频
/// 特性：
/// - 不自动轮播，需手动滑动
/// - 视频离开页面自动暂停，回到页面自动继续播放
/// - 视频播放完成后停在开头，显示重播按钮
/// - 支持静音/取消静音悬浮按钮
class MixedMediaCarousel extends StatefulWidget {
  /// 视频URL（第一个位置）
  final String? videoUrl;

  /// 视频初始化回调
  final Function(AppVideoPlayerController)? onVideoInitialized;

  /// 图片URL列表（从第二个位置开始）
  final List<String> imageUrls;

  /// 轮播图高度
  final double height;

  /// 边角
  final BorderRadius? borderRadius;

  /// 是否显示静音按钮
  final bool showMuteButton;

  const MixedMediaCarousel({
    super.key,
    this.videoUrl,
    this.onVideoInitialized,
    this.imageUrls = const [],
    this.height = 200,
    this.borderRadius,
    this.showMuteButton = true,
  });

  @override
  State<MixedMediaCarousel> createState() => _MixedMediaCarouselState();
}

class _MixedMediaCarouselState extends State<MixedMediaCarousel> {
  AppVideoPlayerController? _videoController;
  late PageController _pageController;
  int _currentIndex = 0;

  // 视频状态
  bool _isMuted = false;
  bool _hasVideoEnded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(MixedMediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl && widget.videoUrl != null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final controller = await AppVideoPlayerController.network(widget.videoUrl!);

    if (!mounted) return;

    // 监听视频播放完成
    controller.controller.addListener(_onVideoPositionChanged);

    setState(() {
      _videoController = controller;
    });

    widget.onVideoInitialized?.call(controller);
  }

  void _onVideoPositionChanged() {
    if (_videoController == null || !_videoController!.isInitialized) return;

    final position = _videoController!.position;
    final duration = _videoController!.duration;

    // 检查视频是否播放完成
    final isEnded = position >= duration - Duration(milliseconds: 100);

    if (isEnded && !_hasVideoEnded) {
      setState(() {
        _hasVideoEnded = true;
      });
    } else if (!isEnded && _hasVideoEnded) {
      setState(() {
        _hasVideoEnded = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  /// 页面切换时的处理
  void _onPageChanged(int index) {
    final oldIndex = _currentIndex;

    setState(() {
      _currentIndex = index;
    });

    // 离开视频页面（index 0）→ 暂停视频
    if (oldIndex == 0 && index != 0) {
      if (_videoController?.isPlaying ?? false) {
        _videoController?.pause();
      }
    }

    // 回到视频页面 → 继续播放（如果还没播放完）
    if (oldIndex != 0 && index == 0) {
      if (_videoController != null && _videoController!.isInitialized && !_hasVideoEnded) {
        _videoController!.play();
      }
    }
  }

  /// 切换静音状态
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _videoController?.controller.setVolume(_isMuted ? 0 : 1);
  }

  /// 重播视频
  void _replayVideo() {
    _videoController?.seekTo(Duration.zero);
    _videoController?.play();
    setState(() {
      _hasVideoEnded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildCarouselItems();

    if (items.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Container(
      height: widget.height,
      decoration: widget.borderRadius != null
          ? BoxDecoration(borderRadius: widget.borderRadius)
          : null,
      clipBehavior: widget.borderRadius != null
          ? Clip.antiAlias
          : Clip.none,
      child: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: items,
      ),
    );
  }

  /// 构建轮播图项列表
  List<Widget> _buildCarouselItems() {
    final List<Widget> items = [];

    // 第一项：视频
    if (widget.videoUrl != null) {
      items.add(_buildVideoItem());
    }

    // 后续项：图片
    for (int i = 0; i < widget.imageUrls.length; i++) {
      items.add(_buildImageItem(i));
    }

    return items;
  }

  /// 构建视频项
  Widget _buildVideoItem() {
    if (_videoController == null || !_videoController!.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // 视频播放器
        AppVideoPlayer(
          controller: _videoController!,
          showControls: false,
          onBackgroundTap: () {
            // 点击视频 → 暂停/播放
            if (_videoController!.isPlaying) {
              _videoController!.pause();
            } else {
              if (_hasVideoEnded) {
                _replayVideo();
              } else {
                _videoController!.play();
              }
            }
            setState(() {});
          },
          overlayBuilder: (context, controller) {
            // 播放完成时显示重播按钮
            if (_hasVideoEnded) {
              return _buildReplayButton();
            }
            return const SizedBox.shrink();
          },
        ),

        // 静音按钮
        if (widget.showMuteButton) _buildMuteButton(),

        // 当前指示器
        _buildPageIndicator(),
      ],
    );
  }

  /// 构建图片项
  Widget _buildImageItem(int index) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: widget.imageUrls[index],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.error)),
          ),
        ),

        // 页面指示器
        _buildPageIndicator(),
      ],
    );
  }

  /// 构建静音按钮
  Widget _buildMuteButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: _toggleMute,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// 构建重播按钮
  Widget _buildReplayButton() {
    return Center(
      child: GestureDetector(
        onTap: _replayVideo,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(20),
          child: const Icon(
            Icons.replay,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }

  /// 构建页面指示器
  Widget _buildPageIndicator() {
    final totalItems = (widget.videoUrl != null ? 1 : 0) + widget.imageUrls.length;
    if (totalItems <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalItems, (index) {
          final isActive = index == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
