import 'package:flutter/material.dart';
import 'package:core_media/core_media.dart';
import 'app_video_player.dart';

/// 完整的视频播放器组件
///
/// 功能特性：
/// - 顶部悬浮层：返回、投屏、收藏、字幕、更多按钮
/// - 底部控制栏：播放/暂停、进度条、时间、全屏、横竖屏切换
/// - 所有元素都可配置（显示/隐藏、样式、间距、事件）
///
/// 架构说明：
/// - 内部使用 AppVideoPlayer 作为底层播放器
/// - 通过 overlayBuilder 添加顶部/底部控制栏
/// - 通过 controlsBuilder 实现自定义控制条逻辑
class FullVideoPlayer extends StatefulWidget {
  /// 视频控制器
  final AppVideoPlayerController controller;

  /// 尺寸
  final double? width;
  final double? height;

  /// 背景点击回调（用于切换控制条显示/隐藏）
  final VoidCallback? onBackgroundTap;

  /// 加载中的占位组件
  final Widget? loadingWidget;

  /// ========== 顶部悬浮层配置 ==========

  /// 是否显示顶部悬浮层
  final bool showTopBar;

  /// 顶部悬浮层配置
  final VideoTopBarConfig topBarConfig;

  /// ========== 底部控制栏配置 ==========

  /// 是否显示底部控制栏
  final bool showBottomBar;

  /// 底部控制栏配置
  final VideoBottomBarConfig bottomBarConfig;

  /// ========== 中央播放按钮配置 ==========

  /// 是否显示中央播放按钮
  final bool showCenterPlayButton;

  const FullVideoPlayer({
    super.key,
    required this.controller,
    this.width,
    this.height,
    this.onBackgroundTap,
    this.loadingWidget,
    // 顶部悬浮层
    this.showTopBar = true,
    this.topBarConfig = const VideoTopBarConfig(),
    // 底部控制栏
    this.showBottomBar = true,
    this.bottomBarConfig = const VideoBottomBarConfig(),
    // 中央播放按钮
    this.showCenterPlayButton = true,
  });

  @override
  State<FullVideoPlayer> createState() => _FullVideoPlayerState();
}

class _FullVideoPlayerState extends State<FullVideoPlayer> {
  bool _showOverlay = true;

