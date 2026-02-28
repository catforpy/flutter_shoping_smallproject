import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'course_schedule_edit_page.dart';
import 'providers/course_schedule_provider.dart';

/// 课程表页面
///
/// 课程表主页面，显示课程安排和时间表
class CourseSchedulePage extends ConsumerStatefulWidget {
  const CourseSchedulePage({super.key});

  @override
  ConsumerState<CourseSchedulePage> createState() => _CourseSchedulePageState();
}

class _CourseSchedulePageState extends ConsumerState<CourseSchedulePage> {

  /// 未加入课表的课程列表
  final List<Map<String, dynamic>> _availableCourses = [
    {
      'isFree': true,
      'title': '揭开 AI 产品经理黄金赛道',
      'progress': 0,
    },
    {
      'isFree': false,
      'title': 'ChatGPT + Flutter 快速开发多端聊天机器人 App',
      'tagText': '实战',
      'progress': 53,
    },
    {
      'isFree': false,
      'title': 'Flutter 高级进阶实战 - 仿哔哩哔哩 - 掌握 Flutter 高阶技能',
      'tagText': '实战',
      'progress': 76,
    },
    {
      'isFree': false,
      'title': 'Netty+SpringBoot 开发即时通讯系统',
      'tagText': '实战',
      'progress': 6,
    },
    {
      'isFree': false,
      'title': 'SpringBoot 3 + Flutter3 实战低代码运营管理',
      'tagText': '实战',
      'progress': 94,
    },
    {
      'isFree': false,
      'title': 'SpringCloudAlibaba 高并发仿斗鱼直播平台实战',
      'tagText': '实战',
      'progress': 79,
    },
    {
      'isFree': false,
      'title': '新版 Springboot3.0 打造能落地的高并发仿 12306 售票系统',
      'tagText': '实战',
      'progress': 9,
    },
    {
      'isFree': false,
      'title': '高并发，高性能，高可用的 MySQL 实战',
      'tagText': '实战',
      'progress': 66,
    },
    {
      'isFree': true,
      'title': 'Springboot + ElasticSearch 构建博客检索系统',
      'progress': 0,
    },
    {
      'isFree': true,
      'title': 'TypeScript 极速入门',
      'progress': 0,
    },
    {
      'isFree': true,
      'title': '从 Docker 到 K8S，容器技术演进之路',
      'progress': 0,
    },
    {
      'isFree': true,
      'title': '全面解读大热行业 物联网/嵌入式前景与就业',
      'progress': 0,
    },
    {
      'isFree': true,
      'title': '深入 AI/大模型必备数学基础 1—线性代数入门篇',
      'progress': 0,
    },
    {
      'isFree': true,
      'title': '深入 AI/大模型必备数学基础 3—概率论入门篇',
      'progress': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 监听课程表状态
    final scheduleText = ref.watch(courseScheduleTextProvider);
    final addedCourses = ref.watch(courseScheduleAddedCoursesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('课程表'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 可滚动的内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 课程提醒标签
                _buildScheduleTag(scheduleText),
                const SizedBox(height: 24),
                // 已加入课表组合
                _buildAddedCoursesSection(addedCourses),
                const SizedBox(height: 24),
                // 未加入课表组合
                _buildAvailableCoursesSection(addedCourses),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // 固定在底部的保存按钮
          Container(
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
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '保存课表',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建课程提醒标签
  Widget _buildScheduleTag(String? scheduleText) {
    return InkWell(
      onTap: _openScheduleEdit,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 231, 83, 81).withAlpha(50), // 橙色
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 左侧：文字描述
            Expanded(
              child: Text(
                scheduleText ?? '每周1/2/3/4/5/6/7 12:00提醒',
                style: const TextStyle(
                  color: Color.fromARGB(255, 247, 33, 33),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // 右侧：添加图标
            const Icon(
              Icons.add_circle_outline,
              color: Color.fromARGB(255, 247, 33, 33),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 打开课程时间设置页面
  void _openScheduleEdit() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const CourseScheduleEditPage(
          initialTime: TimeOfDay(hour: 12, minute: 0),
          initialWeekdays: [0, 1, 2, 3, 4, 5, 6],
          initialReminderEnabled: true,
        ),
      ),
    );

    // 处理返回结果，更新标签文字
    if (result != null && mounted) {
      final time = result['time'] as TimeOfDay;
      final weekdays = result['weekdays'] as List<int>;
      final reminderEnabled = result['reminderEnabled'] as bool;

      if (!reminderEnabled) {
        // 如果关闭了提醒
        ref.read(courseScheduleTextProvider.notifier).state = '已关闭提醒';
      } else {
        // 生成标签文字
        final weekdayStr = _formatWeekdays(weekdays);
        final timeStr = time.format(context);
        ref.read(courseScheduleTextProvider.notifier).state = '每周$weekdayStr $timeStr 提醒';
      }
    }
  }

  /// 格式化星期列表
  /// 例如：[0,1,2,3,4,5,6] -> "1/2/3/4/5/6/7"
  /// 例如：[0,2,4] -> "一/三/五"
  String _formatWeekdays(List<int> weekdays) {
    if (weekdays.length == 7) {
      // 全选
      return '1/2/3/4/5/6/7';
    }

    // 部分选择，转换为星期几
    const weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    final selected = weekdays.map((i) => weekdayNames[i]).join('/');
    return selected;
  }

  /// 构建已加入课表部分
  Widget _buildAddedCoursesSection(List<Map<String, dynamic>> addedCourses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 章节标题
        _buildSectionTitle('已加入课表（${addedCourses.length}）'),
        const SizedBox(height: 12),
        // 课程卡片列表
        ...addedCourses.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          return _buildAddedCourseCard(course, index, addedCourses);
        }),
      ],
    );
  }

  /// 构建未加入课表部分
  Widget _buildAvailableCoursesSection(List<Map<String, dynamic>> addedCourses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 章节标题
        _buildSectionTitle('未加入课表'),
        const SizedBox(height: 12),
        // 课程卡片列表
        ..._availableCourses.map((course) => _buildAvailableCourseCard(course, addedCourses)),
      ],
    );
  }

  /// 构建分节标题
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// 构建已加入课表的课程卡片
  Widget _buildAddedCourseCard(Map<String, dynamic> course, int index, List<Map<String, dynamic>> addedCourses) {
    final isFree = course['isFree'] as bool;
    final title = course['title'] as String;
    final dailyLessons = course['dailyLessons'] as int;
    final tagText = course['tagText'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 0), // 卡片之间没有padding
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 主要内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：标签（免费或实战）+ 课程标题（在同一行，顶部对齐）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标签
                    if (isFree || tagText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFree
                              ? const Color(0xFFFF3B30)
                              : Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFree ? '免费' : tagText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isFree || tagText != null) const SizedBox(width: 8),
                    // 课程标题
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 底部：每日学习 + 增减按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 左侧：每日学习文字
                    Text(
                      '每日学习',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    // 右侧：增减按钮组合
                    Row(
                      children: [
                        // 减号按钮
                        _buildLessonButton(
                          icon: Icons.remove,
                          onTap: () {
                            if (dailyLessons > 1) {
                              // 创建更新后的课程副本
                              final updatedCourses = List<Map<String, dynamic>>.from(addedCourses);
                              updatedCourses[index] = Map<String, dynamic>.from(course);
                              updatedCourses[index]['dailyLessons'] = dailyLessons - 1;
                              ref.read(courseScheduleAddedCoursesProvider.notifier).state = updatedCourses;
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$dailyLessons节',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 加号按钮
                        _buildLessonButton(
                          icon: Icons.add,
                          onTap: () {
                            // 创建更新后的课程副本
                            final updatedCourses = List<Map<String, dynamic>>.from(addedCourses);
                            updatedCourses[index] = Map<String, dynamic>.from(course);
                            updatedCourses[index]['dailyLessons'] = dailyLessons + 1;
                            ref.read(courseScheduleAddedCoursesProvider.notifier).state = updatedCourses;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 悬浮关闭按钮（右上角）
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                // 从列表中移除课程
                final updatedCourses = List<Map<String, dynamic>>.from(addedCourses);
                updatedCourses.removeAt(index);
                ref.read(courseScheduleAddedCoursesProvider.notifier).state = updatedCourses;
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建未加入课表的课程卡片
  Widget _buildAvailableCourseCard(Map<String, dynamic> course, List<Map<String, dynamic>> addedCourses) {
    final isFree = course['isFree'] as bool;
    final title = course['title'] as String;
    final progress = course['progress'] as int;
    final tagText = course['tagText'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 0), // 卡片之间没有padding
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：标签（免费或实战）+ 课程标题（在同一行，顶部对齐）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标签
                if (isFree || tagText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFree
                          ? const Color(0xFFFF3B30)
                          : Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isFree ? '免费' : tagText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isFree || tagText != null) const SizedBox(width: 8),
                // 课程标题
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 底部：学习进度 + 加入课表按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 学习进度
                Text(
                  '已学$progress%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                // 加入课表按钮
                GestureDetector(
                  onTap: () {
                    // 加入课表逻辑
                    final updatedCourses = List<Map<String, dynamic>>.from(addedCourses);
                    updatedCourses.add({
                      'isFree': isFree,
                      'title': title,
                      'tagText': tagText, // 保留标签信息
                      'dailyLessons': 1,
                    });
                    ref.read(courseScheduleAddedCoursesProvider.notifier).state = updatedCourses;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已加入课表：$title')),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        '加入课表',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建增减节数按钮
  Widget _buildLessonButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  /// 保存课表
  void _handleSave() {
    // TODO: 实现保存逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('课表已保存')),
    );
    Navigator.pop(context);
  }
}
