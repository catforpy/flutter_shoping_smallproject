/// Num 扩展方法
extension NumExtension on num? {
  /// 判断是否为 null
  bool get isNull => this == null;

  /// 判断是否不为 null
  bool get isNotNull => !isNull;

  /// 判断是否为 0
  bool get isZero => this != null && this == 0;

  /// 判断是否大于 0
  bool get isPositive => this != null && this! > 0;

  /// 判断是否小于 0
  bool get isNegative => this != null && this! < 0;

  /// 判断是否在指定范围内
  bool isBetween(num min, num max) {
    if (isNull) return false;
    return this! >= min && this! <= max;
  }

  /// 限制在指定范围内
  num? clamp(num min, num max) {
    if (isNull) return null;
    if (this! < min) return min;
    if (this! > max) return max;
    return this;
  }

  /// 格式化为文件大小字符串
  String? get toFileSize {
    if (isNull) return null;

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = this!.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    return '${value.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// 格式化为货币字符串
  String? toCurrency([String symbol = '¥', int decimals = 2]) {
    if (isNull) return null;
    return '$symbol${this!.toStringAsFixed(decimals)}';
  }

  /// 格式化为百分比字符串
  String? toPercent([int decimals = 0]) {
    if (isNull) return null;
    return '${(this! * 100).toStringAsFixed(decimals)}%';
  }

  /// 保留指定小数位
  num? toFixedNum(int fractionDigits) {
    if (isNull) return null;
    if (this is int) {
      return double.parse(this!.toStringAsFixed(fractionDigits));
    }
    return this;
  }

  /// 转换为 int
  int? toIntOrNull() {
    if (isNull) return null;
    return this!.toInt();
  }

  /// 转换为 double
  double? toDoubleOrNull() {
    if (isNull) return null;
    return this!.toDouble();
  }
}
