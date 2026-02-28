import 'result.dart' show Result;

/// Either 类型
///
/// 表示两种可能值之一，Left 或 Right
/// 常用于错误处理：Left 表示错误，Right 表示成功
///
/// 示例：
/// ```dart
/// final success = Either.right('Success');
/// final failure = Either.left('Error');
/// ```
abstract base class Either<L, R> {
  const Either();

  /// 是否为 Left
  bool get isLeft;

  /// 是否为 Right
  bool get isRight;

  /// 创建 Left 值
  factory Either.left(L value) = _Left<L, R>;

  /// 创建 Right 值
  factory Either.right(R value) = _Right<L, R>;

  /// 获取 Left 值
  L? get left;

  /// 获取 Right 值
  R? get right;

  /// 折叠
  T fold<T>(
    T Function(L left) onLeft,
    T Function(R right) onRight,
  );

  /// 映射 Right 值
  Either<L, R2> map<R2>(R2 Function(R value) mapper) {
    return fold(
      (left) => Either.left(left),
      (right) => Either.right(mapper(right)),
    );
  }

  /// 映射 Left 值
  Either<L2, R> mapLeft<L2>(L2 Function(L value) mapper) {
    return fold(
      (left) => Either.left(mapper(left)),
      (right) => Either.right(right),
    );
  }

  /// 链式调用
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R value) mapper) {
    return fold(
      (left) => Either.left(left),
      (right) => mapper(right),
    );
  }

  /// 交换 Left 和 Right
  Either<R, L> swap() {
    return fold(
      (left) => Either.right(left),
      (right) => Either.left(right),
    );
  }

  /// 获取值或抛出异常
  R get valueOrThrow {
    return fold(
      (left) => throw Exception(left.toString()),
      (right) => right,
    );
  }

  /// 获取值或返回默认值
  R getOrElse(R defaultValue) {
    return fold(
      (left) => defaultValue,
      (right) => right,
    );
  }
}

/// Left 实现
final class _Left<L, R> extends Either<L, R> {
  final L _value;

  const _Left(this._value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  L? get left => _value;

  @override
  R? get right => null;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(_value);
  }

  @override
  String toString() => 'Left($_value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Left<L, R> && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}

/// Right 实现
final class _Right<L, R> extends Either<L, R> {
  final R _value;

  const _Right(this._value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  L? get left => null;

  @override
  R? get right => _value;

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(_value);
  }

  @override
  String toString() => 'Right($_value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Right<L, R> && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;
}

/// Either 扩展方法
extension EitherExtensions<L, R> on Either<L, R> {
  /// 当为 Right 时执行
  Either<L, R> onSuccess(void Function(R value) callback) {
    final r = right;
    if (r != null) {
      callback(r);
    }
    return this;
  }

  /// 当为 Left 时执行
  Either<L, R> onFailure(void Function(L error) callback) {
    final l = left;
    if (l != null) {
      callback(l);
    }
    return this;
  }

  /// 转换为 Result
  Result<R> toResult() {
    return fold(
      (left) => Result.failure(Exception(left.toString())),
      (right) => Result.success(right),
    );
  }
}
