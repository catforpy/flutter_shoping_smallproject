/// Result 类型
///
/// 用于表示一个操作的结果，可能是成功或失败
///
/// 示例：
/// ```dart
/// final result = Result.success('Hello');
/// final error = Result.failure(Exception('Error'));
/// ```
final class Result<T> {
  /// 是否成功
  final bool isSuccess;

  /// 是否失败
  final bool isFailure;

  /// 成功时的值
  final T? _value;

  /// 失败时的异常
  final Exception? _error;

  /// 私有构造函数
  const Result._({
    required this.isSuccess,
    required this.isFailure,
    T? value,
    Exception? error,
  })  : _value = value,
        _error = error;

  /// 创建成功结果
  factory Result.success(T value) {
    return Result._(
      isSuccess: true,
      isFailure: false,
      value: value,
    );
  }

  /// 创建失败结果
  factory Result.failure(Exception error) {
    return Result._(
      isSuccess: false,
      isFailure: true,
      error: error,
    );
  }

  /// 获取成功值
  ///
  /// 如果结果失败，会抛出异常
  T get valueOrThrow {
    if (isSuccess) {
      return _value as T;
    }
    throw _error!;
  }

  /// 获取成功值，如果失败则返回默认值
  T getOrElse(T defaultValue) {
    if (isSuccess) {
      return _value as T;
    }
    return defaultValue;
  }

  /// 获取错误
  Exception? get error => _error;

  /// 映射成功值
  Result<R> map<R>(R Function(T value) mapper) {
    if (isSuccess) {
      try {
        return Result.success(mapper(_value as T));
      } catch (e) {
        return Result.failure(Exception(e.toString()));
      }
    }
    return Result.failure(_error!);
  }

  /// 当成功时执行
  Result<T> onSuccess(void Function(T value) callback) {
    if (isSuccess) {
      callback(_value as T);
    }
    return this;
  }

  /// 当失败时执行
  Result<T> onFailure(void Function(Exception error) callback) {
    if (isFailure) {
      callback(_error!);
    }
    return this;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($_value)';
    }
    return 'Result.failure($_error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Result<T> &&
        other.isSuccess == isSuccess &&
        other._value == _value &&
        other._error == _error;
  }

  @override
  int get hashCode => Object.hash(isSuccess, _value, _error);
}

/// Result 扩展方法
extension ResultExtensions<T> on Result<T> {
  /// 链式调用
  Result<R> then<R>(Result<R> Function(T value) fn) {
    if (isSuccess) {
      return fn(_value as T);
    }
    return Result.failure(_error!);
  }

  /// 异步转换
  Future<Result<R>> thenAsync<R>(Future<Result<R>> Function(T value) fn) async {
    if (isSuccess) {
      return await fn(_value as T);
    }
    return Result.failure(_error!);
  }
}
