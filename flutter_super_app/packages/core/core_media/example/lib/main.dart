import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:core_media/core_media.dart';
import 'package:core_ui/core_ui.dart';
import 'package:core_audio/core_audio.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MediaTestPage(),
    );
  }
}

class MediaTestPage extends StatefulWidget {
  const MediaTestPage({super.key});

  @override
  State<MediaTestPage> createState() => _MediaTestPageState();
}

class _MediaTestPageState extends State<MediaTestPage> {
  // 网络视频URL列表
  final List<String> _networkVideos = [
    'https://www.w3schools.com/html/mov_bbb.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  ];

  // 网络音频URL列表
  final List<Map<String, String>> _networkAudios = [
    {
      'title': '测试音频',
      'artist': '在线音频',
      'url': 'https://duda360.oss-cn-hangzhou.aliyuncs.com/duda1234/2025-07-15/6875e33984a4b.mp3',
      'cover': 'https://picsum.photos/seed/audio/200/200',
    },
  ];

  int _currentVideoIndex = 0;
  int _currentAudioIndex = 0;
  AppVideoPlayerController? _videoController;
  AudioPlayerController? _audioController;
  bool _isLoadingVideo = true;
  String _errorMessage = '';

  // 录音相关
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _loadVideo(_currentVideoIndex);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioController?.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  // 加载视频
  Future<void> _loadVideo(int index) async {
    // 释放之前的视频控制器
    _videoController?.dispose();

    setState(() {
      _isLoadingVideo = true;
      _errorMessage = '';
      _videoController = null;
    });

    try {
      final controller = await AppVideoPlayerController.network(_networkVideos[index]);
      if (mounted) {
        setState(() {
          _videoController = controller;
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingVideo = false;
        });
      }
    }
  }

  // 加载音频
  Future<void> _loadAudio(int index) async {
    // 释放之前的音频控制器
    _audioController?.dispose();

    setState(() {
      _currentAudioIndex = index;
      _audioController = null;
    });

    try {
      final controller = await AudioPlayerController.network(_networkAudios[index]['url']!);
      if (mounted) {
        setState(() {
          _audioController = controller;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('音频加载失败: $e')),
        );
      }
    }
  }

  // 请求麦克风权限
  Future<bool> _requestMicrophonePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Core Media 测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 测试1: 视频播放
            _buildSectionTitle('1. 网络视频播放'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('选择视频: '),
                DropdownButton<int>(
                  value: _currentVideoIndex,
                  items: List.generate(
                    _networkVideos.length,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text('视频 ${index + 1}'),
                    ),
                  ),
                  onChanged: (index) {
                    if (index != null) {
                      setState(() {
                        _currentVideoIndex = index;
                      });
                      _loadVideo(index);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: _isLoadingVideo
                      ? const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _errorMessage.isNotEmpty
                          ? SizedBox(
                              height: 200,
                              child: Center(
                                child: Text('加载失败: $_errorMessage'),
                              ),
                            )
                          : _videoController != null
                              ? AppVideoPlayer(
                                  key: ValueKey(_videoController.hashCode),
                                  controller: _videoController!,
                                  showControls: true,
                                )
                              : const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 测试2: 网络音频播放
            _buildSectionTitle('2. 网络音频播放'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('选择音频: '),
                DropdownButton<int>(
                  value: _currentAudioIndex,
                  items: List.generate(
                    _networkAudios.length,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text('音频 ${index + 1}'),
                    ),
                  ),
                  onChanged: (index) {
                    if (index != null) {
                      _loadAudio(index);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _audioController != null
                    ? AppAudioPlayer(
                        key: ValueKey(_audioController.hashCode),
                        controller: _audioController!,
                        showControls: true,
                      )
                    : const SizedBox(
                        height: 100,
                        child: Center(child: Text('请选择音频')),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 测试3: 录音测试
            _buildSectionTitle('3. 录音测试'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          color: _isRecording ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRecording ? '正在录音...' : '未录音',
                          style: TextStyle(
                            color: _isRecording ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isRecording ? _stopRecording : _startRecording,
                          icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                          label: Text(_isRecording ? '停止录音' : '开始录音'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRecording ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_recordedFilePath != null) ...[
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _playRecording,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('播放录音'),
                          ),
                        ],
                      ],
                    ),
                    if (_recordedFilePath != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        '录音文件: $_recordedFilePath',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 测试4: 网络图片加载
            _buildSectionTitle('4. 网络图片加载'),
            const SizedBox(height: 8),
            AppImageLoader(
              imageUrl: 'https://pic.rmb.bdstatic.com/bjh/news/d784e0991477b5a84f4ed1de4f1693c7.png',
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 24),

            // 测试5: 圆形图片
            _buildSectionTitle('5. 圆形头像'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppCircleImage(
                  imageUrl: 'https://picsum.photos/seed/user/200/200',
                  size: 60,
                ),
                AppCircleImage(
                  imageUrl: 'https://picsum.photos/seed/avatar/200/200',
                  size: 80,
                ),
                AppCircleImage(
                  imageUrl: 'https://picsum.photos/seed/profile/200/200',
                  size: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // 开始录音
  Future<void> _startRecording() async {
    try {
      await _audioRecorder.start();
      setState(() {
        _isRecording = true;
        _recordedFilePath = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音失败: $e')),
        );
      }
    }
  }

  // 停止录音
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
      if (mounted && path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音已保存: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('停止录音失败: $e')),
        );
      }
    }
  }

  // 播放录音
  void _playRecording() {
    if (_recordedFilePath != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放录音: $_recordedFilePath')),
        );
      }
    }
  }
}
