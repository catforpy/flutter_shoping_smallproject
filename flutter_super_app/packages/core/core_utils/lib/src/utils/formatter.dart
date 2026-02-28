import '../extensions/string_extension.dart' show StringExtension;
import '../extensions/num_extension.dart' show NumExtension;
import '../extensions/datetime_extension.dart' show DateTimeExtension;

/// 格式化工具类
///
/// 提供各种数据格式化方法
final class Formatter {
  const Formatter._();

  /// 格式化手机号（13812345678 -> 138****5678）
  static String formatPhone(String? phone) {
    return phone.hidePhoneNumber ?? '';
  }

  /// 格式化邮箱（example@gmail.com -> ex***@gmail.com）
  static String formatEmail(String? email) {
    return email.hideEmail ?? '';
  }

  /// 格式化身份证号
  static String formatIdCard(String? idCard) {
    return idCard.hideIdCard ?? '';
  }

  /// 格式化银行卡号（每4位加空格）
  static String formatBankCard(String? cardNo) {
    if (cardNo.isNullOrEmpty || cardNo!.length < 8) {
      return cardNo ?? '';
    }
    final buffer = StringBuffer();
    for (int i = 0; i < cardNo.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cardNo[i]);
    }
    return buffer.toString();
  }

  /// 格式化金额（123456.789 -> ¥123,456.79）
  static String formatMoney(
    num? amount, {
    String symbol = '¥',
    int decimals = 2,
    bool showSymbol = true,
  }) {
    if (amount == null) return '${showSymbol ? symbol : ''}0.00';

    final parts = amount.toStringAsFixed(decimals).split('.');
    final integerPart = _formatIntegerPart(parts[0]);
    final decimalPart = parts.length > 1 ? parts[1] : '0' * decimals;

    return '${showSymbol ? symbol : ''}$integerPart.$decimalPart';
  }

  /// 格式化整数部分（添加千分位逗号）
  static String _formatIntegerPart(String value) {
    if (value.length <= 3) return value;

    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(value[i]);
      count++;
    }

    return buffer.toString().split('').reversed.join('');
  }

  /// 格式化数字为中文（123 -> 一百二十三）
  static String formatNumberToChinese(int? number) {
    if (number == null) return '零';

    const digits = ['零', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    const units = ['', '十', '百', '千', '万', '十', '百', '千', '亿'];

    if (number == 0) return digits[0];

    final result = StringBuffer();
    String numStr = number.toString();
    int length = numStr.length;
    String lastChar = '';

    for (int i = 0; i < length; i++) {
      int digit = int.parse(numStr[i]);
      int pos = length - i - 1;

      if (digit != 0) {
        result.write(digits[digit]);
        result.write(units[pos]);
        lastChar = units[pos];
      } else {
        // 处理连续的零
        if (result.isNotEmpty && lastChar != '零') {
          result.write('零');
          lastChar = '零';
        }
      }
    }

    // 清理末尾的零
    String str = result.toString();
    while (str.endsWith('零')) {
      str = str.substring(0, str.length - 1);
    }

    return str;
  }

  /// 格式化文件大小
  static String formatFileSize(int? bytes) {
    return bytes?.toFileSize ?? '0 B';
  }

  /// 格式化时长（秒 -> HH:mm:ss）
  static String formatDuration(int? seconds) {
    if (seconds == null || seconds < 0) return '00:00:00';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
  }

  /// 格式化日期时间
  static String formatDateTime(
    DateTime? dateTime, {
    String pattern = 'yyyy-MM-dd HH:mm:ss',
  }) {
    return dateTime.format(pattern) ?? '';
  }

  /// 格式化相对时间
  static String formatRelativeTime(DateTime? dateTime) {
    return dateTime.toRelativeTime ?? '';
  }

  /// 格式化百分比
  static String formatPercent(
    num? value, {
    int decimals = 0,
    bool showSign = false,
  }) {
    if (value == null) return '0%';

    final percent = (value * 100).toStringAsFixed(decimals);
    final sign = (showSign && value > 0) ? '+' : '';

    return '$sign$percent%';
  }

  /// 格式化经纬度
  static String formatCoordinate(
    num? longitude,
    num? latitude, {
    int decimals = 6,
  }) {
    if (longitude == null || latitude == null) {
      return '';
    }

    final lng = longitude.toStringAsFixed(decimals);
    final lat = latitude.toStringAsFixed(decimals);

    return '$lng,$lat';
  }

  /// 截断文本
  static String truncate(String? text, int maxLength) {
    return text.ellipsis(maxLength) ?? '';
  }

  /// 高亮关键词
  static String highlightKeyword(
    String? text,
    String keyword, {
    String highlightStart = '[',
    String highlightEnd = ']',
  }) {
    if (text.isNullOrEmpty || keyword.isNullOrEmpty) {
      return text ?? '';
    }

    return text!.replaceAll(
      keyword,
      '$highlightStart$keyword$highlightEnd',
    );
  }
}
