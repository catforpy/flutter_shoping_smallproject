import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:core_audio/core_audio.dart';

/// 音频播放器 UI 组件
///
/// 这是 core_ui 包的组件，提供带 UI 的音频播放器
/// 底层控制器由 core_audio 的 AudioPlayerController 提供
class AppAudioPlayer extends StatefulWidget {
  final AudioPlayerController controller;
  final double? width;
  final bool showControls;
  final Color? primaryColor;

  const AppAudioPlayer({
    super.key,
    required this.controller,
    this.width,
    this.showControls = true,
    this.primaryColor,
  });

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  void _togglePlayPause() async {
    if (widget.controller.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 进度条
            StreamBuilder<Duration>(
              stream: widget.controller.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: widget.controller.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return Column(
                      children: [
                        Slider(
                          value: progress.clamp(0.0, 1.0),
                          max: 1.0,
                          onChanged: (value) {
                            final position = duration * value;
                            widget.controller.seekTo(position);
                          },
                          activeColor: primaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                _formatDuration(duration),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            // 控制按钮
            StreamBuilder<PlayerState>(
              stream: widget.controller.playerStateStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data?.playing ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 32,
                      onPressed: null,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 32,
                        color: Colors.white,
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 32,
                      onPressed: null,
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
