import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_logging/core_logging.dart';
import '../models/app_state.dart';

/// Provider 调试 Mixin
///
/// 提供详细的状态变更日志，方便调试
///
/// 使用示例：
/// ```dart
/// class MyProvider extends StateNotifier<UiState<User>>
///     with ProviderDebugMixin<UiState<User>> {
///   MyProvider() : super(UiState<User>.initial());
///
///   void loadData() {
///     // 状态变更会自动输出详细日志
///     state = UiState.loading();
///     // ...
///   }
/// }
/// ```
mixin ProviderDebugMixin<T> on StateNotifier<T> {
  /// Provider 标签（用于日志识别）
  String get tagName => runtimeType.toString();

  /// 是否启用调试日志（默认只在 Debug 模式启用）
  bool get isDebugEnabled => kDebugMode;

  @override
  set state(T newState) {
    final oldState = this.state; // 保留用于日志比较
    super.state = newState;

    // 只在开发环境输出详细日志
    if (isDebugEnabled) {
      _logStateChange(oldState, newState);
    }
  }

  /// 记录状态变更
  void _logStateChange(T oldState, T newState) {
    Log.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    Log.d('📦 Provider: $tagName');
    Log.d('📅 时间: ${_formatTime(DateTime.now())}');
    Log.d('📥 旧状态: ${_formatState(oldState)}');
    Log.d('📤 新状态: ${_formatState(newState)}');

    // 如果是错误状态，输出详细信息
    if (newState is ErrorState) {
      Log.d('❌ 错误类型: ${newState.error.runtimeType}');
      Log.d('❌ 错误信息: ${newState.error}');
      if (newState.stackTrace != null) {
        Log.d('📚 堆栈:\n${newState.stackTrace}');
      }
    }

    Log.d('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  /// 格式化状态
  String _formatState(T state) {
    if (state == null) return 'null';

    // 处理 AppState 类型
    if (state is AppState) {
      if (state is IdleState) {
        return 'Idle';
      } else if (state is LoadingState) {
        return 'Loading(message: ${state.message ?? "无"})';
      } else if (state is SuccessState) {
        final data = state.data;
        return 'Success(${_formatData(data)})';
      } else if (state is ErrorState) {
        return 'Error(${state.error.runtimeType})';
      } else if (state is DataState) {
        return 'DataState('
            'data: ${_formatData(state.data)}, '
            'isLoading: ${state.isLoading}, '
            'hasError: ${state.hasError}'
            ')';
      }
    }

    // 处理其他类型
    return state.toString();
  }

  /// 格式化数据
  String _formatData(dynamic data) {
    if (data == null) return 'null';
    if (data is List) return 'List(${data.length})';
    if (data is Map) return 'Map(${data.length})';
    if (data is String && data.length > 50) return '"${data.substring(0, 50)}..."';
    return data.toString();
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }
}

/// 状态历史记录 Mixin（可选）
///
/// 记录最近 N 次状态变更，用于调试和问题排查
///
/// 使用示例：
/// ```dart
/// class MyProvider extends StateNotifier<UiState<User>>
///     with StateHistoryMixin<UiState<User>> {
///   MyProvider() : super(UiState<User>.initial()) {
///     // 设置最大历史记录数
///     maxHistory = 50;
///   }
///
///   // 导出历史记录
///   String exportHistory() => getHistoryJson();
/// }
/// ```
mixin StateHistoryMixin<T> on StateNotifier<T> {
  /// 最大历史记录数（默认 50）
  int maxHistory = 50;

  /// 状态历史记录
  final List<StateSnapshot<T>> _history = [];

  /// 获取历史记录
  List<StateSnapshot<T>> get history => List.unmodifiable(_history);

  /// 获取最近 N 条记录
  List<StateSnapshot<T>> getRecent(int count) {
    final start = _history.length > count ? _history.length - count : 0;
    return List.unmodifiable(_history.sublist(start));
  }

  /// 导出历史记录为 JSON
  String getHistoryJson() {
    return _history
        .map((snapshot) => snapshot.toJson())
        .toString(); // 简化处理，实际应该用 jsonEncode
  }

  @override
  set state(T newState) {
    super.state = newState;

    // 记录状态快照
    _recordSnapshot(newState);
  }

  /// 记录状态快照
  void _recordSnapshot(T state) {
    _history.add(StateSnapshot<T>(
      time: DateTime.now(),
      state: state,
    ));

    // 限制历史记录数量
    if (_history.length > maxHistory) {
      _history.removeAt(0);
    }
  }

  /// 清空历史记录
  void clearHistory() {
    _history.clear();
  }
}

/// 状态快照
class StateSnapshot<T> {
  /// 时间戳
  final DateTime time;

  /// 状态
  final T state;

  const StateSnapshot({
    required this.time,
    required this.state,
  });

  /// 转换为 JSON（导出用）
  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'state': state?.toString(),
    };
  }

  @override
  String toString() {
    return 'StateSnapshot(time: $time, state: $state)';
  }
}
