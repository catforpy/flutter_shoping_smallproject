/// DateTime 扩展方法
extension DateTimeExtension on DateTime? {
  /// 判断是否为 null
  bool get isNull => this == null;

  /// 判断是否不为 null
  bool get isNotNull => !isNull;

  /// 是否是今天
  bool get isToday {
    if (isNull) return false;
    final now = DateTime.now();
    return this!.year == now.year &&
        this!.month == now.month &&
        this!.day == now.day;
  }

  /// 是否是昨天
  bool get isYesterday {
    if (isNull) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return this!.year == yesterday.year &&
        this!.month == yesterday.month &&
        this!.day == yesterday.day;
  }

  /// 是否是明天
  bool get isTomorrow {
    if (isNull) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return this!.year == tomorrow.year &&
        this!.month == tomorrow.month &&
        this!.day == tomorrow.day;
  }

  /// 获取当天的开始时间（00:00:00）
  DateTime? get startOfDay {
    if (isNull) return null;
    return DateTime(this!.year, this!.month, this!.day);
  }

  /// 获取当天的结束时间（23:59:59）
  DateTime? get endOfDay {
    if (isNull) return null;
    return DateTime(this!.year, this!.month, this!.day, 23, 59, 59, 999);
  }

  /// 获取当周的第一天（周一）
  DateTime? get startOfWeek {
    if (isNull) return null;
    final day = this!.weekday;
    return this!.subtract(Duration(days: day - 1)).startOfDay;
  }

  /// 获取当周的最后一天（周日）
  DateTime? get endOfWeek {
    if (isNull) return null;
    final day = this!.weekday;
    return this!.add(Duration(days: 7 - day)).endOfDay;
  }

  /// 获取当月的第一天
  DateTime? get startOfMonth {
    if (isNull) return null;
    return DateTime(this!.year, this!.month, 1);
  }

  /// 获取当月的最后一天
  DateTime? get endOfMonth {
    if (isNull) return null;
    final nextMonth = this!.month == 12
        ? DateTime(this!.year + 1, 1, 1)
        : DateTime(this!.year, this!.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).endOfDay;
  }

  /// 格式化为字符串（yyyy-MM-dd HH:mm:ss）
  String? format([String pattern = 'yyyy-MM-dd HH:mm:ss']) {
    if (isNull) return null;
    return _formatDateTime(this!, pattern);
  }

  /// 格式化为日期字符串（yyyy-MM-dd）
  String? get toDateString => format('yyyy-MM-dd');

  /// 格式化为时间字符串（HH:mm:ss）
  String? get toTimeString => format('HH:mm:ss');

  /// 格式化为日期时间字符串（yyyy-MM-dd HH:mm:ss）
  String? get toDateTimeString => format('yyyy-MM-dd HH:mm:ss');

  /// 相对时间描述（如：刚刚、5分钟前、1小时前等）
  String? get toRelativeTime {
    if (isNull) return null;

    final now = DateTime.now();
    final difference = now.difference(this!);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else {
      return '${(difference.inDays / 365).floor()}年前';
    }
  }

  /// 添加天数
  DateTime? addDays(int days) {
    if (isNull) return null;
    return this!.add(Duration(days: days));
  }

  /// 添加月数
  DateTime? addMonths(int months) {
    if (isNull) return null;
    final year = this!.year + (this!.month + months - 1) ~/ 12;
    final month = (this!.month + months - 1) % 12 + 1;
    return DateTime(year, month, this!.day);
  }

  /// 添加年数
  DateTime? addYears(int years) {
    if (isNull) return null;
    return DateTime(this!.year + years, this!.month, this!.day);
  }

  /// 计算两个日期之间的天数差
  int? daysBetween(DateTime? other) {
    if (isNull || other == null) return null;
    final diff = this!.difference(other);
    return diff.inDays.abs();
  }
}

/// 格式化日期时间的内部方法
String _formatDateTime(DateTime dateTime, String pattern) {
  final StringBuffer buffer = StringBuffer();

  for (int i = 0; i < pattern.length; i++) {
    final char = pattern[i];

    if (i + 4 <= pattern.length &&
        pattern.substring(i, i + 4) == 'yyyy') {
      buffer.write(dateTime.year.toString().padLeft(4, '0'));
      i += 3;
    } else if (i + 2 <= pattern.length &&
        pattern.substring(i, i + 2) == 'MM') {
      buffer.write(dateTime.month.toString().padLeft(2, '0'));
      i += 1;
    } else if (i + 2 <= pattern.length &&
        pattern.substring(i, i + 2) == 'dd') {
      buffer.write(dateTime.day.toString().padLeft(2, '0'));
      i += 1;
    } else if (i + 2 <= pattern.length &&
        pattern.substring(i, i + 2) == 'HH') {
      buffer.write(dateTime.hour.toString().padLeft(2, '0'));
      i += 1;
    } else if (i + 2 <= pattern.length &&
        pattern.substring(i, i + 2) == 'mm') {
      buffer.write(dateTime.minute.toString().padLeft(2, '0'));
      i += 1;
    } else if (i + 2 <= pattern.length &&
        pattern.substring(i, i + 2) == 'ss') {
      buffer.write(dateTime.second.toString().padLeft(2, '0'));
      i += 1;
    } else {
      buffer.write(char);
    }
  }

  return buffer.toString();
}
