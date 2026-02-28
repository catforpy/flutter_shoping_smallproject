/// 日志级别枚举
enum LogLevel {
  /// 调试级别
  debug(0, 'DEBUG'),

  /// 信息级别
  info(1, 'INFO'),

  /// 警告级别
  warning(2, 'WARNING'),

  /// 错误级别
  error(3, 'ERROR'),

  /// 致命错误级别
  fatal(4, 'FATAL');

  /// 级别值（用于比较）
  final int value;

  /// 级别名称
  final String name;

  const LogLevel(this.value, this.name);

  /// 是否包含指定级别（用于判断是否应该记录日志）
  bool shouldLog(LogLevel minLevel) {
    return value >= minLevel.value;
  }

  @override
  String toString() => name;
}
