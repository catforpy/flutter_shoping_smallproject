import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_logging/core_logging.dart';
import '../models/ui_state.dart';

/// 异步数据通知器
///
/// 简化异步操作的状态管理
base class AsyncNotifier<T> extends StateNotifier<UiState<T>> {
  AsyncNotifier() : super(UiState<T>.initial());

  /// 当前数据
  T? get data => state.data;

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 是否有错误
  bool get hasError => state.hasError;

  /// 错误消息
  String? get errorMessage => state.errorMessage;

  /// 执行异步操作
  Future<void> fetch(
    Future<T> Function() operation, {
    bool resetOnError = false,
  }) async {
    try {
      state = UiState<T>.loading();
      Log.i('AsyncNotifier 开始执行');
      final result = await operation();
      state = UiState<T>.success(result);
      Log.i('AsyncNotifier 执行成功');
    } catch (e) {
      Log.e('AsyncNotifier 执行失败', error: e);
      state = UiState<T>.error(e.toString());
      if (resetOnError) {
        reset();
      }
    }
  }

  /// 重置状态
  void reset() {
    state = UiState<T>.initial();
    Log.i('AsyncNotifier 状态重置');
  }

  /// 手动设置数据
  void setData(T data) {
    state = UiState<T>.success(data);
  }

  /// 手动设置错误
  void setError(String message) {
    state = UiState<T>.error(message);
  }
}

/// 异步数据 Provider 定义辅助函数
///
/// 简化 Provider 的创建
ProviderContainer get providerContainer => ProviderContainer();

/// 创建异步通知器 Provider
StateNotifierProvider<AsyncNotifier<T>, UiState<T>>
    createAsyncNotifierProvider<T>(
  T Function() initialValue,
) {
  return StateNotifierProvider<AsyncNotifier<T>, UiState<T>>(
    (ref) {
      final notifier = AsyncNotifier<T>();
      return notifier;
    },
  );
}
