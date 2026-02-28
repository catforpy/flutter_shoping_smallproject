/// 应用状态基类
///
/// 所有状态类的基类
base class AppState {
  /// 是否为加载状态
  bool get isLoading => this is LoadingState;

  /// 是否为成功状态
  bool get isSuccess => this is SuccessState;

  /// 是否为错误状态
  bool get isError => this is ErrorState;

  /// 是否为空闲状态
  bool get isIdle => this is IdleState;

  const AppState();
}

/// 空闲状态
final class IdleState extends AppState {
  const IdleState() : super();

  @override
  String toString() => 'IdleState';
}

/// 加载状态
final class LoadingState extends AppState {
  final String? message;

  const LoadingState({this.message}) : super();

  @override
  String toString() => 'LoadingState(message: $message)';
}

/// 成功状态
final class SuccessState<T> extends AppState {
  final T data;

  const SuccessState(this.data) : super();

  @override
  String toString() => 'SuccessState(data: $data)';
}

/// 错误状态
final class ErrorState extends AppState {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorState(
    this.error, [
    this.stackTrace,
  ]) : super();

  @override
  String toString() => 'ErrorState(error: $error)';
}

/// 数据状态（带数据和加载状态）
final class DataState<T> extends AppState {
  final T? data;
  final bool isLoading;
  final Object? error;

  const DataState({
    this.data,
    this.isLoading = false,
    this.error,
  }) : super();

  /// 创建空闲状态
  factory DataState.idle() => const DataState();

  /// 创建加载状态
  factory DataState.loading() => const DataState(isLoading: true);

  /// 创建成功状态
  factory DataState.success(T data) => DataState(data: data);

  /// 创建错误状态
  factory DataState.error(Object error) => DataState(error: error);

  /// 是否有错误
  bool get hasError => error != null;

  /// 是否有数据
  bool get hasData => data != null;

  DataState<T> copyWith({
    T? data,
    bool? isLoading,
    Object? error,
  }) {
    return DataState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'DataState(data: $data, isLoading: $isLoading, error: $error)';
}
