import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// 媒体工具类
final class MediaUtils {
  MediaUtils._();

  /// 获取图片类型
  static String getImageType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'jpeg';
      case '.png':
        return 'png';
      case '.gif':
        return 'gif';
      case '.webp':
        return 'webp';
      case '.bmp':
        return 'bmp';
      default:
        return 'unknown';
    }
  }

  /// 判断是否为图片文件
  static bool isImageFile(String filePath) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final extension = path.extension(filePath).toLowerCase();
    return imageExtensions.contains(extension);
  }

  /// 判断是否为视频文件
  static bool isVideoFile(String filePath) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv'];
    final extension = path.extension(filePath).toLowerCase();
    return videoExtensions.contains(extension);
  }

  /// 判断是否为音频文件
  static bool isAudioFile(String filePath) {
    final audioExtensions = ['.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a'];
    final extension = path.extension(filePath).toLowerCase();
    return audioExtensions.contains(extension);
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// 获取文件名
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// 获取文件扩展名
  static String getFileExtension(String filePath) {
    return path.extension(filePath).replaceFirst('.', '');
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// 获取文件大小
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// 删除文件
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 从文件路径获取文件
  static File getFile(String filePath) {
    return File(filePath);
  }

  /// 从字节数据创建临时文件
  static Future<File> createTempFile(
    String fileName,
    Uint8List bytes, {
    String? tempDir,
  }) async {
    final directory = tempDir != null ? Directory(tempDir) : Directory.systemTemp;
    final filePath = path.join(directory.path, 'temp_${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final file = File(filePath);
    return await file.writeAsBytes(bytes);
  }

  /// Base64 编码
  static String base64Encode(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// 计算图片宽高比
  static double calculateAspectRatio(int width, int height) {
    if (height == 0) return 1.0;
    return width / height;
  }

  /// 根据宽高比调整尺寸
  static Size adjustSizeByAspectRatio(
    double targetWidth,
    double aspectRatio,
  ) {
    final height = targetWidth / aspectRatio;
    return Size(targetWidth, height);
  }
}

/// 图片尺寸信息
final class ImageSize {
  final int width;
  final int height;
  final double aspectRatio;

  const ImageSize({
    required this.width,
    required this.height,
  }) : aspectRatio = height != 0 ? width / height : 1.0;

  @override
  String toString() =>
      'ImageSize(width: $width, height: $height, aspectRatio: $aspectRatio)';
}

/// 媒体信息
final class MediaInfo {
  final String path;
  final String name;
  final String type;
  final int size;
  final int? width;
  final int? height;
  final DateTime createdAt;

  const MediaInfo({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    this.width,
    this.height,
    required this.createdAt,
  });

  /// 是否为图片
  bool get isImage => MediaUtils.isImageFile(path);

  /// 是否为视频
  bool get isVideo => MediaUtils.isVideoFile(path);

  /// 是否为音频
  bool get isAudio => MediaUtils.isAudioFile(path);

  /// 格式化的文件大小
  String get formattedSize => MediaUtils.formatFileSize(size);

  /// 图片尺寸信息
  ImageSize? get imageSize {
    if (width != null && height != null) {
      return ImageSize(width: width!, height: height!);
    }
    return null;
  }

  @override
  String toString() =>
      'MediaInfo(name: $name, type: $type, size: $formattedSize)';
}
