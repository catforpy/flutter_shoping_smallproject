import 'dart:io';
import 'package:flutter/material.dart';
import 'package:core_file_cache/core_file_cache.dart';

/// 文件缓存测试页面
class FileCacheTestPage extends StatefulWidget {
  const FileCacheTestPage({super.key});

  @override
  State<FileCacheTestPage> createState() => _FileCacheTestPageState();
}

class _FileCacheTestPageState extends State<FileCacheTestPage> {
  String _status = '等待测试...';
  String _cacheSize = '0 B';
  File? _cachedFile;
  bool _isLoading = false;

  // 测试用的图片 URL
  final String _testImageUrl =
      'https://picsum.photos/800/600.jpg';

  @override
  void initState() {
    super.initState();
    _updateCacheSize();
  }

  /// 更新缓存大小显示
  Future<void> _updateCacheSize() async {
    final size = await FileCacheManager.getCacheSize();
    setState(() {
      _cacheSize = FileCacheManager.formatCacheSize(size);
    });
  }

  /// 测试下载并缓存文件
  Future<void> _testDownloadAndCache() async {
    setState(() {
      _isLoading = true;
      _status = '开始下载...';
    });

    try {
      final file = await FileCacheManager.get(
        _testImageUrl,
        type: FileType.image,
        onProgress: (received, total) {
          final progress = ((received / total) * 100).toStringAsFixed(1);
          setState(() {
            _status = '下载中: $progress%';
          });
        },
      );

      setState(() {
        _cachedFile = file;
        _status = '✅ 下载成功！\n路径: ${file.path}';
        _isLoading = false;
      });

      await _updateCacheSize();
    } catch (e) {
      setState(() {
        _status = '❌ 下载失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 测试从缓存获取
  Future<void> _testGetFromCache() async {
    setState(() {
      _isLoading = true;
      _status = '从缓存获取...';
    });

    try {
      final file = await FileCacheManager.get(
        _testImageUrl,
        type: FileType.image,
      );

      setState(() {
        _cachedFile = file;
        _status = '✅ 缓存命中！\n路径: ${file.path}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ 获取失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 清除当前文件缓存
  Future<void> _testRemoveFile() async {
    await FileCacheManager.remove(_testImageUrl);
    setState(() {
      _cachedFile = null;
      _status = '✅ 已清除文件缓存';
    });
    await _updateCacheSize();
  }

  /// 清除所有缓存
  Future<void> _testClearAll() async {
    await FileCacheManager.clearAll();
    setState(() {
      _cachedFile = null;
      _status = '✅ 已清除所有缓存';
    });
    await _updateCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件缓存测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 缓存大小卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '当前缓存大小:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      _cacheSize,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 状态显示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 缓存的图片
            if (_cachedFile != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '缓存的图片:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Image.file(_cachedFile!),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // 测试按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _testDownloadAndCache,
              child: const Text('下载并缓存图片'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testGetFromCache,
              child: const Text('从缓存获取（测试第二次加载）'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testRemoveFile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('清除当前文件缓存'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testClearAll,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('清除所有缓存'),
            ),
          ],
        ),
      ),
    );
  }
}
