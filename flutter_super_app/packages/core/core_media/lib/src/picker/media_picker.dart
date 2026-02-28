import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// 媒体类型枚举
enum MediaType {
  image,
  video,
}

/// 媒体选择结果
class MediaPickerResult {
  final File file;
  final String path;
  final MediaType type;
  final int? fileSize;
  final String? fileName;

  const MediaPickerResult({
    required this.file,
    required this.path,
    required this.type,
    this.fileSize,
    this.fileName,
  });

  /// 文件大小（格式化）
  String get formattedSize {
    if (fileSize == null) return '未知';
    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  String toString() {
    return 'MediaPickerResult(type: $type, path: $path, size: $formattedSize)';
  }
}

/// 媒体选择器
class AppMediaPicker {
  final ImagePicker _picker = ImagePicker();

  /// 单例
  static final AppMediaPicker _instance = AppMediaPicker._internal();
  factory AppMediaPicker() => _instance;
  AppMediaPicker._internal();

  /// 从相册选择图片
  ///
  /// [maxWidth] 最大宽度（压缩）
  /// [maxHeight] 最大高度（压缩）
  /// [imageQuality] 图片质量 0-100
  Future<MediaPickerResult?> pickImageFromGallery({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileSize = await file.length();

      return MediaPickerResult(
        file: file,
        path: pickedFile.path,
        type: MediaType.image,
        fileSize: fileSize,
        fileName: pickedFile.name,
      );
    } catch (e) {
      debugPrint('选择图片失败: $e');
      return null;
    }
  }

  /// 拍照
  ///
  /// [maxWidth] 最大宽度（压缩）
  /// [maxHeight] 最大高度（压缩）
  /// [imageQuality] 图片质量 0-100
  /// [preferFrontCamera] 优先使用前置摄像头
  Future<MediaPickerResult?> pickImageFromCamera({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 100,
    bool preferFrontCamera = false,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice:
            preferFrontCamera ? CameraDevice.front : CameraDevice.rear,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileSize = await file.length();

      return MediaPickerResult(
        file: file,
        path: pickedFile.path,
        type: MediaType.image,
        fileSize: fileSize,
        fileName: pickedFile.name,
      );
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 从相册选择视频
  Future<MediaPickerResult?> pickVideoFromGallery() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileSize = await file.length();

      return MediaPickerResult(
        file: file,
        path: pickedFile.path,
        type: MediaType.video,
        fileSize: fileSize,
        fileName: pickedFile.name,
      );
    } catch (e) {
      debugPrint('选择视频失败: $e');
      return null;
    }
  }

  /// 录制视频
  Future<MediaPickerResult?> pickVideoFromCamera() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.camera);

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileSize = await file.length();

      return MediaPickerResult(
        file: file,
        path: pickedFile.path,
        type: MediaType.video,
        fileSize: fileSize,
        fileName: pickedFile.name,
      );
    } catch (e) {
      debugPrint('录制视频失败: $e');
      return null;
    }
  }

  /// 多选图片
  ///
  /// 限制 Android/iOS 平台可用
  Future<List<MediaPickerResult>> pickMultipleImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();

      final results = <MediaPickerResult>[];

      for (final pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        results.add(MediaPickerResult(
          file: file,
          path: pickedFile.path,
          type: MediaType.image,
          fileSize: fileSize,
          fileName: pickedFile.name,
        ));
      }

      return results;
    } catch (e) {
      debugPrint('多选图片失败: $e');
      return [];
    }
  }

  /// 从媒体源选择（图片或视频）
  Future<MediaPickerResult?> pickMedia({
    bool allowPhoto = true,
    bool allowVideo = false,
  }) async {
    try {
      // 注意: pickMedia 需要 image_picker 1.1.0+ 版本
      // 如果不支持则回退到 pickImage
      final pickedFile = await _picker.pickMedia();

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      final fileSize = await file.length();

      // 根据 MIME 类型或扩展名判断类型
      final type = _getMediaTypeFromFile(pickedFile.path);

      return MediaPickerResult(
        file: file,
        path: pickedFile.path,
        type: type,
        fileSize: fileSize,
        fileName: pickedFile.name,
      );
    } catch (e) {
      debugPrint('选择媒体失败: $e');
      return null;
    }
  }

  MediaType _getMediaTypeFromFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    final videoExts = ['mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv'];
    return videoExts.contains(ext) ? MediaType.video : MediaType.image;
  }
}
