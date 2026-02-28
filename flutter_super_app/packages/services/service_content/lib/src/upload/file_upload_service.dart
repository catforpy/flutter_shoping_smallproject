import 'dart:io';
import 'package:flutter/foundation.dart';

/// 上传结果
class UploadResult {
  final String url;
  final String fileName;
  final int fileSize;
  final String fileType; // 'image' 或 'video'

  const UploadResult({
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });

  @override
  String toString() {
    return 'UploadResult(url: $url, fileName: $fileName, size: $fileSize, type: $fileType)';
  }
}

/// 文件上传服务
///
/// 负责将本地文件上传到 OSS（对象存储）
/// 支持图片和视频的上传
class FileUploadService {
  /// 单例
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  /// OSS 配置
  // TODO: 从后端或配置文件获取
  static const String _ossBaseUrl = 'https://your-cdn-domain.com';
  static const String _uploadEndpoint = 'https://api.example.com/upload';

  /// 上传单个文件
  ///
  /// [file] 要上传的文件
  /// [fileType] 文件类型 ('image' 或 'video')
  /// [onProgress] 上传进度回调 (0.0 - 1.0)
  Future<UploadResult?> uploadFile(
    File file, {
    required String fileType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      debugPrint('========== 文件上传开始 ==========');
      debugPrint('本地文件路径: ${file.path}');

      // 生成唯一文件名
      final fileName = _generateFileName(file.path);
      final fileExtension = _getFileExtension(file.path);
      final fileSize = await file.length();

      debugPrint('文件名: $fileName.$fileExtension');
      debugPrint('文件大小: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)');
      debugPrint('文件类型: $fileType');

      // 开发模式：直接返回本地文件路径，方便测试
      // TODO: 等后端 OSS 准备好后，改为真实上传并返回网络 URL
      final useLocalPath = true; // 设为 false 启用真实上传

      String url;

      if (useLocalPath) {
        // 开发模式：直接使用本地路径
        url = file.path;
        debugPrint('🔧 开发模式：使用本地文件路径');
        debugPrint('本地路径: $url');
      } else {
        // 生产模式：模拟上传过程
        debugPrint('📤 正在上传到 OSS: http://oss.example.com/$fileType/$fileName.$fileExtension');

        // 模拟上传进度
        onProgress?.call(0.3);
        await Future.delayed(const Duration(milliseconds: 300));
        debugPrint('上传进度: 30%');

        onProgress?.call(0.6);
        await Future.delayed(const Duration(milliseconds: 300));
        debugPrint('上传进度: 60%');

        onProgress?.call(1.0);
        await Future.delayed(const Duration(milliseconds: 400));
        debugPrint('上传进度: 100%');

        // 生成模拟的 CDN URL
        url = 'http://oss.example.com/$fileType/$fileName.$fileExtension';
      }

      debugPrint('✅ 上传成功！');
      debugPrint('文件 URL: $url');
      debugPrint('========== 文件上传结束 ==========');

      return UploadResult(
        url: url,
        fileName: '$fileName.$fileExtension',
        fileSize: fileSize,
        fileType: fileType,
      );
    } catch (e) {
      debugPrint('❌ 文件上传失败: $e');
      return null;
    }
  }

  /// 批量上传文件
  ///
  /// [files] 要上传的文件列表
  /// [fileType] 文件类型
  /// [onProgress] 总体进度回调
  Future<List<UploadResult>> uploadFiles(
    List<File> files, {
    required String fileType,
    void Function(double progress, int completed, int total)? onProgress,
  }) async {
    final results = <UploadResult>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];

      final result = await uploadFile(
        file,
        fileType: fileType,
        onProgress: (fileProgress) {
          // 计算总体进度
          final totalProgress = ((i + fileProgress) / files.length);
          onProgress?.call(totalProgress, i, files.length);
        },
      );

      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  /// 从文件路径上传
  Future<UploadResult?> uploadFileFromPath(
    String filePath, {
    required String fileType,
    void Function(double progress)? onProgress,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint('文件不存在: $filePath');
      return null;
    }
    return uploadFile(
      file,
      fileType: fileType,
      onProgress: onProgress,
    );
  }

  /// 生成唯一文件名
  String _generateFileName(String filePath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'file_$timestamp-$random';
  }

  /// 获取文件扩展名
  String _getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// 压缩图片（可选）
  ///
  /// 在上传前压缩图片以减少带宽和存储成本
  // Future<File?> compressImage(File file, {int quality = 80}) async {
  //   // 使用 flutter_image_compress 包
  //   // TODO: 实现图片压缩
  //   return file;
  // }
}

/// 文件上传进度状态
class UploadProgress {
  final double progress; // 0.0 - 1.0
  final int completed;
  final int total;
  final String? currentFileName;

  const UploadProgress({
    required this.progress,
    required this.completed,
    required this.total,
    this.currentFileName,
  });

  @override
  String toString() {
    final percentage = (progress * 100).toStringAsFixed(1);
    return '上传进度: $percentage% ($completed/$total)';
  }
}
