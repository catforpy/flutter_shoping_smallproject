import 'package:flutter/material.dart';

/// 课程下载页面
///
/// 用于选择要下载的课程章节
class CourseDownloadPage extends StatefulWidget {
  const CourseDownloadPage({super.key});

  @override
  State<CourseDownloadPage> createState() => _CourseDownloadPageState();
}

class _CourseDownloadPageState extends State<CourseDownloadPage> {
  /// 章节数据
  final List<Map<String, dynamic>> _chapters = [
    {
      'title': '第1章 揭开AI产品经理黄金赛道',
      'lessons': [
        {'number': '1-1', 'title': '课程介绍', 'size': '12.8 MB', 'duration': '03分28秒'},
        {'number': '1-2', 'title': '建立正确的产品观：产品经理岗位起源', 'size': '20.1 MB', 'duration': '05分45秒'},
        {'number': '1-3', 'title': 'AI产品经理：需求快速增长的新兴岗位', 'size': '20.3 MB', 'duration': '05分50秒'},
        {'number': '1-4', 'title': 'AI产品经理工作流程与岗位能力模型', 'size': '23.3 MB', 'duration': '05分54秒'},
        {'number': '1-5', 'title': '产品思维的层层迷雾：不写代码就是纯净水？', 'size': '23.4 MB', 'duration': '06分29秒'},
      ],
    },
    {
      'title': '第2章 如何拥抱AI：AI产品职业切入方式',
      'lessons': [
        {'number': '2-1', 'title': 'AI产品岗位的方向选择策略', 'size': '48.4 MB', 'duration': '13分37秒'},
        {'number': '2-2', 'title': '其他AI非技术类岗位的选择策略', 'size': '30.8 MB', 'duration': '08分51秒'},
        {'number': '2-3', 'title': '技术出身行业大佬养成轨迹分析', 'size': '33.3 MB', 'duration': '09分03秒'},
        {'number': '2-4', 'title': '如何0到1学习成为AI产品经理', 'size': '58.0 MB', 'duration': '16分34秒'},
      ],
    },
    {
      'title': '第3章 理解大模型的能力边界',
      'lessons': [
        {'number': '3-1', 'title': '人工智能起源与4阶段发展浪潮', 'size': '40.8 MB', 'duration': '11分56秒'},
        {'number': '3-2', 'title': '大模型现象级爆发的根本动力', 'size': '25.6 MB', 'duration': '06分47秒'},
        {'number': '3-3', 'title': '大模型与传统AI的5项差异对比解读', 'size': '19.4 MB', 'duration': '05分52秒'},
        {'number': '3-4', 'title': '大模型的能力边界：典型的优势与失效场景', 'size': '39.2 MB', 'duration': '10分36秒'},
      ],
    },
  ];

  /// 每个章节的选中状态（章节索引 -> 课时索引集合）
  final Map<int, Set<int>> _selectedLessons = {};

