/// 正则表达式常量
final class RegexConstants {
  const RegexConstants._();

  /// 手机号（中国大陆）
  static const String phone = r'^1[3-9]\d{9}$';

  /// 邮箱
  static const String email = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// 身份证号（中国大陆）
  static const String idCard = r'^\d{17}[\dXx]$';

  /// 用户名（4-20位字母数字下划线）
  static const String username = r'^[a-zA-Z0-9_]{4,20}$';

  /// 密码（8-20位，至少包含字母和数字）
  static const String password = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,20}$';

  /// URL
  static const String url = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  /// IPv4 地址
  static const String ipv4 = r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';

  /// 车牌号
  static const String licensePlate = r'^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-HJ-NP-Z0-9]{5,6}$';

  /// 银行卡号
  static const String bankCard = r'^\d{16,19}$';

  /// 邮政编码
  static const String postalCode = r'^\d{6}$';

  /// 微信号
  static const String wechatId = r'^[a-zA-Z][-a-zA-Z0-9_]{5,19}$';

  /// QQ 号
  static const String qq = r'^[1-9][0-9]{4,10}$';

  /// 颜色值（Hex 格式）
  static const String hexColor = r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$';

  /// 验证码（6位数字）
  static const String verificationCode = r'^\d{6}$';

  /// 纯数字
  static const String numeric = r'^\d+$';

  /// 纯字母
  static const String alpha = r'^[a-zA-Z]+$';

  /// 字母数字
  static const String alphaNumeric = r'^[a-zA-Z0-9]+$';

  /// 十六进制颜色
  static const String color = r'^(0x)?[0-9A-Fa-f]+$';
}
