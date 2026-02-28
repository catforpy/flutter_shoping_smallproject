/// String 扩展方法
extension StringExtension on String? {
  /// 判断是否为空或 null
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// 判断是否不为空
  bool get isNotNullOrNotEmpty => !isNullOrEmpty;

  /// 去除首尾空格后判断是否为空
  bool get isNullOrBlank {
    if (this == null) return true;
    return this!.trim().isEmpty;
  }

  /// 验证是否是手机号（中国大陆）
  bool get isPhoneNumber {
    if (isNullOrEmpty) return false;
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this!);
  }

  /// 验证是否是邮箱
  bool get isEmail {
    if (isNullOrEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this!);
  }

  /// 验证是否是纯数字
  bool get isNumeric {
    if (isNullOrEmpty) return false;
    return RegExp(r'^\d+$').hasMatch(this!);
  }

  /// 验证是否是身份证号（中国大陆）
  bool get isIdCard {
    if (isNullOrEmpty) return false;
    // 简单验证：18位数字或17位数字+X
    return RegExp(r'^\d{17}[\dXx]$').hasMatch(this!);
  }

  /// 验证是否是 URL
  bool get isUrl {
    if (isNullOrEmpty) return false;
    return RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    ).hasMatch(this!);
  }

  /// 验证是否是 IPv4 地址
  bool get isIPv4 {
    if (isNullOrEmpty) return false;
    return RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    ).hasMatch(this!);
  }

  /// 隐藏手机号中间四位
  String? get hidePhoneNumber {
    if (isNullOrEmpty || !isPhoneNumber) return this;
    return this!.replaceFirstMapped(
      RegExp(r'(\d{3})\d{4}(\d{4})'),
      (match) => '${match[1]}****${match[2]}',
    );
  }

  /// 隐藏邮箱
  String? get hideEmail {
    if (isNullOrEmpty || !isEmail) return this;
    final parts = this!.split('@');
    if (parts.length != 2) return this;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return this;
    return '${name[0]}***@$domain';
  }

  /// 隐藏身份证号
  String? get hideIdCard {
    if (isNullOrEmpty || !isIdCard) return this;
    return this!.replaceFirstMapped(
      RegExp(r'(\d{6})\d{8}(\d{4})'),
      (match) => '${match[1]}********${match[2]}',
    );
  }

  /// 首字母大写
  String? get capitalize {
    if (isNullOrEmpty) return this;
    return this![0].toUpperCase() + this!.substring(1);
  }

  /// 转换为 int
  int? toIntOrNull() {
    if (isNullOrEmpty) return null;
    return int.tryParse(this!);
  }

  /// 转换为 double
  double? toDoubleOrNull() {
    if (isNullOrEmpty) return null;
    return double.tryParse(this!);
  }

  /// 截取字符串并添加省略号
  String? ellipsis(int maxLength) {
    if (isNullOrEmpty) return this;
    if (this!.length <= maxLength) return this;
    return '${this!.substring(0, maxLength)}...';
  }

  /// 移除所有空白字符
  String? get removeAllWhitespace {
    if (isNullOrEmpty) return this;
    return this!.replaceAll(RegExp(r'\s+'), '');
  }

  /// 判断是否包含中文
  bool get containsChinese {
    if (isNullOrEmpty) return false;
    return RegExp(r'[\u4e00-\u9fa5]').hasMatch(this!);
  }

  /// 将字符串转换为安全的文件名
  String? toSafeFileName() {
    if (isNullOrEmpty) return this;
    return this!
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }
}
