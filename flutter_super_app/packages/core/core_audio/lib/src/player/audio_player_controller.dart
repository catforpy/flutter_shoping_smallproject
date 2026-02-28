import 'package:just_audio/just_audio.dart';

/// 音频播放器控制器封装
///
/// 这是 core_audio 的底层封装，只提供音频播放的核心能力
/// 不包含任何 UI 组件
class AudioPlayerController {
  final AudioPlayer _player;

  AudioPlayerController._(this._player);

  /// 从网络 URL 创建控制器
  static Future<AudioPlayerController> network(String url) async {
    final player = AudioPlayer();
    await player.setUrl(url);
    return AudioPlayerController._(player);
  }

  /// 从本地文件创建控制器
  static Future<AudioPlayerController> file(String filePath) async {
    final player = AudioPlayer();
    await player.setFilePath(filePath);
    return AudioPlayerController._(player);
  }

  /// 从 Asset 创建控制器
  static Future<AudioPlayerController> asset(String assetPath) async {
    final player = AudioPlayer();
    await player.setAsset(assetPath);
    return AudioPlayerController._(player);
  }

  /// 播放
  Future<void> play() => _player.play();

  /// 暂停
  Future<void> pause() => _player.pause();

  /// 停止
  Future<void> stop() => _player.stop();

  /// 跳转到指定位置
  Future<void> seekTo(Duration position) => _player.seek(position);

  /// 设置循环模式
  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  /// 设置播放速度
  Future<void> setPlaybackSpeed(double speed) => _player.setSpeed(speed);

  /// 设置音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  /// 获取播放流
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// 获取播放位置流
  Stream<Duration> get positionStream => _player.positionStream;

  /// 获取时长流
  Stream<Duration?> get durationStream => _player.durationStream;

  /// 获取内部播放器（用于与 UI 组件集成）
  AudioPlayer get player => _player;

  /// 是否正在播放
  bool get isPlaying => _player.playing;

  /// 播放速度
  double get playbackSpeed => _player.speed;

  /// 当前播放位置
  Duration get position => _player.position;

  /// 音频总时长
  Duration get duration => _player.duration ?? Duration.zero;

  /// 音量
  double get volume => _player.volume;

  /// 循环模式
  LoopMode get loopMode => _player.loopMode;

  /// 释放资源
  Future<void> dispose() => _player.dispose();
}
