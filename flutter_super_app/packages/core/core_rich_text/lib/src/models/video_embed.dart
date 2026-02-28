import 'package:flutter_quill/flutter_quill.dart';

/// 视频嵌入块类型常量
const String videoEmbedType = 'video';

/// 视频嵌入块
///
/// 用于在 Quill 编辑器中嵌入视频内容
/// 继承自 Embeddable，使用标准的数据存储格式
class VideoEmbed extends Embeddable {
  /// 创建视频嵌入块
  ///
  /// [videoUrl] 视频 URL（本地路径或网络地址）
  const VideoEmbed({required String videoUrl})
      : super(videoEmbedType, videoUrl);

  /// 获取视频 URL
  String get videoUrl {
    // Embeddable 的 data 属性存储的就是视频 URL
    return data as String;
  }

  /// 从字符串创建 VideoEmbed
  static VideoEmbed fromString(String videoUrl) {
    return VideoEmbed(videoUrl: videoUrl);
  }

  /// 从 JSON 创建
  /// JSON 格式: {"video": "https://example.com/video.mp4"}
  static VideoEmbed fromJson(Map<String, dynamic> json) {
    final url = json[videoEmbedType] as String;
    return VideoEmbed(videoUrl: url);
  }

  @override
  /// 转换为 JSON
  /// 返回格式: {"video": "https://example.com/video.mp4"}
  Map<String, dynamic> toJson() {
    return {videoEmbedType: videoUrl};
  }
}
