import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'media_picker.dart' show MediaType;

/// 媒体选择结果
class WechatMediaPickerResult {
  final File file;
  final String path;
  final MediaType type;
  final int? fileSize;
  final String? fileName;
  final List<int>? thumbnail;

  const WechatMediaPickerResult({
    required this.file,
    required this.path,
    required this.type,
    this.fileSize,
    this.fileName,
    this.thumbnail,
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
    return 'WechatMediaPickerResult(type: $type, path: $path, size: $formattedSize)';
  }
}

/// 微信风格媒体选择器
///
/// 基于 wechat_assets_picker 封装
/// 提供更友好的 API 和统一的结果格式
class WechatAssetPickerWrapper {
  /// 单例
  static final WechatAssetPickerWrapper _instance =
      WechatAssetPickerWrapper._internal();
  factory WechatAssetPickerWrapper() => _instance;
  WechatAssetPickerWrapper._internal();

  /// 从相册选择图片
  ///
  /// [context] 上下文
  /// [maxCount] 最大选择数量，默认 1
  Future<List<WechatMediaPickerResult>> pickImages(
    BuildContext context, {
    int maxCount = 1,
  }) async {
    return _pickAssets(
      context,
      requestType: RequestType.image,
      maxCount: maxCount,
      expectedType: MediaType.image,
    );
  }

  /// 从相册选择视频
  ///
  /// [context] 上下文
  /// [maxCount] 最大选择数量，默认 1
  Future<List<WechatMediaPickerResult>> pickVideos(
    BuildContext context, {
    int maxCount = 1,
  }) async {
    return _pickAssets(
      context,
      requestType: RequestType.video,
      maxCount: maxCount,
      expectedType: MediaType.video,
    );
  }

  /// 从相册选择图片或视频
  ///
  /// [context] 上下文
  /// [maxCount] 最大选择数量，默认 1
  Future<List<WechatMediaPickerResult>> pickMedia(
    BuildContext context, {
    int maxCount = 1,
  }) async {
    return _pickAssets(
      context,
      requestType: RequestType.common,
      maxCount: maxCount,
      expectedType: null, // 不限制类型
    );
  }

  /// 拍照
  ///
  /// [context] 上下文
  Future<WechatMediaPickerResult?> pickImageFromCamera(
    BuildContext context,
  ) async {
    // 请求相机权限
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint('相机权限未授予');
      return null;
    }

    try {
      final AssetEntity? entity = await Navigator.of(context).push<AssetEntity>(
        MaterialPageRoute(
          builder: (context) => const CameraPicker(
            pickerConfig: CameraPickerConfig(
              enableAudio: false,
            ),
          ),
        ),
      );

      if (entity == null) return null;

      return await _entityToResult(entity);
    } catch (e) {
      debugPrint('拍照失败: $e');
      return null;
    }
  }

  /// 录制视频
  ///
  /// [context] 上下文
  /// [maxDuration] 最长录制时长
  Future<WechatMediaPickerResult?> pickVideoFromCamera(
    BuildContext context, {
    Duration? maxDuration,
  }) async {
    // 请求相机和麦克风权限
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
      debugPrint('相机或麦克风权限未授予');
      return null;
    }

    try {
      final AssetEntity? entity = await Navigator.of(context).push<AssetEntity>(
        MaterialPageRoute(
          builder: (context) => CameraPicker(
            pickerConfig: CameraPickerConfig(
              enableAudio: true,
              maximumRecordingDuration: maxDuration,
            ),
          ),
        ),
      );

      if (entity == null) return null;

      return await _entityToResult(entity);
    } catch (e) {
      debugPrint('录制视频失败: $e');
      return null;
    }
  }

  /// 通用资源选择方法
  Future<List<WechatMediaPickerResult>> _pickAssets(
    BuildContext context, {
    required RequestType requestType,
    required int maxCount,
    MediaType? expectedType,
  }) async {
    try {
      final List<AssetEntity>? entities = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: maxCount,
          requestType: requestType,
          filterOptions: FilterOptionGroup(
            imageOption: const FilterOption(
              sizeConstraint: SizeConstraint(ignoreSize: true),
            ),
            videoOption: const FilterOption(
              durationConstraint: DurationConstraint(
                min: Duration.zero,
                max: Duration(minutes: 10), // 限制最长10分钟
              ),
            ),
          ),
        ),
      );

      if (entities == null || entities.isEmpty) return [];

      final results = <WechatMediaPickerResult>[];

      for (final entity in entities) {
        final result = await _entityToResult(entity);
        if (result != null) {
          // 如果指定了期望类型，进行过滤
          if (expectedType == null || result.type == expectedType) {
            results.add(result);
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('选择资源失败: $e');
      return [];
    }
  }

  /// 将 AssetEntity 转换为 WechatMediaPickerResult
  Future<WechatMediaPickerResult?> _entityToResult(
    AssetEntity entity,
  ) async {
    try {
      // 获取文件
      final file = await entity.file;
      if (file == null) return null;

      // 获取缩略图
      final thumbnailData =
          entity.type == AssetType.image ? await entity.thumbnailData : null;

      // 获取文件信息
      final title = entity.title;
      final size = await file.length();

      // 确定媒体类型
      final type = entity.type == AssetType.video
          ? MediaType.video
          : MediaType.image;

      return WechatMediaPickerResult(
        file: file,
        path: file.path,
        type: type,
        fileSize: size,
        fileName: title,
        thumbnail: thumbnailData,
      );
    } catch (e) {
      debugPrint('转换资源失败: $e');
      return null;
    }
  }
}
