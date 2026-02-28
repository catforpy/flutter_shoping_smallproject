import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:core_media/core_media.dart';
import 'package:core_rich_text/core_rich_text.dart';
import 'package:service_content/service_content.dart';

/// 笔记编辑器页面
///
/// ## 功能特性
/// - 顶部导航栏：关闭按钮、标题"记笔记"、发布按钮
/// - 中间区域：富文本编辑器
/// - 底部工具栏：格式化工具 + 公开开关
///
/// ## 使用示例
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => const NoteEditorPage(),
///   ),
/// );
/// ```
class NoteEditorPage extends StatefulWidget {
  /// 笔记ID（可选，用于编辑已有笔记）
  final String? noteId;

  /// 初始内容（Delta格式JSON字符串）
  final String? initialContent;

  const NoteEditorPage({
    super.key,
    this.noteId,
    this.initialContent,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  /// Quill控制器
  late final QuillController _controller;

  /// 是否公开
  bool _isPublic = false;

  /// 焦点节点
  final FocusNode _focusNode = FocusNode();

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  /// 工具栏展开状态
  bool _isToolbarExpanded = false;

  /// 上传服务
  final FileUploadService _uploadService = FileUploadService();

  /// 文档是否有内容（缓存状态，避免频繁计算）
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _initController();

    // 延迟请求焦点，避免键盘弹出时卡顿
    // 等待第一帧渲染完成后再请求焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  /// 初始化控制器
  void _initController() {
    // 如果有初始内容，加载它
    if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
      try {
        final json = jsonDecode(widget.initialContent!);
        _controller = QuillController(
          document: Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // 如果解析失败，创建空文档
        _controller = QuillController.basic();
      }
    } else {
      // 创建空控制器
      _controller = QuillController.basic();
    }

    // 监听文本变化
    _controller.addListener(() {
      // 只在文档内容状态变化时更新（有内容 vs 无内容）
      final hasContent = _controller.document.length > 1;
      if (hasContent != _hasContent) {
        setState(() {
          _hasContent = hasContent;
        });
      }
    });

    // 初始化 _hasContent 状态
    _hasContent = _controller.document.length > 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 关闭页面（不保存）
  void _handleClose() {
    // 检查是否有未保存的更改
    if (_controller.document.length > 1) {
      _showCloseConfirmDialog();
    } else {
      Navigator.pop(context);
    }
  }

  /// 显示关闭确认对话框
  void _showCloseConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('放弃编辑？'),
        content: const Text('您有未保存的笔记内容，确定要离开吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 关闭编辑器
            },
            child: const Text('放弃'),
          ),
        ],
      ),
    );
  }

  /// 发布笔记
  void _handlePublish() async {
    // 检查内容是否为空
    if (_controller.document.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入笔记内容')),
      );
      return;
    }

    // 获取内容（Delta格式JSON）
    final deltaJson = _controller.document.toDelta().toJson();
    final jsonString = jsonEncode(deltaJson);

    // 提取图片和视频路径
    final mediaUrls = _extractMediaUrls(deltaJson);

    // ========== 打印发送给后端的数据 ==========
    debugPrint('\n========================================');
    debugPrint('📤 发布笔记 - 发送给后端的数据');
    debugPrint('========================================');
    debugPrint('内容类型: note');
    debugPrint('是否公开: ${_isPublic ? '公开' : '私有'}');
    debugPrint('Delta JSON 长度: ${jsonString.length} 字符');

    final images = mediaUrls['images'] ?? [];
    final videos = mediaUrls['videos'] ?? [];

    debugPrint('\n📸 图片数量: ${images.length}');
    if (images.isNotEmpty) {
      for (var i = 0; i < images.length; i++) {
        debugPrint('  图片 ${i + 1}: ${images[i]}');
      }
    }
    debugPrint('\n🎬 视频数量: ${videos.length}');
    if (videos.isNotEmpty) {
      for (var i = 0; i < videos.length; i++) {
        debugPrint('  视频 ${i + 1}: ${videos[i]}');
      }
    }
    debugPrint('\n📝 完整 Delta JSON:');
    debugPrint(jsonString);
    debugPrint('========================================\n');

    // ========== 保存到数据库（模拟） ==========
    await _saveToDatabase(jsonString, mediaUrls);

    // 显示成功提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPublic ? '✅ 已发布公开笔记' : '✅ 已保存私有笔记',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // 延迟返回，让用户看到反馈
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        // 返回 JSON 数据给上一级页面
        Navigator.pop(context, jsonString);
      }
    });
  }

  /// 从 Delta JSON 中提取图片和视频 URL
  Map<String, List<String>> _extractMediaUrls(List<dynamic> deltaJson) {
    final images = <String>[];
    final videos = <String>[];

    for (var op in deltaJson) {
      if (op is Map && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is Map) {
          // 检查图片
          if (insert.containsKey('image')) {
            final imageUrl = insert['image'];
            if (imageUrl is String) {
              images.add(imageUrl);
            }
          }
          // 检查视频
          if (insert.containsKey('video')) {
            final videoUrl = insert['video'];
            if (videoUrl is String) {
              videos.add(videoUrl);
            }
          }
        }
      }
    }

    return {'images': images, 'videos': videos};
  }

  /// 保存到数据库（模拟实现）
  Future<void> _saveToDatabase(
    String contentJson,
    Map<String, List<String>> mediaUrls,
  ) async {
    // TODO: 实际项目中应该调用真实的数据库服务
    // 这里模拟数据库保存

    debugPrint('\n========================================');
    debugPrint('💾 保存到数据库');
    debugPrint('========================================');

    // 模拟数据库记录
    final noteRecord = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': 'note',
      'content': contentJson,
      'is_public': _isPublic,
      'images': mediaUrls['images'] ?? [],
      'videos': mediaUrls['videos'] ?? [],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final images = noteRecord['images'] as List;
    final videos = noteRecord['videos'] as List;

    debugPrint('📊 数据库记录:');
    debugPrint('  ID: ${noteRecord['id']}');
    debugPrint('  类型: ${noteRecord['type']}');
    debugPrint('  公开: ${noteRecord['is_public']}');
    debugPrint('  图片: ${images.length} 张');
    debugPrint('  视频: ${videos.length} 个');
    debugPrint('  创建时间: ${noteRecord['created_at']}');

    debugPrint('\n💡 提示: 实际项目中，这里应该调用：');
    debugPrint('  await noteService.createNote(noteRecord);');
    debugPrint('  或者');
    debugPrint('  await contentService.createContent(...)');
    debugPrint('========================================\n');

    // 模拟异步保存
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          return Column(
            children: [
              // 编辑器区域
              Expanded(
                child: RepaintBoundary(
                  child: _buildEditor(),
                ),
              ),
              // 底部工具栏（键盘弹出时会自动顶到键盘上方）
              RepaintBoundary(
                child: _buildBottomToolbar(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _handleClose,
        tooltip: '关闭',
      ),
      title: const Text('记笔记'),
      actions: [
        // 发布按钮
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton.icon(
            onPressed: _hasContent ? _handlePublish : null,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('发布'),
            style: TextButton.styleFrom(
              foregroundColor: _hasContent
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建编辑器
  Widget _buildEditor() {
    // 使用 QuillEditor.basic() + 自定义 embedBuilders
    return RepaintBoundary(
      child: QuillEditor.basic(
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        config: QuillEditorConfig(
          placeholder: '开始输入您的笔记...',
          scrollable: true,
          autoFocus: false,
          minHeight: 300,
          maxHeight: double.infinity,
          padding: EdgeInsets.zero,
          // 添加嵌入块构建器（支持图片和视频）
          embedBuilders: [
            // 使用 flutter_quill_extensions 提供的默认构建器（支持图片）
            ...FlutterQuillEmbeds.editorBuilders(),
            // 自定义视频嵌入构建器
            VideoEmbedBuilder(),
          ],
        ),
      ),
    );
  }

  /// 构建底部工具栏
  Widget _buildBottomToolbar() {
    // 使用 RepaintBoundary 隔离重绘，避免键盘弹出时重建
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          // 点击空白处收起工具栏
          if (_isToolbarExpanded) {
            setState(() {
              _isToolbarExpanded = false;
            });
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 工具栏区域（展开时显示）
                if (_isToolbarExpanded)
                  _buildQuillToolbar(),
                // 底部按钮行
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // A 按钮（格式化工具）
                      _buildToolbarToggleButton(),
                      const SizedBox(width: 12),
                      // 图片按钮
                      _buildImageButton(),
                      const SizedBox(width: 12),
                      // 视频按钮
                      _buildVideoButton(),
                      const Spacer(),
                      // 公开开关
                      _buildPublicToggle(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建工具栏展开/收起按钮
  Widget _buildToolbarToggleButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isToolbarExpanded = !_isToolbarExpanded;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isToolbarExpanded ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'A',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isToolbarExpanded ? Colors.blue : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建Quill工具栏
  Widget _buildQuillToolbar() {
    return RepaintBoundary(
      child: QuillSimpleToolbar(
      controller: _controller,
      config: const QuillSimpleToolbarConfig(
        // 显示的按钮组
        showDividers: true,
        showAlignmentButtons: false,
        showBackgroundColorButton: false,
        showClearFormat: false,
        showCodeBlock: true,
        showDirection: false,
        showFontFamily: false,
        showFontSize: false,
        showHeaderStyle: true,
        showIndent: false,
        showInlineCode: true,
        showLink: true,
        showListBullets: true,
        showListNumbers: true,
        showListCheck: true,
        showQuote: true,
        showSearchButton: false,
        showRedo: true,
        showUndo: true,
        showSubscript: false,
        showSuperscript: false,
      ),
      ),
    );
  }

  /// 构建公开开关
  Widget _buildPublicToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isPublic ? Icons.public : Icons.lock,
          size: 18,
          color: _isPublic ? Colors.green : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          _isPublic ? '公开' : '私有',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: _isPublic,
          onChanged: (value) {
            setState(() {
              _isPublic = value;
            });
          },
          activeColor: Colors.green,
        ),
      ],
    );
  }

  /// 构建图片按钮
  Widget _buildImageButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image,
          size: 20,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// 构建视频按钮
  Widget _buildVideoButton() {
    return GestureDetector(
      onTap: _showVideoSourceDialog,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.videocam,
          size: 20,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// 显示图片来源选择对话框
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图片来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('输入图片链接'),
              onTap: () {
                Navigator.pop(context);
                _showImageUrlDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示视频来源选择对话框
  void _showVideoSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择视频来源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('录制视频'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('输入视频链接'),
              onTap: () {
                Navigator.pop(context);
                _showVideoUrlDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 从相册选择图片
  Future<void> _pickImageFromGallery() async {
    try {
      final picker = WechatAssetPickerWrapper();
      final results = await picker.pickImages(
        context,
        maxCount: 1,
      );

      if (!mounted) return;

      if (results.isNotEmpty) {
        final result = results.first;
        // 上传图片并插入
        await _uploadAndInsertMedia(result.path, 'image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  /// 拍照
  Future<void> _pickImageFromCamera() async {
    try {
      final picker = WechatAssetPickerWrapper();
      final result = await picker.pickImageFromCamera(context);

      if (!mounted) return;

      if (result != null) {
        // 上传图片并插入
        await _uploadAndInsertMedia(result.path, 'image');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  /// 显示图片URL输入对话框
  void _showImageUrlDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入图片链接'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // 使用 document.insert() 插入图片
                final index = _controller.selection.extentOffset;
                _controller.document.insert(
                  index,
                  Embeddable('image', controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('插入'),
          ),
        ],
      ),
    );
  }

  /// 显示视频URL输入对话框
  void _showVideoUrlDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入视频链接'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/video.mp4',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // 使用 document.insert() 插入视频
                final index = _controller.selection.extentOffset;
                _controller.document.insert(
                  index,
                  VideoEmbed(videoUrl: controller.text),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('插入'),
          ),
        ],
      ),
    );
  }

  /// 从相册选择视频
  Future<void> _pickVideoFromGallery() async {
    try {
      final picker = WechatAssetPickerWrapper();
      final results = await picker.pickVideos(
        context,
        maxCount: 1,
      );

      if (!mounted) return;

      if (results.isNotEmpty) {
        final result = results.first;
        // 上传视频并插入
        await _uploadAndInsertMedia(result.path, 'video');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择视频失败: $e')),
        );
      }
    }
  }

  /// 录制视频
  Future<void> _pickVideoFromCamera() async {
    try {
      final picker = WechatAssetPickerWrapper();
      final result = await picker.pickVideoFromCamera(
        context,
        maxDuration: const Duration(minutes: 10),
      );

      if (!mounted) return;

      if (result != null) {
        // 上传视频并插入
        await _uploadAndInsertMedia(result.path, 'video');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录制视频失败: $e')),
        );
      }
    }
  }

  /// 上传媒体文件并插入到编辑器
  ///
  /// [filePath] 本地文件路径
  /// [mediaType] 媒体类型 ('image' 或 'video')
  Future<void> _uploadAndInsertMedia(
    String filePath,
    String mediaType,
  ) async {
    // 打印本地文件信息
    debugPrint('\n========== 媒体文件选择 ==========');
    debugPrint('本地文件路径: $filePath');
    debugPrint('媒体类型: $mediaType');
    debugPrint('准备上传到 OSS...');
    debugPrint('==================================\n');

    // 显示上传进度对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UploadProgressDialog(
        filePath: filePath,
        mediaType: mediaType,
        uploadService: _uploadService,
        onUploadComplete: (url) {
          // 上传成功，插入到编辑器
          if (mounted) {
            debugPrint('\n========== 插入到编辑器 ==========');
            debugPrint('插入内容: {$mediaType: "$url"}');
            debugPrint('==================================\n');

            // 根据媒体类型使用不同的插入方法
            if (mediaType == 'image') {
              // 使用 document.insert() 方法插入图片
              // 对于图片，flutter_quill 内置了支持
              final index = _controller.selection.extentOffset;
              _controller.document.insert(
                index,
                Embeddable('image', url),
              );
            } else if (mediaType == 'video') {
              // 使用 document.insert() 方法插入视频
              final index = _controller.selection.extentOffset;
              _controller.document.insert(
                index,
                VideoEmbed(videoUrl: url),
              );
            }
          }
        },
      ),
    );
  }
}
