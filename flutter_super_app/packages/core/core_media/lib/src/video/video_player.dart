import 'dart:io';
import 'dart:ui' show Size;
import 'package:video_player/video_player.dart';

/// 视频播放器控制器封装
///
/// 这是 core_media 的底层封装，只提供视频播放的核心能力
/// 不包含任何 UI 组件
class AppVideoPlayerController {
  final VideoPlayerController _controller;

  AppVideoPlayerController._(this._controller);

  /// 从网络 URL 创建控制器
  static Future<AppVideoPlayerController> network(String url) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await controller.initialize();
    return AppVideoPlayerController._(controller);
  }

  /// 从本地文件创建控制器
  static Future<AppVideoPlayerController> file(String filePath) async {
    final controller = VideoPlayerController.file(File(filePath));
    await controller.initialize();
    return AppVideoPlayerController._(controller);
  }

  /// 从已有的 VideoPlayerController 创建
  factory AppVideoPlayerController.fromController(VideoPlayerController controller) {
    return AppVideoPlayerController._(controller);
  }

  /// 播放
  void play() => _controller.play();

  /// 暂停
  void pause() => _controller.pause();

  /// 跳转到指定位置
  void seekTo(Duration position) => _controller.seekTo(position);

  /// 设置循环播放
  void setLooping(bool looping) => _controller.setLooping(looping);

  /// 设置播放速度
  void setPlaybackSpeed(double speed) => _controller.setPlaybackSpeed(speed);

  /// 获取内部控制器（用于与 VideoPlayer widget 集成）
  VideoPlayerController get controller => _controller;

  /// 是否已初始化
  bool get isInitialized => _controller.value.isInitialized;

  /// 是否正在播放
  bool get isPlaying => _controller.value.isPlaying;

  /// 是否正在缓冲
  bool get isBuffering => _controller.value.isBuffering;

  /// 是否循环播放
  bool get isLooping => _controller.value.isLooping;

  /// 播放速度
  double get playbackSpeed => _controller.value.playbackSpeed;

  /// 当前播放位置
  Duration get position => _controller.value.position;

  /// 视频总时长
  Duration get duration => _controller.value.duration;

  /// 视频宽高比
  double get aspectRatio => _controller.value.aspectRatio;

  /// 视频尺寸
  Size get size => _controller.value.size;

  /// 释放资源
  void dispose() => _controller.dispose();
}
