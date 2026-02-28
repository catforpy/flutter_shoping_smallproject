import 'package:flutter/material.dart';
import 'package:service_content/service_content.dart';

/// 上传进度对话框
///
/// 显示文件上传进度，支持图片和视频上传
class UploadProgressDialog extends StatefulWidget {
  /// 本地文件路径
  final String filePath;

  /// 媒体类型 ('image' 或 'video')
  final String mediaType;

  /// 上传服务
  final FileUploadService uploadService;

  /// 上传完成回调
  final Function(String url) onUploadComplete;

  const UploadProgressDialog({
    super.key,
    required this.filePath,
    required this.mediaType,
    required this.uploadService,
    required this.onUploadComplete,
  });

  @override
  State<UploadProgressDialog> createState() => _UploadProgressDialogState();
}

class _UploadProgressDialogState extends State<UploadProgressDialog> {
  double _progress = 0.0;
  bool _isUploading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startUpload();
  }

  Future<void> _startUpload() async {
    final result = await widget.uploadService.uploadFileFromPath(
      widget.filePath,
      fileType: widget.mediaType,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      },
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _isUploading = false;
      });

      // 延迟一下让用户看到 100%
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        widget.onUploadComplete(result.url);
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _isUploading = false;
        _error = '上传失败，请重试';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaTypeName = widget.mediaType == 'image' ? '图片' : '视频';

    return AlertDialog(
      title: Text('上传$mediaTypeName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUploading) ...[
            const SizedBox(height: 20),
            CircularProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            Text('上传中... ${(_progress * 100).toStringAsFixed(0)}%'),
          ],
          if (_error != null) ...[
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!),
          ],
        ],
      ),
      actions: [
        if (_error != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
      ],
    );
  }
}
