# Core Cache 技术指南

## 目录
- [概述](#概述)
- [架构设计](#架构设计)
- [核心组件](#核心组件)
- [使用指南](#使用指南)
- [API 参考](#api-参考)
- [最佳实践](#最佳实践)

---

## 概述

`core_cache` 是一个统一的缓存管理库，提供内存缓存和持久化缓存的双重支持，简化数据存储操作。

### 核心特性

- **双重缓存**：内存缓存（快速）+ 持久化缓存（持久）
- **类型安全**：支持泛型和类型推断
- **过期机制**：支持缓存过期时间设置
- **自动序列化**：JSON 对象自动序列化/反序列化
- **异常处理**：统一的缓存异常体系
- **日志记录**：详细的操作日志

### 包结构

```
core_cache
├── lib/
│   ├── src/
│   │   ├── cache/
│   │   │   ├── cache_key.dart      # 缓存键类
│   │   │   ├── cache_entry.dart    # 缓存条目
│   │   │   └── cache_manager.dart  # 缓存管理器
│   │   ├── storage/
│   │   │   └── storage_manager.dart # 存储管理器
│   │   └── exceptions/
│   │       └── cache_exceptions.dart # 缓存异常
│   └── core_cache.dart
└── test/
```

---

## 架构设计

### 缓存层次结构

```
┌─────────────────────────────────────────────────────────────────┐
│                      Application Layer                          │
│                                                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │   Features    │  │   Features    │  │   Features    │       │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘       │
│          │                  │                  │                 │
└──────────┼──────────────────┼──────────────────┼─────────────────┘
           │                  │                  │
           ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CacheManager                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              统一缓存接口                                │   │
│  │  - set/get/remove/clear                                  │   │
│  │  - 类型安全（CacheKey<T>）                               │   │
│  │  - 自动路由（内存/持久化）                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│           │                          │                         │
│           ▼                          ▼                         │
│  ┌───────────────┐          ┌───────────────┐                │
│  │  MemoryCache  │          │StorageManager │                │
│  │               │          │               │                │
│  │ - Map 内存    │          │- SharedPreferences│            │
│  │ - 快速访问    │          │- 持久化存储   │                │
│  │ - 支持过期    │          │- 跨进程共享   │                │
│  └───────────────┘          └───────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

### 数据流程

```
写入流程:
应用 -> CacheManager.set() -> 判断 persist 参数
   ├── true  -> StorageManager.setString() -> SharedPreferences
   └── false -> MemoryCache.set() -> Map 内存

读取流程:
应用 -> CacheManager.get() -> 判断 persist 参数
   ├── true  -> StorageManager.getString() -> SharedPreferences
   └── false -> MemoryCache.get() -> Map 内存 -> 检查过期
```

---

## 核心组件

### 1. CacheKey<T> - 缓存键

类型安全的缓存键定义。

```dart
final class CacheKey<T> {
  final String key;
  final T? defaultValue;
  const CacheKey(this.key, {this.defaultValue});
}
```

**使用示例：**

```dart
// 定义类型安全的缓存键
final accessTokenKey = CacheKey<String>('access_token');
final userIdKey = CacheKey<int>('user_id', defaultValue: 0);
final isLoggedInKey = CacheKey<bool>('is_logged_in', defaultValue: false);

// 使用（编译时类型检查）
await cache.set(accessTokenKey, 'xxx-token');
final token = await cache.get(accessTokenKey);  // 返回 String?
```

### 2. CacheEntry<T> - 缓存条目

包装缓存数据，支持过期时间。

```dart
final class CacheEntry<T> {
  final T data;
  final int? expireTimeMs;
  final DateTime createdAt;

  // 是否已过期
  bool get isExpired;

  // 剩余有效时间（毫秒）
  int? get remainingTimeMs;

  // 剩余有效时间（秒）
  int? get remainingTimeSeconds;
}
```

**使用示例：**

```dart
// 创建永不过期的缓存条目
final entry1 = CacheEntry(data: 'some data');

// 创建带过期时间的缓存条目（1小时）
final entry2 = CacheEntry.withExpiry(
  'some data',
  expiry: Duration(hours: 1),
);

// 检查是否过期
if (entry2.isExpired) {
  print('缓存已过期');
}

// 获取剩余时间
print('剩余时间: ${entry2.remainingTimeSeconds} 秒');
```

### 3. MemoryCache - 内存缓存

基于 Map 的内存缓存，支持过期时间。

#### API 方法

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `set<T>(String, T, {Duration?})` | 设置缓存 | void |
| `get<T>(String)` | 获取缓存 | T? |
| `remove(String)` | 删除缓存 | void |
| `clear()` | 清空所有缓存 | void |
| `containsKey(String)` | 检查键是否存在 | bool |
| `keys` | 获取所有键 | Set<String> |

**使用示例：**

```dart
final memoryCache = MemoryCache();

// 设置缓存
memoryCache.set('user', {'name': 'Alice', 'age': 25});

// 设置带过期时间的缓存（5分钟）
memoryCache.set('temp_data', 'data', expiry: Duration(minutes: 5));

// 获取缓存
final user = memoryCache.get<Map<String, dynamic>>('user');

// 检查是否存在
if (memoryCache.containsKey('user')) {
  print('用户缓存存在');
}

// 删除缓存
memoryCache.remove('user');

// 清空所有缓存
memoryCache.clear();
```

### 4. StorageManager - 持久化存储

基于 SharedPreferences 的持久化存储。

#### API 方法

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `setString(String, String)` | 保存字符串 | Future<bool> |
| `getString(String)` | 获取字符串 | Future<String?> |
| `setInt(String, int)` | 保存整数 | Future<bool> |
| `getInt(String)` | 获取整数 | Future<int?> |
| `setBool(String, bool)` | 保存布尔值 | Future<bool> |
| `getBool(String)` | 获取布尔值 | Future<bool?> |
| `setDouble(String, double)` | 保存双精度浮点数 | Future<bool> |
| `getDouble(String)` | 获取双精度浮点数 | Future<double?> |
| `setStringList(String, List<String>)` | 保存字符串列表 | Future<bool> |
| `getStringList(String)` | 获取字符串列表 | Future<List<String>?> |
| `setJson(String, Map)` | 保存 JSON 对象 | Future<bool> |
| `getJson(String)` | 获取 JSON 对象 | Future<Map<String, dynamic>?> |
| `remove(String)` | 删除指定键 | Future<bool> |
| `clear()` | 清空所有缓存 | Future<bool> |
| `containsKey(String)` | 检查键是否存在 | Future<bool> |
| `getKeys()` | 获取所有键 | Future<Set<String>> |

**使用示例：**

```dart
final storage = StorageManager();

// 基本类型
await storage.setString('username', 'alice');
await storage.setInt('age', 25);
await storage.setBool('is_logged_in', true);
await storage.setDouble('price', 99.99);

// 字符串列表
await storage.setStringList('tags', ['dart', 'flutter', 'cache']);

// JSON 对象
await storage.setJson('user', {
  'name': 'Alice',
  'age': 25,
  'email': 'alice@example.com',
});

// 获取数据
final username = await storage.getString('username');
final age = await storage.getInt('age');
final user = await storage.getJson('user');

// 删除数据
await storage.remove('username');

// 清空所有缓存
await storage.clear();
```

### 5. CacheManager - 缓存管理器

统一管理内存缓存和持久化缓存。

#### API 方法

| 方法 | 说明 | 返回类型 |
|------|------|---------|
| `memory` | 内存缓存实例 | MemoryCache |
| `storage` | 存储管理器实例 | StorageManager |
| `setMemory<T>(String, T, {Duration?})` | 设置内存缓存 | void |
| `getMemory<T>(String)` | 获取内存缓存 | T? |
| `setStorage<T>(String, T)` | 设置持久化缓存 | Future<void> |
| `getStorage<T>(String)` | 获取持久化缓存 | Future<T?> |
| `set<T>(CacheKey<T>, T, {bool})` | 设置缓存（类型安全） | Future<void> |
| `get<T>(CacheKey<T>, {bool})` | 获取缓存（类型安全） | Future<T?> |
| `getOrElse<T>(CacheKey<T>, {bool})` | 获取缓存或默认值 | Future<T> |
| `remove(String)` | 删除缓存 | Future<void> |
| `delete(String)` | 删除缓存 | Future<void> |
| `removeBatch(List<String>)` | 批量删除缓存 | Future<void> |
| `clear()` | 清空所有缓存 | Future<void> |
| `containsKey(String)` | 检查键是否存在 | Future<bool> |

### 6. 缓存异常

| 异常类 | 错误码 | 说明 |
|--------|--------|------|
| `CacheReadException` | `CACHE_READ_ERROR` | 缓存读取失败 |
| `CacheWriteException` | `CACHE_WRITE_ERROR` | 缓存写入失败 |
| `CacheDeleteException` | `CACHE_DELETE_ERROR` | 缓存删除失败 |
| `CacheExpiredException` | `CACHE_EXPIRED` | 缓存已过期 |
| `CacheNotFoundException` | `CACHE_NOT_FOUND` | 缓存不存在 |

---

## 使用指南

### 场景 1：用户登录状态管理

```dart
class AuthManager {
  final CacheManager _cache = CacheManager();

  // 定义缓存键
  static const accessTokenKey = CacheKey<String>('access_token');
  static const refreshTokenKey = CacheKey<String>('refresh_token');
  static const userIdKey = CacheKey<int>('user_id');
  static const isLoggedInKey = CacheKey<bool>('is_logged_in', defaultValue: false);

  // 保存登录信息
  Future<void> saveLoginInfo({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    await _cache.set(accessTokenKey, accessToken);
    await _cache.set(refreshTokenKey, refreshToken);
    await _cache.set(userIdKey, userId);
    await _cache.set(isLoggedInKey, true);
  }

  // 获取访问 Token
  Future<String?> getAccessToken() async {
    return await _cache.get(accessTokenKey);
  }

  // 获取用户 ID
  Future<int> getUserId() async {
    return await _cache.getOrElse(userIdKey);
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await _cache.getOrElse(isLoggedInKey);
  }

  // 清除登录信息
  Future<void> clearLoginInfo() async {
    await _cache.remove('access_token');
    await _cache.remove('refresh_token');
    await _cache.remove('user_id');
    await _cache.set(isLoggedInKey, false);
  }
}
```

### 场景 2：临时数据缓存（内存）

```dart
class DataLoader {
  final CacheManager _cache = CacheManager();

  // 加载数据（带内存缓存）
  Future<List<User>> loadUsers() async {
    // 尝试从内存缓存获取
    final cached = _cache.getMemory<List<User>>('users');
    if (cached != null) {
      return cached;
    }

    // 从网络加载
    final users = await apiClient.getUsers();

    // 缓存到内存（5分钟过期）
    _cache.setMemory('users', users, expiry: Duration(minutes: 5));

    return users;
  }

  // 刷新数据
  Future<void> refreshUsers() async {
    final users = await apiClient.getUsers();
    _cache.setMemory('users', users, expiry: Duration(minutes: 5));
  }
}
```

### 场景 3：用户设置持久化

```dart
class SettingsManager {
  final CacheManager _cache = CacheManager();

  // 定义缓存键
  static const themeKey = CacheKey<String>('theme', defaultValue: 'system');
  static const languageKey = CacheKey<String>('language', defaultValue: 'zh-CN');
  static const notificationEnabledKey = CacheKey<bool>('notification_enabled', defaultValue: true);

  // 获取主题
  Future<String> getTheme() async {
    return await _cache.getOrElse(themeKey);
  }

  // 设置主题
  Future<void> setTheme(String theme) async {
    await _cache.set(themeKey, theme);
  }

  // 获取语言
  Future<String> getLanguage() async {
    return await _cache.getOrElse(languageKey);
  }

  // 设置语言
  Future<void> setLanguage(String language) async {
    await _cache.set(languageKey, language);
  }

  // 获取通知设置
  Future<bool> getNotificationEnabled() async {
    return await _cache.getOrElse(notificationEnabledKey);
  }

  // 设置通知
  Future<void> setNotificationEnabled(bool enabled) async {
    await _cache.set(notificationEnabledKey, enabled);
  }
}
```

### 场景 4：分页数据缓存

```dart
class PaginatedCache {
  final CacheManager _cache = CacheManager();

  // 生成分页缓存键
  String _getPageKey(String endpoint, int page) {
    return '${endpoint}_page_$page';
  }

  // 缓存分页数据
  Future<void> cachePageData(String endpoint, int page, List<dynamic> data) async {
    final key = _getPageKey(endpoint, page);
    await _cache.setStorage(key, {
      'data': data,
      'page': page,
      'cached_at': DateTime.now().toIso8601String(),
    });
  }

  // 获取分页数据
  Future<List<dynamic>?> getPageData(String endpoint, int page) async {
    final key = _getPageKey(endpoint, page);
    final cached = await _cache.getStorage<Map<String, dynamic>>(key);
    if (cached == null) return null;

    // 检查缓存是否过期（1小时）
    final cachedAt = DateTime.parse(cached['cached_at']);
    if (DateTime.now().difference(cachedAt) > Duration(hours: 1)) {
      await _cache.remove(key);
      return null;
    }

    return List<dynamic>.from(cached['data']);
  }

  // 清除指定端点的所有分页缓存
  Future<void> clearPageCache(String endpoint) async {
    final allKeys = await _cache.storage.getKeys();
    final pageKeys = allKeys.where((key) => key.startsWith('${endpoint}_page_')).toList();
    await _cache.removeBatch(pageKeys);
  }
}
```

### 场景 5：双重缓存策略

```dart
class SmartCache {
  final CacheManager _cache = CacheManager();

  /// 多级缓存获取数据
  /// 1. 先从内存缓存获取
  /// 2. 内存没有则从持久化缓存获取
  /// 3. 都没有则从网络获取并缓存
  Future<T> get<T>(String key, Future<T> Function() fetcher) async {
    // 1. 内存缓存
    final memoryData = _cache.getMemory<T>(key);
    if (memoryData != null) {
      Log.i('内存缓存命中: $key');
      return memoryData;
    }

    // 2. 持久化缓存
    final storageData = await _cache.getStorage<T>(key);
    if (storageData != null) {
      Log.i('持久化缓存命中: $key');
      // 同时更新到内存缓存
      _cache.setMemory(key, storageData, expiry: Duration(minutes: 5));
      return storageData;
    }

    // 3. 从网络获取
    Log.i('从网络获取: $key');
    final data = await fetcher();

    // 缓存到内存和持久化
    _cache.setMemory(key, data, expiry: Duration(minutes: 5));
    await _cache.setStorage(key, data);

    return data;
  }

  /// 刷新数据
  Future<void> refresh<T>(String key, Future<T> Function() fetcher) async {
    final data = await fetcher();
    _cache.setMemory(key, data, expiry: Duration(minutes: 5));
    await _cache.setStorage(key, data);
  }

  /// 清除数据
  Future<void> clear(String key) async {
    _cache.memory.remove(key);
    await _cache.storage.remove(key);
  }
}

// 使用示例
final smartCache = SmartCache();

// 获取用户信息
final user = await smartCache.get('user_info', () => apiClient.getUserInfo());

// 刷新用户信息
await smartCache.refresh('user_info', () => apiClient.getUserInfo());
```

---

## API 参考

### CacheKey 构造函数

```dart
const CacheKey(
  String key,      // 键名
  {T? defaultValue} // 可选默认值
)
```

### CacheEntry 构造函数

```dart
CacheEntry({
  required T data,           // 缓存数据
  int? expireTimeMs,        // 过期时间（毫秒）
  DateTime? createdAt,      // 创建时间
})

// 工厂构造函数
CacheEntry.withExpiry(
  T data,
  {required Duration expiry} // 过期时长
)
```

### MemoryCache 方法

| 方法 | 签名 |
|------|------|
| set | `void set<T>(String key, T data, {Duration? expiry})` |
| get | `T? get<T>(String key)` |
| remove | `void remove(String key)` |
| clear | `void clear()` |
| containsKey | `bool containsKey(String key)` |
| keys | `Set<String> get keys` |

### StorageManager 方法

| 方法 | 签名 |
|------|------|
| setString | `Future<bool> setString(String key, String value)` |
| getString | `Future<String?> getString(String key)` |
| setInt | `Future<bool> setInt(String key, int value)` |
| getInt | `Future<int?> getInt(String key)` |
| setBool | `Future<bool> setBool(String key, bool value)` |
| getBool | `Future<bool?> getBool(String key)` |
| setDouble | `Future<bool> setDouble(String key, double value)` |
| getDouble | `Future<double?> getDouble(String key)` |
| setStringList | `Future<bool> setStringList(String key, List<String> value)` |
| getStringList | `Future<List<String>?> getStringList(String key)` |
| setJson | `Future<bool> setJson(String key, Map<String, dynamic> value)` |
| getJson | `Future<Map<String, dynamic>?> getJson(String key)` |
| remove | `Future<bool> remove(String key)` |
| clear | `Future<bool> clear()` |
| containsKey | `Future<bool> containsKey(String key)` |
| getKeys | `Future<Set<String>> getKeys()` |

### CacheManager 方法

| 方法 | 签名 |
|------|------|
| setMemory | `void setMemory<T>(String key, T data, {Duration? expiry})` |
| getMemory | `T? getMemory<T>(String key)` |
| setStorage | `Future<void> setStorage<T>(String key, T data)` |
| getStorage | `Future<T?> getStorage<T>(String key)` |
| set | `Future<void> set<T>(CacheKey<T> key, T value, {bool persist = true})` |
| get | `Future<T?> get<T>(CacheKey<T> key, {bool persist = true})` |
| getOrElse | `Future<T> getOrElse<T>(CacheKey<T> key, {bool persist = true})` |
| remove | `Future<void> remove(String key)` |
| delete | `Future<void> delete(String key)` |
| removeBatch | `Future<void> removeBatch(List<String> keys)` |
| clear | `Future<void> clear()` |
| containsKey | `Future<bool> containsKey(String key)` |

---

## 最佳实践

### 1. 合理选择缓存类型

```dart
// ✅ 好的做法：根据数据特性选择缓存类型

// 用户登录信息 - 持久化（应用重启后仍然有效）
await cache.setStorage('access_token', token);

// 临时数据 - 内存（快速访问，应用重启后清除）
cache.setMemory('temp_list', data, expiry: Duration(minutes: 5));

// 用户设置 - 持久化
await cache.setStorage('theme', theme);

// ❌ 不好的做法：所有数据都用持久化
cache.setStorage('temp_data', data); // 应该用内存缓存
```

### 2. 使用类型安全的 CacheKey

```dart
// ✅ 好的做法：使用 CacheKey
final userIdKey = CacheKey<int>('user_id', defaultValue: 0);
await cache.set(userIdKey, 123);
final userId = await cache.getOrElse(userIdKey); // 类型安全

// ❌ 不好的做法：直接使用字符串
await cache.setStorage('user_id', 123);
final userId = await cache.getStorage<int>('user_id'); // 容易出错
```

### 3. 设置合理的过期时间

```dart
// ✅ 好的做法：根据数据更新频率设置过期时间

// 频繁变化的数据 - 短过期时间
cache.setMemory('stock_price', price, expiry: Duration(minutes: 1));

// 偶尔变化的数据 - 中等过期时间
cache.setMemory('news_list', news, expiry: Duration(hours: 1));

// 很少变化的数据 - 长过期时间或永不过期
await cache.setStorage('user_profile', profile);

// ❌ 不好的做法：所有数据都设置相同的过期时间
cache.setMemory('data', data, expiry: Duration(hours: 24));
```

### 4. 统一管理缓存键

```dart
// ✅ 好的做法：集中定义缓存键
abstract class CacheKeys {
  static const accessToken = CacheKey<String>('access_token');
  static const userId = CacheKey<int>('user_id');
  static const theme = CacheKey<String>('theme', defaultValue: 'system');
}

// 使用
await cache.set(CacheKeys.accessToken, token);

// ❌ 不好的做法：字符串散落在各处
await cache.setStorage('access_token', token); // 容易拼写错误
await cache.setStorage('accessToken', token);   // 不一致
```

### 5. 处理缓存异常

```dart
// ✅ 好的做法：捕获并处理异常
try {
  await cache.setStorage(key, value);
} on CacheWriteException catch (e) {
  Log.e('缓存写入失败: $key', error: e);
  // 降级处理：使用内存缓存
  cache.setMemory(key, value);
} catch (e) {
  Log.e('未知错误', error: e);
}

// ❌ 不好的做法：不处理异常
await cache.setStorage(key, value); // 可能抛出异常
```

### 6. 及时清理无用缓存

```dart
// ✅ 好的做法：退出登录时清理用户数据
Future<void> logout() async {
  // 清理用户相关缓存
  await cache.remove('access_token');
  await cache.remove('user_info');
  await cache.remove('user_settings');

  // 或批量删除
  await cache.removeBatch(['access_token', 'user_info', 'user_settings']);
}

// ❌ 不好的做法：不清理旧数据
// 用户退出后，缓存仍然保留旧数据
```

### 7. 使用双重缓存提升性能

```dart
// ✅ 好的做法：内存 + 持久化双重缓存
Future<T> get<T>(String key, Future<T> Function() fetcher) async {
  // 先查内存（快速）
  final memoryData = cache.getMemory<T>(key);
  if (memoryData != null) return memoryData;

  // 再查持久化
  final storageData = await cache.getStorage<T>(key);
  if (storageData != null) {
    cache.setMemory(key, storageData); // 更新到内存
    return storageData;
  }

  // 最后从网络获取
  final data = await fetcher();
  cache.setMemory(key, data);
  await cache.setStorage(key, data);
  return data;
}
```

---

## 总结

`core_cache` 提供了一套完整的缓存管理方案：

1. **MemoryCache** - 内存缓存，快速访问
2. **StorageManager** - 持久化存储，跨进程共享
3. **CacheManager** - 统一接口，类型安全
4. **CacheKey<T>** - 类型安全的缓存键
5. **CacheEntry<T>** - 支持过期的缓存条目

**使用建议：**

- **频繁访问的数据** → 使用内存缓存
- **需要持久化的数据** → 使用持久化缓存
- **类型敏感的场景** → 使用 CacheKey<T>
- **需要过期的数据** → 使用 CacheEntry.withExpiry
- **高性能场景** → 使用双重缓存策略

通过合理使用缓存，可以：
- 减少网络请求
- 提升应用响应速度
- 改善用户体验
- 降低服务器负载
