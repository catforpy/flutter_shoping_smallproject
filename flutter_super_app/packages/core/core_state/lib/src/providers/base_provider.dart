import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_logging/core_logging.dart';
import '../models/app_state.dart';

/// 基础 Provider
///
/// 所有 Provider 的基类
base class BaseProvider<T> extends StateNotifier<AppState> {
  BaseProvider() : super(const IdleState());

  /// 获取当前数据
  T? get data {
    final state = this.state;
    if (state is SuccessState<T>) {
      return state.data;
    }
    return null;
  }

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 是否有错误
  bool get hasError => state.isError;

  /// 是否为空闲状态
  bool get isIdle => state.isIdle;

  /// 设置加载状态
  void setLoading([String? message]) {
    state = LoadingState(message: message);
  }

  /// 设置成功状态
  void setSuccess(T data) {
    state = SuccessState<T>(data);
    Log.i('Provider 操作成功: ${runtimeType}');
  }

  /// 设置错误状态
  void setError(Object error, [StackTrace? stackTrace]) {
    state = ErrorState(error, stackTrace);
    Log.e('Provider 操作失败: ${runtimeType}', error: error);
  }

  /// 重置状态
  void reset() {
    state = const IdleState();
  }

  /// 执行异步操作（自动处理加载/成功/错误状态）
  Future<void> execute(
    Future<T> Function() operation, {
    String? loadingMessage,
  }) async {
    try {
      setLoading(loadingMessage);
      final result = await operation();
      setSuccess(result);
    } catch (e, stackTrace) {
      setError(e, stackTrace);
      rethrow;
    }
  }
}

/// 自动释放的 Provider 混入
mixin AutoDisposeMixin<T> on StateNotifier<T> {
  @override
  void dispose() {
    Log.i('Provider 已释放: ${runtimeType}');
    super.dispose();
  }
}

/// 带日志的 Provider
mixin LoggingMixin<T> on StateNotifier<T> {
  @override
  void set state(T newState) {
    final oldState = this.state;
    super.state = newState;
    Log.i('Provider 状态变更: ${runtimeType}');
    Log.i('  旧状态: $oldState');
    Log.i('  新状态: $newState');
  }
}