  void _togglePlayPause() {
    if (widget.controller.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    setState(() {});
  }

  void _handleTap() {
    if (widget.onBackgroundTap != null) {
      widget.onBackgroundTap!();
      return;
    }
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // 视频播放器（不传 onBackgroundTap，避免 AbsorbPointer 阻止控制栏点击）
          AppVideoPlayer(
            controller: widget.controller,
            width: widget.width,
            height: widget.height,
            loadingWidget: widget.loadingWidget,
            showControls: false,
            overlayBuilder: (context, controller) => GestureDetector(
              onTap: widget.onBackgroundTap ?? _handleTap,
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: [
                  // 中央播放按钮
                  if (widget.showCenterPlayButton)
                    _buildCenterPlayButton(),
                ],
              ),
            ),
          ),
          // 顶部悬浮层
          if (widget.showTopBar && _showOverlay)
            VideoTopBar(
              config: widget.topBarConfig,
              currentPosition: widget.controller.position,
            ),
          // 底部控制栏
          if (widget.showBottomBar && _showOverlay)
            VideoBottomBar(
              config: widget.bottomBarConfig,
              controller: widget.controller,
              onTogglePlayPause: _togglePlayPause,
            ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayButton() {
    final isPlaying = widget.controller.isPlaying;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedOpacity(
        opacity: (_showOverlay && !isPlaying) ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
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
    );
  }
}

// ========== 顶部悬浮层配置 ==========

/// 顶部悬浮层配置
class VideoTopBarConfig {
  /// 按钮之间的间距
  final double spacing;

  /// 两侧的内边距
  final EdgeInsets padding;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color iconColor;

  /// 是否显示返回按钮
  final bool showBackButton;

  /// 返回按钮点击事件
  final VoidCallback? onBackTap;

  /// 是否显示投屏按钮
  final bool showCastButton;

  /// 投屏按钮点击事件
  final VoidCallback? onCastTap;

  /// 是否显示收藏按钮
  final bool showFavoriteButton;

  /// 收藏状态
  final bool isFavorite;

  /// 收藏按钮点击事件
  final VoidCallback? onFavoriteTap;

  /// 是否显示字幕按钮
  final bool showSubtitleButton;

  /// 字幕按钮点击事件
  final VoidCallback? onSubtitleTap;

  /// 是否显示更多按钮
  final bool showMoreButton;

  /// 更多按钮点击事件
  final VoidCallback? onMoreTap;

  /// 渐变背景开始颜色（顶部）
  final Color gradientBegin;

  /// 渐变背景结束颜色（底部）
  final Color gradientEnd;

  const VideoTopBarConfig({
    this.spacing = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.iconSize = 24,
    this.iconColor = Colors.white,
    this.showBackButton = true,
    this.onBackTap,
    this.showCastButton = true,
    this.onCastTap,
    this.showFavoriteButton = true,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showSubtitleButton = true,
    this.onSubtitleTap,
    this.showMoreButton = true,
    this.onMoreTap,
    this.gradientBegin = const Color(0xCC000000), // 80% 黑色
    this.gradientEnd = Colors.transparent,
  });
}

/// 顶部悬浮层组件
class VideoTopBar extends StatelessWidget {
  final VideoTopBarConfig config;
  final Duration currentPosition;

  const VideoTopBar({
    super.key,
    required this.config,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [config.gradientBegin, config.gradientEnd],
          ),
        ),
        padding: config.padding,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // 左侧：返回按钮
              if (config.showBackButton)
                IconButton(
                  icon: Icon(Icons.arrow_back, color: config.iconColor, size: config.iconSize),
                  onPressed: config.onBackTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

              const Spacer(),

              // 右侧：投屏、收藏、字幕、更多按钮
              if (config.showCastButton) ...[
                _buildIconButton(Icons.cast, config.onCastTap),
                SizedBox(width: config.spacing),
              ],
              if (config.showFavoriteButton) ...[
                _buildIconButton(
                  config.isFavorite ? Icons.star : Icons.star_border,
                  config.onFavoriteTap,
                ),
                SizedBox(width: config.spacing),
              ],
              if (config.showSubtitleButton) ...[
                _buildIconButton(Icons.subtitles, config.onSubtitleTap),
                SizedBox(width: config.spacing),
              ],
              if (config.showMoreButton)
                _buildIconButton(Icons.more_vert, config.onMoreTap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, color: config.iconColor, size: config.iconSize),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

// ========== 底部控制栏配置 ==========

/// 底部控制栏配置
class VideoBottomBarConfig {
  /// 按钮之间的间距
  final double spacing;

  /// 两侧的内边距
  final EdgeInsets padding;

  /// 图标大小
  final double iconSize;

  /// 文字颜色
  final Color textColor;

  /// 进度条高度
  final double progressBarHeight;

  /// 进度条颜色
  final Color progressBarColor;

  /// 进度条缓冲颜色
  final Color progressBufferedColor;

  /// 进度条背景颜色
  final Color progressBackgroundColor;

  /// 是否显示播放/暂停按钮
  final bool showPlayButton;

  /// 是否显示当前时间
  final bool showCurrentTime;

  /// 是否显示总时间
  final bool showTotalTime;

  /// 是否显示进度条
  final bool showProgressBar;

  /// 是否显示悬浮开关按钮
  final bool showFloatButton;

  /// 悬浮状态
  final bool isFloating;

  /// 悬浮开关按钮点击事件
  final VoidCallback? onFloatTap;

  /// 是否显示横竖屏切换按钮
  final bool showOrientationButton;

  /// 是否横屏
  final bool isLandscape;

  /// 横竖屏切换按钮点击事件
  final VoidCallback? onOrientationTap;

  /// 渐变背景开始颜色（顶部）
  final Color gradientBegin;

  /// 渐变背景结束颜色（底部）
  final Color gradientEnd;

  /// 是否使用 SafeArea 包裹（默认 true）
  final bool useSafeArea;

  const VideoBottomBarConfig({
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.iconSize = 24,
    this.textColor = Colors.white,
    this.progressBarHeight = 3,
    this.progressBarColor = Colors.white,
    this.progressBufferedColor = Colors.white24,
    this.progressBackgroundColor = Colors.white24,
    this.showPlayButton = true,
    this.showCurrentTime = true,
    this.showTotalTime = true,
    this.showProgressBar = true,
    this.showFloatButton = true,
    this.isFloating = false,
    this.onFloatTap,
    this.showOrientationButton = true,
    this.isLandscape = false,
    this.onOrientationTap,
    this.gradientBegin = Colors.transparent,
    this.gradientEnd = const Color(0xCC000000), // 80% 黑色
    this.useSafeArea = true,
  });
}

/// 底部控制栏组件
class VideoBottomBar extends StatelessWidget {
  final VideoBottomBarConfig config;
  final AppVideoPlayerController controller;
  final VoidCallback onTogglePlayPause;

  const VideoBottomBar({
    super.key,
    required this.config,
    required this.controller,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaying = controller.isPlaying;
    final position = controller.position;
    final duration = controller.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [config.gradientBegin, config.gradientEnd],
          ),
        ),
        padding: config.padding,
        child: config.useSafeArea
            ? SafeArea(
                top: false,
                child: Row(
                  children: [
                    // 播放/暂停按钮
                    if (config.showPlayButton)
                      _buildControlButton(
                        icon: isPlaying ? Icons.pause : Icons.play_arrow,
                        onTap: onTogglePlayPause,
                      ),

                    SizedBox(width: config.showPlayButton ? config.spacing : 0),

                    // 当前时间
                    if (config.showCurrentTime)
                      Text(
                        _formatDuration(position),
                        style: TextStyle(color: config.textColor, fontSize: 13),
                      ),

                    SizedBox(width: config.showCurrentTime ? config.spacing : 0),

                    // 进度条（占据中间空间）
                    if (config.showProgressBar)
                      Expanded(child: _buildProgressBar(progress)),

                    SizedBox(width: config.showProgressBar ? config.spacing : 0),

                    // 总时间
                    if (config.showTotalTime) ...[
                      Text(
                        _formatDuration(duration),
                        style: TextStyle(color: config.textColor, fontSize: 13),
                      ),
                      SizedBox(width: config.spacing),
                    ],

                    // 悬浮开关按钮
                    if (config.showFloatButton) ...[
                      _buildIconButton(Icons.picture_in_picture_alt, config.onFloatTap),
                      SizedBox(width: config.spacing),
                    ],

                    // 横竖屏切换按钮
                    if (config.showOrientationButton)
                      _buildIconButton(
                        config.isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                        config.onOrientationTap,
                      ),
                  ],
                ),
              )
            : Row(
                children: [
                  // 播放/暂停按钮
                  if (config.showPlayButton)
                    _buildControlButton(
                      icon: isPlaying ? Icons.pause : Icons.play_arrow,
                      onTap: onTogglePlayPause,
                    ),

                  SizedBox(width: config.showPlayButton ? config.spacing : 0),

                  // 当前时间
                  if (config.showCurrentTime)
                    Text(
                      _formatDuration(position),
                      style: TextStyle(color: config.textColor, fontSize: 13),
                    ),

                  SizedBox(width: config.showCurrentTime ? config.spacing : 0),

                  // 进度条（占据中间空间）
                  if (config.showProgressBar)
                    Expanded(child: _buildProgressBar(progress)),

                  SizedBox(width: config.showProgressBar ? config.spacing : 0),

                  // 总时间
                  if (config.showTotalTime) ...[
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(color: config.textColor, fontSize: 13),
                    ),
                    SizedBox(width: config.spacing),
                  ],

                  // 悬浮开关按钮
                  if (config.showFloatButton) ...[
                    _buildIconButton(Icons.picture_in_picture_alt, config.onFloatTap),
                    SizedBox(width: config.spacing),
                  ],

                  // 横竖屏切换按钮
                  if (config.showOrientationButton)
                    _buildIconButton(
                      config.isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                      config.onOrientationTap,
                    ),
                ],
              ),
      ),
    );
  }

  /// 构建控制按钮（带足够的点击区域）
  Widget _buildControlButton({required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      width: config.iconSize + 16,
      height: config.iconSize + 16,
      child: IconButton(
        icon: Icon(icon, color: config.textColor, size: config.iconSize),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: config.progressBarHeight,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
      ),
      child: Slider(
        value: progress.clamp(0.0, 1.0),
        onChanged: (value) {
          final position = Duration(
            milliseconds: (controller.duration.inMilliseconds * value).round(),
          );
          controller.seekTo(position);
        },
        activeColor: config.progressBarColor,
        inactiveColor: config.progressBackgroundColor,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(icon, color: config.textColor, size: config.iconSize),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
