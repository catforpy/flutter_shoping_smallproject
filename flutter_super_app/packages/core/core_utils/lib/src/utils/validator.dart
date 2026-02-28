import '../extensions/string_extension.dart' show StringExtension;

/// 验证器工具类
///
/// 提供各种数据验证方法
final class Validator {
  const Validator._();

  /// 验证手机号
  static bool isPhoneNumber(String? value) {
    return value.isPhoneNumber;
  }

  /// 验证邮箱
  static bool isEmail(String? value) {
    return value.isEmail;
  }

  /// 验证身份证号
  static bool isIdCard(String? value) {
    return value.isIdCard;
  }

  /// 验证 URL
  static bool isUrl(String? value) {
    return value.isUrl;
  }

  /// 验证用户名（4-20位，字母数字下划线）
  static bool isUsername(String? value) {
    if (value.isNullOrEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9_]{4,20}$').hasMatch(value!);
  }

  /// 验证密码（8-20位，至少包含字母和数字）
  static bool isPassword(String? value) {
    if (value.isNullOrEmpty) return false;
    if (value!.length < 8 || value.length > 20) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);
    return hasLetter && hasNumber;
  }

  /// 验证验证码（6位数字）
  static bool isVerificationCode(String? value) {
    if (value.isNullOrEmpty) return false;
    return RegExp(r'^\d{6}$').hasMatch(value!);
  }

  /// 验证车牌号
  static bool isLicensePlate(String? value) {
    if (value.isNullOrEmpty) return false;
    // 普通车牌：7位，省份简称+字母+5位数字/字母
    // 新能源车牌：8位
    return RegExp(
      r'^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-HJ-NP-Z0-9]{5,6}$',
    ).hasMatch(value!);
  }

  /// 验证银行卡号
  static bool isBankCard(String? value) {
    if (value.isNullOrEmpty) return false;
    return RegExp(r'^\d{16,19}$').hasMatch(value!);
  }

  /// 验证微信号
  static bool isWeChatId(String? value) {
    if (value.isNullOrEmpty) return false;
    // 6-20位，以字母开头，可包含字母、数字、下划线、减号
    return RegExp(r'^[a-zA-Z][-a-zA-Z0-9_]{5,19}$').hasMatch(value!);
  }

  /// 验证 QQ 号
  static bool isQQ(String? value) {
    if (value.isNullOrEmpty) return false;
    final num = int.tryParse(value!);
    if (num == null) return false;
    return num >= 10000 && num <= 9999999999;
  }

  /// 验证邮政编码
  static bool isPostalCode(String? value) {
    if (value.isNullOrEmpty) return false;
    return RegExp(r'^\d{6}$').hasMatch(value!);
  }

  /// 验证颜色值（Hex 格式）
  static bool isHexColor(String? value) {
    if (value.isNullOrEmpty) return false;
    return RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$').hasMatch(value!);
  }

  /// 验证 IP 地址（IPv4 或 IPv6）
  static bool isIP(String? value) {
    if (value.isNullOrEmpty) return false;
    return value.isIPv4 || RegExp(r'^::1$').hasMatch(value!);
  }

  /// 验证经度
  static bool isLongitude(String? value) {
    if (value.isNullOrEmpty) return false;
    final num = double.tryParse(value!);
    if (num == null) return false;
    return num >= -180 && num <= 180;
  }

  /// 验证纬度
  static bool isLatitude(String? value) {
    if (value.isNullOrEmpty) return false;
    final num = double.tryParse(value!);
    if (num == null) return false;
    return num >= -90 && num <= 90;
  }

  /// 验证年龄
  static bool isAge(String? value) {
    if (value.isNullOrEmpty) return false;
    final age = int.tryParse(value!);
    if (age == null) return false;
    return age >= 0 && age <= 150;
  }

  /// 组合验证结果
  static ValidationResult validate({
    String? phone,
    String? email,
    String? password,
    String? username,
  }) {
    final errors = <String, String>{};

    if (phone != null && !isPhoneNumber(phone)) {
      errors['phone'] = '手机号格式不正确';
    }

    if (email != null && !isEmail(email)) {
      errors['email'] = '邮箱格式不正确';
    }

    if (password != null && !isPassword(password)) {
      errors['password'] = '密码必须为8-20位，且包含字母和数字';
    }

    if (username != null && !isUsername(username)) {
      errors['username'] = '用户名必须为4-20位字母、数字或下划线';
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 验证结果
final class ValidationResult {
  /// 是否验证通过
  final bool isValid;

  /// 错误信息（字段名 -> 错误消息）
  final Map<String, String> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const {},
  });

  /// 获取第一个错误消息
  String? get firstError {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  /// 获取指定字段的错误消息
  String? getErrorFor(String field) {
    return errors[field];
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors)';
  }
}
