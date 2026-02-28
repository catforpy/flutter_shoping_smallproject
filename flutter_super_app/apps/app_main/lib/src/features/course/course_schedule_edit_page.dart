import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';

/// 课表调整页面
///
/// 用于设置课程时间、重复规则和学习提醒
class CourseScheduleEditPage extends StatefulWidget {
  /// 初始时间
  final TimeOfDay? initialTime;

  /// 初始选中的星期（0-6，0代表周一）
  final List<int>? initialWeekdays;

  /// 初始提醒状态
  final bool? initialReminderEnabled;

  const CourseScheduleEditPage({
    super.key,
    this.initialTime,
    this.initialWeekdays,
    this.initialReminderEnabled,
  });

  @override
  State<CourseScheduleEditPage> createState() => _CourseScheduleEditPageState();
}

class _CourseScheduleEditPageState extends State<CourseScheduleEditPage> {
  /// 选中的时间
  late TimeOfDay selectedTime;

  /// 选中的星期（0-6，0代表周一）
  List<int> selectedWeekdays = [];

  /// 是否开启学习提醒
  bool reminderEnabled = true;

  /// 星期列表
  static const List<String> weekdays = [
    '星期一',
    '星期二',
    '星期三',
    '星期四',
    '星期五',
    '星期六',
    '星期日',
  ];

  @override
  void initState() {
    super.initState();
    // 初始化时间
    selectedTime = widget.initialTime ?? const TimeOfDay(hour: 12, minute: 4);
    // 初始化星期（创建可变副本，避免修改不可变列表）
    selectedWeekdays = widget.initialWeekdays != null
        ? List<int>.from(widget.initialWeekdays!)
        : [0, 1, 2, 3, 4, 5, 6];
    // 初始化提醒状态
    reminderEnabled = widget.initialReminderEnabled ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 内容区域（可滚动）
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),
                  // 时间选择器
                  _buildTimePicker(),
                  const SizedBox(height: 24),
                  // 星期选择列表
                  _buildWeekdaySelector(),
                  const SizedBox(height: 16),
                  // 学习提醒开关
                  _buildReminderSwitch(),
                ],
              ),
            ),
            // 底部确定按钮
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
        tooltip: '关闭',
      ),
      title: const Text('调整课表'),
      centerTitle: true,
    );
  }

  /// 构建时间选择器（iOS 风格滚轮）
  Widget _buildTimePicker() {
    return Container(
      height: 140, // 稍微放大
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 选中项的高亮背景（立体效果）
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // 滚轮选择器
          Row(
            children: [
              // 小时滚轮
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedTime.hour,
                  ),
                  selectionOverlay: const SizedBox(), // 禁用默认遮罩，使用自定义背景
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedTime = TimeOfDay(
                        hour: index,
                        minute: selectedTime.minute,
                      );
                    });
                  },
                  children: List.generate(24, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 22, // 稍微放大
                          color: index == selectedTime.hour
                              ? Colors.black
                              : Colors.grey.shade400,
                          fontWeight: index == selectedTime.hour
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 冒号分隔符
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              // 分钟滚轮
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedTime.minute,
                  ),
                  selectionOverlay: const SizedBox(), // 禁用默认遮罩
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedTime = TimeOfDay(
                        hour: selectedTime.hour,
                        minute: index,
                      );
                    });
                  },
                  children: List.generate(60, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 22, // 稍微放大
                          color: index == selectedTime.minute
                              ? Colors.black
                              : Colors.grey.shade400,
                          fontWeight: index == selectedTime.minute
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建星期选择列表
  Widget _buildWeekdaySelector() {
    return GroupedListSection(
      config: GroupedListSectionConfig(
        showCardEffect: true,
        cardBackgroundColor: Colors.white,
        cardMargin: const EdgeInsets.only(bottom: 16),
        cardPadding: EdgeInsets.zero, // 去掉卡片内边距
        dividerConfig: const GroupedListDividerConfig(
          height: 0.5,
        ), // 缩小分割线
        items: List.generate(7, (index) {
          final isSelected = selectedWeekdays.contains(index);
          return GroupedListItemConfig(
            title: weekdays[index],
            trailing: Icon(
              Icons.check,
              color: isSelected
                  ? const Color(0xFFFF3B30) // 红色（选中）
                  : Colors.grey.shade300, // 灰色（未选中）
              size: 20, // 缩小图标
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedWeekdays.remove(index);
                } else {
                  selectedWeekdays.add(index);
                }
              });
            },
          );
        }),
      ),
    );
  }

  /// 构建学习提醒开关
  Widget _buildReminderSwitch() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text(
          '学习提醒',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text(
          '开启后可收到Push和微信提醒',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Switch(
          value: reminderEnabled,
          onChanged: (value) {
            setState(() {
              reminderEnabled = value;
            });
          },
          activeColor: const Color(0xFFFF3B30),
        ),
        onTap: () {
          // 点击整行也能切换开关
          setState(() {
            reminderEnabled = !reminderEnabled;
          });
        },
      ),
    );
  }

  /// 构建确定按钮
  Widget _buildConfirmButton() {
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
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: const Text(
            '确定',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// 确认按钮点击事件
  void _handleConfirm() {
    // 验证是否至少选择了一天
    if (selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一天')),
      );
      return;
    }

    // 返回结果
    final result = {
      'time': selectedTime,
      'weekdays': selectedWeekdays,
      'reminderEnabled': reminderEnabled,
    };

    Navigator.pop(context, result);
  }
}
