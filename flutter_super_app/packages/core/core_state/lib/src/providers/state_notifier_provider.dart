import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_logging/core_logging.dart';
import '../models/ui_state.dart';

/// StateNotifier Provider 辅助类
///
/// 简化 StateNotifier 的创建和使用
base class UiStateProvider<T> extends StateNotifier<UiState<T>> {
  UiStateProvider() : super(UiState<T>.initial());

  /// 当前数据
  T? get data => state.data;

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 是否有错误
  bool get hasError => state.hasError;

  /// 错误消息
  String? get errorMessage => state.errorMessage;

  /// 是否为初始状态
  bool get isInitial => state.isInitial;

  /// 设置加载状态
  void toLoading() {
    state = UiState<T>.loading();
    Log.i('UiState 进入加载状态: ${runtimeType}');
  }

  /// 设置成功状态
  void toSuccess(T data) {
    state = UiState<T>.success(data);
    Log.i('UiState 进入成功状态: ${runtimeType}');
  }

  /// 设置错误状态
  void toError(String message) {
    state = UiState<T>.error(message);
    Log.e('UiState 进入错误状态: ${runtimeType}, error: $message');
  }

  /// 重置状态
  void reset() {
    state = UiState<T>.initial();
    Log.i('UiState 状态重置: ${runtimeType}');
  }

  /// 执行异步操作
  Future<void> execute(
    Future<T> Function() operation,
  ) async {
    try {
      toLoading();
      final result = await operation();
      toSuccess(result);
    } catch (e) {
      toError(e.toString());
      rethrow;
    }
  }
}

/// 分页状态 Provider
base class PagedStateProvider<T> extends StateNotifier<PagedUiState<T>> {
  PagedStateProvider() : super(PagedUiState<T>.initial());

  /// 当前数据列表
  List<T> get data => state.data;

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 是否有错误
  bool get hasError => state.hasError;

  /// 是否还有更多数据
  bool get hasMore => state.hasMore;

  /// 当前页码
  int get currentPage => state.currentPage;

  /// 是否为空列表
  bool get isEmpty => state.isEmpty;

  /// 设置加载状态
  void toLoading() {
    state = PagedUiState<T>.loading();
    Log.i('PagedUiState 进入加载状态: ${runtimeType}');
  }

  /// 设置成功状态
  void toSuccess(List<T> newData, {bool hasMore = true}) {
    state = PagedUiState<T>.success(newData, hasMore: hasMore);
    Log.i('PagedUiState 进入成功状态: ${runtimeType}, count: ${newData.length}');
  }

  /// 追加数据（用于分页加载更多）
  void appendData(List<T> newData, {bool hasMore = true}) {
    final combinedData = [...state.data, ...newData];
    state = state.copyWith(
      data: combinedData,
      hasMore: hasMore,
      isLoading: false,
      currentPage: state.currentPage + 1,
    );
    Log.i('PagedUiState 追加数据: ${runtimeType}, new count: ${newData.length}, total: ${combinedData.length}');
  }

  /// 设置错误状态
  void toError(String message) {
    state = PagedUiState<T>.error(message);
    Log.e('PagedUiState 进入错误状态: ${runtimeType}, error: $message');
  }

  /// 重置状态
  void reset() {
    state = PagedUiState<T>.initial();
    Log.i('PagedUiState 状态重置: ${runtimeType}');
  }

  /// 刷新数据
  Future<void> refresh(
    Future<List<T>> Function() operation,
  ) async {
    try {
      toLoading();
      final result = await operation();
      toSuccess(result);
    } catch (e) {
      toError(e.toString());
      rethrow;
    }
  }

  /// 加载更多数据
  Future<void> loadMore(
    Future<List<T>> Function(int page) operation,
  ) async {
    if (!hasMore || isLoading) return;

    try {
      state = state.copyWith(isLoading: true);
      final nextPage = state.currentPage + 1;
      final result = await operation(nextPage);

      if (result.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        Log.i('PagedUiState 没有更多数据: ${runtimeType}');
      } else {
        appendData(result, hasMore: result.isNotEmpty);
      }
    } catch (e) {
      toError(e.toString());
      rethrow;
    }
  }
}

// ============================================================================
// 高级分页 Provider（新增）
// ============================================================================

/// 分页状态（增强版）
///
/// 用于高级分页管理，包含更细粒度的状态
final class AdvancedPagedState<T> {
  /// 所有已加载的数据
  final List<T> items;

  /// 是否还有更多数据
  final bool hasMore;

  /// 是否正在刷新（重新加载第一页）
  final bool isRefreshing;

  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 是否正在初始加载
  final bool isLoading;

  /// 错误信息
  final Object? error;

  /// 当前页码（从 1 开始，0 表示未加载）
  final int currentPage;

  const AdvancedPagedState({
    this.items = const [],
    this.hasMore = true,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isLoading = false,
    this.error,
    this.currentPage = 0,
  });

