import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/video_embed.dart';

/// 视频嵌入构建器
///
/// 负责在 Quill 编辑器中渲染视频嵌入块
class VideoEmbedBuilder extends EmbedBuilder {
  @override
  String get key => videoEmbedType;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final videoUrl = embedContext.node.value.data as String;

    return GestureDetector(
      onTap: () {
        // 点击视频时的回调（可以打开视频播放器）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('点击播放视频: $videoUrl')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  '视频',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  videoUrl,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