  /// 剩余可用空间（GB）
  static const double _remainingSpaceGB = 703.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('下载'),
        centerTitle: true,
        actions: [
          // 右侧：下载管理按钮
          TextButton(
            onPressed: () {
              // TODO: 跳转到下载管理页面
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('下载管理')),
              );
            },
            child: const Text(
              '下载管理',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 构建章节列表（每个章节标题可吸顶）
          ..._buildChapterSections(),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  /// 构建章节区域列表（带吸顶效果）
  List<Widget> _buildChapterSections() {
    return _chapters.map((chapter) {
      final chapterIndex = _chapters.indexOf(chapter);
      final title = chapter['title'] as String;
      final lessons = chapter['lessons'] as List<Map<String, dynamic>>;
      final selectedLessons = _selectedLessons[chapterIndex] ?? {};

      return SliverMainAxisGroup(
        slivers: [
          // 吸顶章节标题（无选择框）
          SliverPersistentHeader(
            pinned: true, // 吸顶
            delegate: _ChapterHeaderDelegate(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    // 章节标题
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // 选中数量
                    Text(
                      '${selectedLessons.length}/${lessons.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 课时列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: lessons.length,
              (context, index) {
                final lesson = lessons[index];
                final isSelected = selectedLessons.contains(index);
                return _buildLessonItem(lesson, index, chapterIndex, isSelected);
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  /// 构建课时条目（圆圈选择框与文字顶部对齐）
  Widget _buildLessonItem(
    Map<String, dynamic> lesson,
    int lessonIndex,
    int chapterIndex,
    bool isSelected,
  ) {
    final number = lesson['number'] as String;
    final title = lesson['title'] as String;
    final size = lesson['size'] as String;
    final duration = lesson['duration'] as String;

    return InkWell(
      onTap: () => _toggleLessonSelect(chapterIndex, lessonIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // 顶部对齐
          children: [
            // 选择圆圈
            GestureDetector(
              onTap: () => _toggleLessonSelect(chapterIndex, lessonIndex),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // 课时信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 课时编号 + 标题
                  Text(
                    '$number $title',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 文件大小 + 时长
                  Row(
                    children: [
                      Text(
                        size,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 切换课时选中状态
  void _toggleLessonSelect(int chapterIndex, int lessonIndex) {
    setState(() {
      final chapterSelection = _selectedLessons[chapterIndex] ?? {};
      if (chapterSelection.contains(lessonIndex)) {
        chapterSelection.remove(lessonIndex);
      } else {
        chapterSelection.add(lessonIndex);
      }
      _selectedLessons[chapterIndex] = chapterSelection;
    });
  }

  /// 判断是否全部选中
  bool get _isAllSelected {
    int totalSelected = 0;
    int totalLessons = 0;
    for (var entry in _selectedLessons.entries) {
      totalSelected += entry.value.length;
    }
    for (var chapter in _chapters) {
      totalLessons += (chapter['lessons'] as List).length;
    }
    return totalSelected == totalLessons && totalLessons > 0;
  }

  /// 切换全选状态
  void _toggleSelectAll() {
    setState(() {
      if (_isAllSelected) {
        // 取消全选
        for (var chapter in _chapters) {
          final chapterIndex = _chapters.indexOf(chapter);
          _selectedLessons[chapterIndex] = {};
        }
      } else {
        // 全选
        for (var chapter in _chapters) {
          final chapterIndex = _chapters.indexOf(chapter);
          final lessons = chapter['lessons'] as List;
          _selectedLessons[chapterIndex] = {for (int i = 0; i < lessons.length; i++) i};
        }
      }
    });
  }

  /// 计算已选课时的总大小（MB）
  double _calculateSelectedSizeMB() {
    double totalSizeMB = 0;
    for (var entry in _selectedLessons.entries) {
      final chapterIndex = entry.key;
      final selectedLessonIndices = entry.value;
      final lessons = _chapters[chapterIndex]['lessons'] as List<Map<String, dynamic>>;

      for (var lessonIndex in selectedLessonIndices) {
        final lesson = lessons[lessonIndex];
        final sizeStr = lesson['size'] as String;
        // 解析大小字符串，例如 "12.8 MB" -> 12.8
        final sizeValue = double.parse(sizeStr.split(' ')[0]);
        totalSizeMB += sizeValue;
      }
    }
    return totalSizeMB;
  }

  /// 构建底部操作栏
  Widget _buildBottomActionBar() {
    // 计算总选中课时数
    int totalSelected = 0;
    for (var entry in _selectedLessons.entries) {
      totalSelected += entry.value.length;
    }

    // 计算已选大小
    final selectedSizeMB = _calculateSelectedSizeMB();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部：已选大小和剩余空间
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 已选大小（数字+MB为蓝色）
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '已选大小',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: selectedSizeMB == 0
                              ? '0MB'
                              : '${selectedSizeMB.toStringAsFixed(1)}MB',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 剩余空间（数字为红色）
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '剩余',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: '${_remainingSpaceGB.toStringAsFixed(1)}G',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text: '空间',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 底部：全选 + 选择下载按钮
            Row(
              children: [
                // 全选圆圈
                GestureDetector(
                  onTap: _toggleSelectAll,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isAllSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: _isAllSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                    ),
                    child: _isAllSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                // 全选文字
                const Text(
                  '全选',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                // 选择下载按钮
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: totalSelected > 0 ? _handleDownload : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: totalSelected > 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 长方形圆角
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '选择下载',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 处理下载
  void _handleDownload() {
    // TODO: 实现下载逻辑
    int totalSelected = 0;
    for (var entry in _selectedLessons.entries) {
      totalSelected += entry.value.length;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始下载 $totalSelected 个课时')),
    );
  }
}

/// 章节标题栏代理（用于吸顶效果）
class _ChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChapterHeaderDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 48.0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_ChapterHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
