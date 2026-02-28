import 'dart:io';
import 'package:record/record.dart' as record_pkg;
import 'package:permission_handler/permission_handler.dart';

/// 录音器控制器封装
///
/// 这是 core_audio 的底层封装，只提供录音的核心能力
/// 不包含任何 UI 组件
class AudioRecorder {
  final _recorder = record_pkg.AudioRecorder();
  String? _currentPath;

  /// 是否正在录音
  Future<bool> get isRecording async => await _recorder.isRecording();

  /// 是否已暂停
  Future<bool> get isPaused async => await _recorder.isPaused();

  /// 请求麦克风权限
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    }
    return true;
  }

  /// 开始录音
  ///
  /// [path] 可选的录音文件路径。如果不提供，将使用临时路径
  Future<void> start([String? path]) async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('没有麦克风权限');
    }

    // 如果没有提供路径，生成临时路径
    if (path == null) {
      final directory = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      path = '${directory.path}/recording_$timestamp.m4a';
    }

    _currentPath = path;

    // 使用默认配置开始录音
    await _recorder.start(
      const record_pkg.RecordConfig(),
      path: path,
    );
  }

  /// 停止录音
  ///
  /// 返回录音文件路径
  Future<String?> stop() async {
    if (!await isRecording) {
      return _currentPath;
    }
    final path = await _recorder.stop();
    _currentPath = null;
    return path;
  }

  /// 暂停录音
  Future<void> pause() async {
    await _recorder.pause();
  }

  /// 恢复录音
  Future<void> resume() async {
    await _recorder.resume();
  }

  /// 释放资源
  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
