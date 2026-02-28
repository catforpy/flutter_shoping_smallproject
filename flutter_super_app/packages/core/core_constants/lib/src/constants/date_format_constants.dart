/// 日期时间格式常量
final class DateFormatConstants {
  const DateFormatConstants._();

  /// 完整日期时间格式
  static const String fullDateTime = 'yyyy-MM-dd HH:mm:ss';

  /// 日期格式
  static const String date = 'yyyy-MM-dd';

  /// 时间格式
  static const String time = 'HH:mm:ss';

  /// 日期时间格式（无秒）
  static const String dateTimeNoSeconds = 'yyyy-MM-dd HH:mm';

  /// 时间格式（无秒）
  static const String timeNoSeconds = 'HH:mm';

  /// 月份格式
  static const String month = 'yyyy-MM';

  /// 年份
  static const String year = 'yyyy';

  /// 中文日期格式
  static const String chineseDate = 'yyyy年MM月dd日';

  /// 中文日期时间格式
  static const String chineseDateTime = 'yyyy年MM月dd日 HH:mm:ss';

  /// ISO 8601 格式
  static const String iso8601 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  /// HTTP 日期格式
  static const String httpDate = 'EEE, dd MMM yyyy HH:mm:ss GMT';

  /// 文件名友好格式
  static const String fileSafe = 'yyyyMMdd_HHmmss';
}
