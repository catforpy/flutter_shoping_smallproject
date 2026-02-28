/// UI 状态
///
/// 用于 UI 层的状态管理
final class UiState<T> {
  final T? data;
  final bool isLoading;
  final String? errorMessage;

  const UiState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 初始状态
  factory UiState.initial() => const UiState();

  /// 加载状态
  factory UiState.loading() => const UiState(isLoading: true);

  /// 成功状态
  factory UiState.success(T data) => UiState(data: data);

  /// 错误状态
  factory UiState.error(String message) => UiState(errorMessage: message);

  /// 是否为初始状态
  bool get isInitial => !isLoading && data == null && errorMessage == null;

  /// 是否有错误
  bool get hasError => errorMessage != null;

  /// 是否有数据
  bool get hasData => data != null;

  UiState<T> copyWith({
    T? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UiState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'UiState(data: $data, isLoading: $isLoading, error: $errorMessage)';
}

/// 分页 UI 状态
final class PagedUiState<T> {
  final List<T> data;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const PagedUiState({
    this.data = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 1,
  });

  /// 初始状态
  factory PagedUiState.initial() => const PagedUiState();

  /// 加载状态
  factory PagedUiState.loading() => const PagedUiState(isLoading: true);

  /// 成功状态
  factory PagedUiState.success(List<T> data, {bool hasMore = true}) {
    return PagedUiState(data: data, hasMore: hasMore);
  }

  /// 错误状态
  factory PagedUiState.error(String message) {
    return PagedUiState(errorMessage: message);
  }

  /// 是否为初始状态
  bool get isInitial => !isLoading && data.isEmpty && errorMessage == null;

  /// 是否有错误
  bool get hasError => errorMessage != null;

  /// 是否为空列表
  bool get isEmpty => data.isEmpty && !isLoading;

  PagedUiState<T> copyWith({
    List<T>? data,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return PagedUiState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  String toString() =>
      'PagedUiState(data: ${data.length}, isLoading: $isLoading, hasMore: $hasMore, page: $currentPage)';
}
