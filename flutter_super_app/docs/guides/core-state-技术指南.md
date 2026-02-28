# Core State 技术指南

## 目录
- [概述](#概述)
- [架构设计](#架构设计)
- [核心组件](#核心组件)
- [使用指南](#使用指南)
- [状态模式对比](#状态模式对比)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)

---

## 概述

`core_state` 是基于 Riverpod 构建的状态管理基础库，提供了一套完整的状态管理解决方案。

### 核心特性

- **分层设计**：提供多种状态抽象层级，满足不同场景需求
- **类型安全**：充分利用 Dart 的类型系统，确保状态安全
- **自动管理**：通过 Provider 自动处理加载/成功/错误状态
- **分页支持**：内置完整的分页列表管理能力
- **调试友好**：提供详细的日志和历史记录功能
- **持久化支持**：支持状态自动保存和恢复

### 设计理念

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │   Widgets     │  │   Widgets     │  │   Widgets     │       │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘       │
│          │                  │                  │                 │
│          │ ref.watch()      │                  │                 │
│          ▼                  ▼                  ▼                 │
├─────────────────────────────────────────────────────────────────┤
│                      State Layer                                │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │ UiState<T>    │  │ PagedUiState  │  │  AppState     │       │
│  │               │  │     <T>       │  │               │       │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘       │
│          │                  │                  │                 │
│          ▼                  ▼                  ▼                 │
├─────────────────────────────────────────────────────────────────┤
│                    Provider Layer                               │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │ UiState       │  │AdvancedPaged  │  │  BaseProvider │       │
│  │ Provider      │  │NotifierProvider│ │               │       │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘       │
│          │                  │                  │                 │
│          ▼                  ▼                  ▼                 │
├─────────────────────────────────────────────────────────────────┤
│                      Domain Layer                                │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │  Repository   │  │   UseCase     │  │   Service     │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 架构设计

### 状态层次结构

```
AppState (抽象基类)
│
├── IdleState         - 空闲状态
├── LoadingState      - 加载中状态
├── SuccessState<T>   - 成功状态（带数据）
├── ErrorState        - 错误状态
└── DataState<T>      - 综合状态（包含所有信息）
    ├── .idle()
    ├── .loading()
    ├── .success()
    └── .error()
```

### Provider 层次结构

```
StateNotifier<T> (Riverpod)
│
├── BaseProvider<T>
│   └── execute() - 自动状态管理
│
├── UiStateProvider<T>
│   ├── toLoading()
│   ├── toSuccess()
│   ├── toError()
│   └── execute()
│
├── PagedStateProvider<T>
│   ├── refresh()     - 刷新（替换数据）
│   ├── loadMore()    - 加载更多（追加数据）
│   ├── retry()       - 重试
│   └── appendData()  - 追加数据
│
├── AdvancedPagedNotifierProvider<T>
│   ├── refresh()     - 重新加载第一页
│   ├── loadMore()    - 加载下一页
│   ├── retry()       - 重试失败操作
│   ├── goToPage()    - 跳转指定页
│   ├── prependItems()- 顶部追加
│   ├── appendItems() - 末尾追加
│   ├── removeItem()  - 移除项目
│   └── updateItem()  - 更新项目
│
└── AsyncNotifier<T>
    └── fetch()       - 简化异步操作
```

---

## 核心组件

### 1. 状态模型

#### AppState - 基础状态模型

适用于需要明确状态类型的场景：

```dart
// 定义状态
base class AuthProvider extends StateNotifier<AppState> {
  AuthProvider() : super(const IdleState());

  Future<void> login(String username, String password) async {
    state = const LoadingState(message: '登录中...');
    try {
      final user = await authService.login(username, password);
      state = SuccessState<User>(user);
    } catch (e) {
      state = ErrorState(e);
    }
  }
}

// 使用
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);

  return switch (authState) {
    IdleState() => Text('请登录'),
    LoadingState() => CircularProgressIndicator(),
    SuccessState(data: final user) => Text('欢迎, ${user.name}'),
    ErrorState() => Text('登录失败'),
  };
}
```

#### UiState<T> - UI 状态模型

适用于 UI 层的状态管理：

```dart
final class UserProfileProvider extends StateNotifier<UiState<User>> {
  UserProfileProvider() : super(UiState<User>.initial());

  Future<void> loadProfile(String userId) async {
    state = UiState<User>.loading();
    try {
      final user = await userService.getProfile(userId);
      state = UiState<User>.success(user);
    } catch (e) {
      state = UiState<User>.error(e.toString());
    }
  }
}

// 使用
Widget build(BuildContext context, WidgetRef ref) {
  final profileState = ref.watch(userProfileProvider);

  if (profileState.isLoading) {
    return const CircularProgressIndicator();
  }

  if (profileState.hasError) {
    return Text('错误: ${profileState.errorMessage}');
  }

  final user = profileState.data;
  if (user == null) {
    return const Text('没有数据');
  }

  return Text('用户: ${user.name}');
}
```

#### PagedUiState<T> - 分页 UI 状态

适用于列表数据的分页加载：

```dart
final class ProductListProvider extends StateNotifier<PagedUiState<Product>> {
  ProductListProvider() : super(PagedUiState<Product>.initial());

  Future<void> loadProducts() async {
    state = PagedUiState<Product>.loading();
    try {
      final products = await productService.getProducts(page: 1);
      state = PagedUiState<Product>.success(products);
    } catch (e) {
      state = PagedUiState<Product>.error(e.toString());
    }
  }
}
```

### 2. Provider 基类

#### BaseProvider<T> - 基础 Provider

提供自动状态管理的 `execute()` 方法：

```dart
final class UserRepository extends BaseProvider<User> {
  final UserService _service;

  UserRepository(this._service);

  Future<void> fetchUser(String userId) async {
    await execute(
      () => _service.getUser(userId),
      loadingMessage: '加载用户信息...',
    );
  }
}

// 自动处理：加载 → 成功/错误
// 不需要手动管理状态转换
```

**执行流程：**

```
execute() 调用
    │
    ▼
setLoading() ──────────────► 状态变为 LoadingState
    │
    ▼
执行 operation()
    │
    ├── 成功 ──► setSuccess() ──► 状态变为 SuccessState<T>
    │
    └── 失败 ──► setError() ────► 状态变为 ErrorState
```

#### UiStateProvider<T> - UI 状态 Provider

```dart
final class SettingsProvider extends UiStateProvider<Settings> {
  final SettingsService _service;

  SettingsProvider(this._service);

  Future<void> loadSettings() async {
    await execute(() => _service.getSettings());
  }

  void updateTheme(String theme) {
    // 手动更新数据
    final current = data;
    if (current != null) {
      toSuccess(current.copyWith(theme: theme));
    }
  }
}
```

#### PagedStateProvider<T> - 分页状态 Provider

```dart
final class CommentProvider extends PagedStateProvider<Comment> {
  final CommentService _service;

  CommentProvider(this._service);

  // 刷新（替换数据）
  Future<void> refresh() async {
    await refresh(() => _service.getComments(page: 1));
  }

  // 加载更多（追加数据）
  Future<void> loadMore() async {
    await loadMore((page) => _service.getComments(page: page));
  }
}
```

#### AdvancedPagedNotifierProvider<T> - 高级分页 Provider

最强大的分页状态管理器：

```dart
final class UserListNotifier extends AdvancedPagedNotifierProvider<User> {
  final UserRepository _repository;

  UserListNotifier({
    required UserRepository repository,
  }) : _repository = repository,
       super(
         pageSize: 20,
         fetcher: (page, size) => repository.getUsers(page: page, size: size),
       );
}

// 使用
final userListProvider = StateNotifierProvider<UserListNotifier, AdvancedPagedState<User>>((ref) {
  return UserListNotifier(repository: ref.read(userRepositoryProvider));
});
```

**状态模型：**

```dart
final class AdvancedPagedState<T> {
  final List<T> items;          // 所有已加载的数据
  final bool hasMore;           // 是否还有更多
  final bool isRefreshing;      // 是否正在刷新
  final bool isLoadingMore;     // 是否正在加载更多
  final bool isLoading;         // 是否正在初始加载
  final Object? error;          // 错误信息
  final int currentPage;        // 当前页码
}
```

**可用方法：**

| 方法 | 说明 | 场景 |
|------|------|------|
| `refresh()` | 刷新数据（替换） | 下拉刷新、重新进入页面 |
| `loadMore()` | 加载更多（追加） | 滚动到底部 |
| `retry()` | 重试失败操作 | 用户点击重试 |
| `goToPage(int)` | 跳转指定页 | 点击页码 |
| `clear()` | 清空数据 | 搜索前清空 |
| `prependItems(list)` | 顶部追加 | 新增数据后插入 |
| `appendItems(list)` | 末尾追加 | 批量添加 |
| `removeItem(test)` | 移除项目 | 删除操作 |
| `updateItem(test, item)` | 更新项目 | 编辑操作 |

### 3. AsyncNotifier<T> - 异步通知器

简化异步操作的状态管理：

```dart
final class DashboardNotifier extends AsyncNotifier<Dashboard> {
  final DashboardService _service;

  DashboardNotifier(this._service);

  Future<void> loadDashboard() async {
    await fetch(
      () => _service.getDashboard(),
      resetOnError: true,  // 失败时重置状态
    );
  }
}

// 使用
final dashboardProvider = StateNotifierProvider<DashboardNotifier, UiState<Dashboard>>((ref) {
  return DashboardNotifier(ref.read(dashboardService));
});
```

### 4. 调试工具

#### ProviderDebugMixin<T> - 调试日志混入

```dart
final class MyProvider extends StateNotifier<UiState<User>>
    with ProviderDebugMixin<UiState<User>> {
  MyProvider() : super(UiState<User>.initial());

  void loadData() {
    // 状态变更会自动输出详细日志
    state = UiState.loading();
    // ...
  }
}
```

**日志输出：**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Provider: MyProvider
📅 时间: 14:32:15.123
📥 旧状态: UiState(data: null, isLoading: false, error: null)
📤 新状态: Loading(message: 加载中...)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### StateHistoryMixin<T> - 状态历史记录

```dart
final class DebuggableProvider extends StateNotifier<UiState<User>>
    with StateHistoryMixin<UiState<User>> {
  DebuggableProvider() : super(UiState<User>.initial()) {
    maxHistory = 100;  // 设置最大历史记录数
  }

  void exportHistory() {
    final json = getHistoryJson();
    Log.d('状态历史: $json');
  }
}
```

### 5. 持久化工具

#### StatePersistence - 状态持久化

```dart
// 保存状态
await StatePersistence.save('user_settings', {'theme': 'dark', 'language': 'zh'});

// 恢复状态
final settings = await StatePersistence.restore<Map<String, dynamic>>('user_settings');

// 带过期时间的保存
await StatePersistence.saveWithExpiry('cache_data', data, Duration(hours: 1));

// 检查是否存在
final exists = await StatePersistence.exists('user_settings');
```

#### StatePersistenceMixin<T> - 自动持久化混入

```dart
final class SettingsProvider extends StateNotifier<UiState<Settings>>
    with StatePersistenceMixin<UiState<Settings>> {
  SettingsProvider() : super(UiState<Settings>.initial()) {
    persistenceKey = 'app_settings';  // 设置持久化键
    restoreState();  // 自动恢复
  }

  @override
  void dispose() {
    saveState();  // 自动保存
    super.dispose();
  }

  // 状态变更会自动保存到本地
}
```

---

## 使用指南

### 场景 1：简单数据获取

使用 `UiStateProvider<T>`：

```dart
// 1. 定义 Provider
final class UserProfileProvider extends UiStateProvider<User> {
  final UserService _service;

  UserProfileProvider(this._service);

  Future<void> loadProfile(String userId) async {
    await execute(() => _service.getProfile(userId));
  }
}

// 2. 创建 Provider
final userProfileProvider = StateNotifierProvider<UserProfileProvider, UiState<User>>((ref) {
  return UserProfileProvider(ref.read(userService));
});

// 3. UI 中使用
class UserProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    return profileState.when(
      initial: () => const Text('点击按钮加载'),
      loading: () => const CircularProgressIndicator(),
      success: (user) => Text('用户: ${user.name}'),
      error: (message) => Text('错误: $message'),
    );
  }
}
```

### 场景 2：分页列表

使用 `AdvancedPagedNotifierProvider<T>`：

```dart
// 1. 定义 Notifier
final class ProductListNotifier extends AdvancedPagedNotifierProvider<Product> {
  final ProductRepository _repository;

  ProductListNotifier({required ProductRepository repository})
      : _repository = repository,
        super(
          pageSize: 20,
          fetcher: (page, size) => _repository.getProducts(page: page, size: size),
        );
}

// 2. 创建 Provider
final productListProvider = StateNotifierProvider<ProductListNotifier, AdvancedPagedState<Product>>((ref) {
  return ProductListNotifier(repository: ref.read(productRepositoryProvider));
});

// 3. UI 中使用
class ProductListPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始加载
    ref.read(productListProvider.notifier).refresh();

    // 监听滚动，自动加载更多
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(productListProvider.notifier).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pagedState = ref.watch(productListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(productListProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: pagedState.items.length + (pagedState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == pagedState.items.length) {
            return const CircularProgressIndicator();
          }
          return ProductTile(product: pagedState.items[index]);
        },
      ),
    );
  }
}
```

### 场景 3：表单编辑

```dart
final class FormProvider extends StateNotifier<UiState<FormData>> {
  FormProvider() : super(UiState<FormData>.success(FormData()));

  void updateName(String name) {
    final current = data;
    if (current != null) {
      state = UiState<FormData>.success(current.copyWith(name: name));
    }
  }

  void updateEmail(String email) {
    final current = data;
    if (current != null) {
      state = UiState<FormData>.success(current.copyWith(email: email));
    }
  }

  Future<void> submit() async {
    final current = data;
    if (current == null) return;

    state = UiState<FormData>.loading();
    try {
      await formService.submit(current);
      state = UiState<FormData>.success(current);
    } catch (e) {
      state = UiState<FormData>.error(e.toString());
    }
  }
}
```

### 场景 4：多状态组合

使用多个 Provider 组合：

```dart
// 1. 定义多个 Provider
final authProvider = StateNotifierProvider<AuthProvider, AppState>((ref) {
  return AuthProvider(ref.read(authService));
});

final settingsProvider = StateNotifierProvider<SettingsProvider, UiState<Settings>>((ref) {
  return SettingsProvider(ref.read(settingsService));
});

// 2. UI 中组合使用
class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);

    // 根据多个状态决定显示内容
    if (authState is! SuccessState<User>) {
      return const LoginPage();
    }

    if (settingsState.isLoading) {
      return const CircularProgressIndicator();
    }

    return Content(user: authState.data, settings: settingsState.data);
  }
}
```

---

## 状态模式对比

### AppState vs UiState vs DataState

| 特性 | AppState | UiState<T> | DataState<T> |
|------|----------|------------|--------------|
| **状态类型** | 独立状态类 | 综合状态类 | 综合状态类 |
| **类型安全** | 高（使用 is 检查） | 中（使用 getter） | 中（使用 getter） |
| **模式匹配** | 支持 switch 表达式 | 不支持 | 不支持 |
| **适用场景** | 需要明确状态类型 | UI 层状态管理 | 复杂状态组合 |
| **空值安全** | 需要类型转换 | 使用 ? 可空 | 使用 ? 可空 |

**选择建议：**
- **AppState**：需要明确区分状态类型，使用 switch 表达式
- **UiState<T>**：UI 层简单状态管理
- **DataState<T>**：需要在保留数据的同时显示加载状态

### Provider 选择指南

```
┌─────────────────────────────────────────────────────────────────┐
│                        Provider 选择决策树                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  是否需要分页？                                                   │
│     │                                                           │
│     ├── 是 ──► 数据量大（>100）？                                │
│     │         │                                                 │
│     │         ├── 是 ──► AdvancedPagedNotifierProvider<T>       │
│     │         │          (完整分页功能)                         │
│     │         │                                                 │
│     │         └── 否 ──► PagedStateProvider<T>                  │
│     │                   (简单分页功能)                          │
│     │                                                           │
│     └── 否 ──► 需要明确状态类型？                                │
│               │                                                 │
│               ├── 是 ──► BaseProvider<T> + AppState             │
│               │          (类型安全，模式匹配)                   │
│               │                                                 │
│               └── 否 ──► UiStateProvider<T>                     │
│                          (简单易用)                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 最佳实践

### 1. 单一职责原则

每个 Provider 只负责一个状态域：

```dart
// ❌ 不好的做法：一个 Provider 管理多个不相关的状态
final class BadProvider extends StateNotifier<UiState<CombinedData>> {
  // 同时管理用户、设置、通知等
}

// ✅ 好的做法：拆分为多个 Provider
final class UserProfileProvider extends UiStateProvider<User> { }
final class SettingsProvider extends UiStateProvider<Settings> { }
final class NotificationProvider extends UiStateProvider<List<Notification>> { }
```

### 2. 数据不可变性

```dart
// ✅ 好的做法：使用 copyWith 创建新状态
state = state.copyWith(data: newData);

// ❌ 不好的做法：直接修改状态
state.data?.name = 'new name';
```

### 3. 错误处理

```dart
// ✅ 好的做法：详细错误信息
try {
  final result = await service.getData();
  toSuccess(result);
} catch (e, stackTrace) {
  Log.e('操作失败', error: e, stackTrace: stackTrace);
  toError('操作失败：${e.toString()}');
  // 可选：上报错误监控
  ErrorReporting.reportError(e, stackTrace);
}

// ❌ 不好的做法：吞掉错误
try {
  final result = await service.getData();
  toSuccess(result);
} catch (e) {
  // 什么都不做
}
```

### 4. 避免过度重建

```dart
// ❌ 不好的做法：整个 Provider 重建
final filterProvider = StateProvider((ref) => Filter.initial());
final listProvider = StateNotifierProvider<ListProvider, List<Item>>((ref) {
  final filter = ref.watch(filterProvider);  // filter 变化会重建整个 Provider
  return ListProvider(filter);
});

// ✅ 好的做法：Provider 内部处理筛选
final listProvider = StateNotifierProvider<ListProvider, UiState<List<Item>>>((ref) {
  return ListProvider();
});

// 在 UI 中处理筛选
@override
Widget build(BuildContext context, WidgetRef ref) {
  final listState = ref.watch(listProvider);
  final filter = ref.watch(filterProvider);

  final filteredItems = listState.data?.where(filter.matches).toList();
  // ...
}
```

### 5. 持久化策略

```dart
// ✅ 好的做法：持久化关键状态
final class SettingsProvider extends StateNotifier<UiState<Settings>>
    with StatePersistenceMixin<UiState<Settings>> {
  SettingsProvider() : super(UiState<Settings>.initial()) {
    persistenceKey = 'app_settings';
    restoreState();
  }
}

// ❌ 不好的做法：持久化所有状态（包括临时状态）
final class TempDataProvider extends StateNotifier<UiState<TempData>>
    with StatePersistenceMixin<UiState<TempData>> {
  // 临时数据不需要持久化
}
```

---

## 常见问题

### Q1: 何时使用 `BaseProvider` vs `UiStateProvider`？

**A:**
- **BaseProvider<AppState>**：需要明确状态类型，使用 switch 表达式进行模式匹配
- **UiStateProvider<T>**：UI 层简单状态管理，不需要明确区分状态类型

```dart
// BaseProvider - 类型明确
return switch (state) {
  IdleState() => Text('空闲'),
  LoadingState() => CircularProgressIndicator(),
  SuccessState(data: final user) => Text(user.name),
  ErrorState() => Text('错误'),
};

// UiStateProvider - 简单判断
if (state.isLoading) return CircularProgressIndicator();
if (state.hasError) return Text(state.errorMessage!);
return Text(state.data!.name);
```

### Q2: 如何处理父子状态？

**A:** 使用 `ProviderContainer` 或 `ref.watch` 建立依赖关系：

```dart
// 子 Provider 依赖父 Provider
final childProvider = StateNotifierProvider<ChildProvider, UiState<ChildData>>((ref) {
  final parent = ref.watch(parentProvider);
  return ChildProvider(parent.data);
});
```

### Q3: 分页数据如何缓存？

**A:** 结合 `StatePersistence` 使用：

```dart
final class CachedProductListProvider extends AdvancedPagedNotifierProvider<Product>
    with StatePersistenceMixin<AdvancedPagedState<Product>> {
  CachedProductListProvider({required ProductRepository repository})
      : super(
          pageSize: 20,
          fetcher: (page, size) => repository.getProducts(page: page, size: size),
        ) {
    persistenceKey = 'product_list_cache';
    restoreState();
  }
}
```

### Q4: 如何实现乐观更新？

**A:** 先更新本地状态，再同步到服务器：

```dart
Future<void> addComment(Comment comment) async {
  // 1. 立即更新本地状态
  final current = state;
  if (current is SuccessState<List<Comment>>) {
    final newComments = [comment, ...current.data];
    state = SuccessState<List<Comment>>(newComments);
  }

  // 2. 发送到服务器
  try {
    await commentService.addComment(comment);
  } catch (e) {
    // 失败时回滚
    state = current;
    toError('添加失败：${e.toString()}');
  }
}
```

### Q5: 状态更新太频繁导致性能问题？

**A:** 使用防抖或节流：

```dart
final class SearchProvider extends StateNotifier<UiState<List<Result>>> {
  Timer? _debounceTimer;

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      state = UiState<List<Result>>.loading();
      try {
        final results = await searchService.search(query);
        state = UiState<List<Result>>.success(results);
      } catch (e) {
        state = UiState<List<Result>>.error(e.toString());
      }
    });
  }
}
```

---

## 与其他状态管理方案对比

### vs Riverpod 原生

| 特性 | core_state | Riverpod 原生 |
|------|------------|---------------|
| 状态模型 | 内置状态模型 | 需要自己定义 |
| 分页支持 | 内置完整分页 | 需要自己实现 |
| 持久化 | 内置支持 | 需要额外集成 |
| 调试工具 | 内置日志和历史 | 需要手动添加 |
| 学习曲线 | 低（封装完善） | 中（需要理解概念） |

### vs Provider

| 特性 | core_state (Riverpod) | Provider |
|------|----------------------|----------|
| 状态监听 | `ref.watch()` | `context.watch()` |
| 状态获取 | 无需 BuildContext | 需要 BuildContext |
| 作用域控制 | 更灵活 | 依赖 InheritedWidget |
| 编译安全 | 高（编译时检查） | 中（运行时检查） |
| 测试友好性 | 高（无需 Widget） | 中（需要 Widget 树） |

### vs GetX

| 特性 | core_state (Riverpod) | GetX |
|------|----------------------|------|
| 状态管理 | 声明式 | 响应式 |
| 依赖注入 | Provider 模式 | Get.find() |
| 代码分离 | 好（分层清晰） | 中（容易耦合） |
| 学习曲线 | 中 | 低（简单直接） |
| 类型安全 | 高 | 中（字符串依赖） |

### vs BLoC

| 特性 | core_state (Riverpod) | BLoC |
|------|----------------------|------|
| 状态管理 | StateNotifier | Bloc |
| 事件处理 | 直接调用方法 | 需要定义 Event |
| 代码量 | 少（精简） | 多（样板代码多） |
| 学习曲线 | 中 | 高（概念多） |
| 调试工具 | 内置 | 需要 BlocObserver |

---

## 总结

`core_state` 提供了一套完整的状态管理解决方案：

1. **灵活的状态模型**：AppState、UiState、DataState 适应不同场景
2. **强大的 Provider 基类**：BaseProvider、UiStateProvider、PagedStateProvider 等
3. **完善的分页支持**：AdvancedPagedNotifierProvider 提供完整分页功能
4. **丰富的调试工具**：日志、历史记录、状态持久化
5. **类型安全**：充分利用 Dart 类型系统

选择合适的状态模型和 Provider 基类，可以大大简化状态管理代码，提高开发效率。