  /// 创建初始状态
  factory AdvancedPagedState.initial() => const AdvancedPagedState();

  /// 是否为空列表
  bool get isEmpty => items.isEmpty;

  /// 是否不为空
  bool get isNotEmpty => items.isNotEmpty;

  /// 是否有任何加载操作正在进行
  bool get hasLoadingAction => isLoading || isRefreshing || isLoadingMore;

  /// 是否有错误
  bool get hasError => error != null;

  /// 复制并更新部分字段
  AdvancedPagedState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isLoading,
    Object? error,
    int? currentPage,
    bool clearError = false,
  }) {
    return AdvancedPagedState<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  String toString() {
    return 'AdvancedPagedState('
        'items: ${items.length}, '
        'hasMore: $hasMore, '
        'isLoading: $isLoading, '
        'isRefreshing: $isRefreshing, '
        'isLoadingMore: $isLoadingMore, '
        'error: $error, '
        'currentPage: $currentPage'
        ')';
  }
}

/// 高级分页数据 Provider
///
/// 自动管理分页逻辑，包括：
/// - 刷新（加载第一页，替换旧数据）
/// - 加载更多（追加数据）
/// - 重试（当前页）
/// - 跳转指定页
/// - 状态管理（加载中、成功、失败）
/// - 是否还有更多数据
/// - 本地数据操作（追加、删除、更新）
///
/// 使用示例：
/// ```dart
/// class UserListNotifier extends AdvancedPagedNotifierProvider<User> {
///   UserListNotifier({required UserRepository repository})
///       : super(
///           pageSize: 20,
///           fetcher: (page, size) => repository.getUsers(page: page, size: size),
///         );
/// }
///
/// final userListProvider = StateNotifierProvider<UserListNotifier, AdvancedPagedState<User>>((ref) {
///   return UserListNotifier(repository: ref.read(repositoryProvider));
/// });
///
/// // 刷新
/// ref.read(userListProvider.notifier).refresh();
///
/// // 加载更多
/// ref.read(userListProvider.notifier).loadMore();
///
/// // 删除某项
/// ref.read(userListProvider.notifier).removeItem((user) => user.id == targetId);
/// ```
base class AdvancedPagedNotifierProvider<T> extends StateNotifier<AdvancedPagedState<T>> {
  /// 每页数据量
  final int pageSize;

  /// 数据获取器
  ///
  /// 参数：
  /// - page: 页码（从 1 开始）
  /// - size: 每页数量
  ///
  /// 返回：该页的数据列表
  final Future<List<T>> Function(int page, int size) fetcher;

  /// 当前页码（从 1 开始，0 表示未加载）
  int _currentPage = 0;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 已加载的所有数据
  List<T> get _items => state.items;

  AdvancedPagedNotifierProvider({
    required this.pageSize,
    required this.fetcher,
  }) : super(AdvancedPagedState<T>.initial()) {
    Log.i('AdvancedPagedNotifierProvider 初始化: pageSize=$pageSize');
  }

  /// 刷新（重新加载第一页，替换旧数据）
  ///
  /// 使用场景：
  /// - 下拉刷新
  /// - 重新进入页面
  /// - 数据可能已过期，需要重新加载
  Future<void> refresh() async {
    // 防止重复操作
    if (state.isLoading || state.isRefreshing) {
      Log.w('已在刷新中，忽略重复请求');
      return;
    }

    Log.i('🔄 刷新数据（加载第 1 页）');

    // 设置刷新状态
    state = state.copyWith(
      isRefreshing: true,
      isLoading: true,
      clearError: true,
    );

    try {
      // 加载第一页
      final result = await fetcher(1, pageSize);

      // 重置状态
      _currentPage = 1;
      _hasMore = result.length >= pageSize;

      Log.i('✅ 刷新成功: 获得 ${result.length} 条数据, hasMore=$_hasMore');

      // 替换数据（不是追加）
      state = AdvancedPagedState<T>(
        items: result,
        hasMore: _hasMore,
        isRefreshing: false,
        isLoadingMore: false,
        isLoading: false,
        currentPage: 1,
        error: null,
      );
    } catch (e, stackTrace) {
      Log.e('❌ 刷新失败', error: e, stackTrace: stackTrace);

      // 保持原数据，只更新错误状态
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
      rethrow;
    }
  }

  /// 加载更多（追加数据）
  ///
  /// 使用场景：
  /// - 用户滚动到底部
  /// - 上拉加载更多
  ///
  /// 注意：
  /// - 如果没有更多数据，不会发起请求
  /// - 如果正在加载，不会重复请求
  Future<void> loadMore() async {
    // 检查条件
    if (state.isLoadingMore) {
      Log.w('正在加载更多，忽略重复请求');
      return;
    }

    if (!_hasMore) {
      Log.i('没有更多数据了');
      return;
    }

    if (state.isRefreshing || state.isLoading) {
      Log.w('正在刷新或初始加载，暂不加载更多');
      return;
    }

    final nextPage = _currentPage + 1;
    Log.i('⬇️ 加载更多（第 $nextPage 页）');

    // 设置加载更多状态
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      // 加载下一页
      final result = await fetcher(nextPage, pageSize);

      // 追加数据（不是替换）
      final newItems = [..._items, ...result];
      _currentPage = nextPage;
      _hasMore = result.length >= pageSize;

      Log.i('✅ 加载更多成功: 获得 ${result.length} 条数据, 总计 ${newItems.length} 条, hasMore=$_hasMore');

      state = AdvancedPagedState<T>(
        items: newItems,
        hasMore: _hasMore,
        isRefreshing: false,
        isLoadingMore: false,
        isLoading: false,
        currentPage: _currentPage,
        error: null,
      );
    } catch (e, stackTrace) {
      Log.e('❌ 加载更多失败', error: e, stackTrace: stackTrace);

      // 保持原数据，只更新错误状态
      state = state.copyWith(
        isLoadingMore: false,
        error: e,
      );
      rethrow;
    }
  }

  /// 重试（重新执行最后一次失败的操作）
  ///
  /// 使用场景：
  /// - 加载失败后，用户点击重试
  Future<void> retry() async {
    if (!state.hasError) {
      Log.w('没有错误，无需重试');
      return;
    }

    Log.i('🔄 重试');

    // 根据当前状态判断是刷新还是加载更多
    if (_currentPage == 0) {
      // 从未加载过，执行初始加载
      await refresh();
    } else if (state.isLoadingMore) {
      // 上次是加载更多失败
      await loadMore();
    } else {
      // 默认执行刷新
      await refresh();
    }
  }

  /// 跳转到指定页码
  ///
  /// 使用场景：
  /// - 用户点击页码跳转
  /// - 搜索后跳转到第 1 页
  ///
  /// 注意：
  /// - 这会清空当前数据，重新加载
  Future<void> goToPage(int page) async {
    if (page < 1) {
      Log.w('页码必须大于 0: $page');
      return;
    }

    Log.i('📄 跳转到第 $page 页');

    // 设置加载状态
    state = state.copyWith(
      isRefreshing: true,
      isLoading: true,
      clearError: true,
    );

    try {
      // 加载指定页
      final result = await fetcher(page, pageSize);

      _currentPage = page;
      _hasMore = result.length >= pageSize;

      Log.i('✅ 跳转成功: 获得 ${result.length} 条数据, page=$page, hasMore=$_hasMore');

      // 替换数据
      state = AdvancedPagedState<T>(
        items: result,
        hasMore: _hasMore,
        isRefreshing: false,
        isLoadingMore: false,
        isLoading: false,
        currentPage: page,
        error: null,
      );
    } catch (e, stackTrace) {
      Log.e('❌ 跳转失败', error: e, stackTrace: stackTrace);

      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
      rethrow;
    }
  }

  /// 清空数据
  ///
  /// 使用场景：
  /// - 搜索前清空旧结果
  /// - 切换分类时清空数据
  void clear() {
    Log.i('🗑️ 清空数据');
    _currentPage = 0;
    _hasMore = true;
    state = AdvancedPagedState<T>.initial();
  }

  /// 追加数据到顶部（不经过网络请求）
  ///
  /// 使用场景：
  /// - 本地新增数据后，直接追加到列表
  /// - 插入数据到列表顶部
  void prependItems(List<T> newItems) {
    Log.i('➕ 在顶部追加 ${newItems.length} 条数据');

    final allItems = [...newItems, ..._items];
    state = state.copyWith(items: allItems);
  }

  /// 追加数据到末尾（不经过网络请求）
  ///
  /// 使用场景：
  /// - 本地新增数据后，直接追加到列表末尾
  void appendItems(List<T> newItems) {
    Log.i('➕ 在末尾追加 ${newItems.length} 条数据');

    final allItems = [..._items, ...newItems];
    state = state.copyWith(items: allItems);
  }

  /// 移除指定数据
  ///
  /// 使用场景：
  /// - 删除某条数据后，从列表中移除
  void removeItem(bool Function(T item) test) {
    final newItems = _items.where((item) => !test(item)).toList();
    Log.i('🗑️ 移除数据: ${_items.length - newItems.length} 条');
    state = state.copyWith(items: newItems);
  }

  /// 更新指定数据
  ///
  /// 使用场景：
  /// - 更新某条数据后，同步到列表
  void updateItem(bool Function(T item) test, T newItem) {
    final index = _items.indexWhere(test);
    if (index >= 0) {
      final newItems = [..._items];
      newItems[index] = newItem;
      Log.i('🔄 更新数据: index=$index');
      state = state.copyWith(items: newItems);
    }
  }
}
