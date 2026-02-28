import 'dart:convert';
import 'package:core_logging/core_logging.dart';
import '../cache/cache_entry.dart';
import '../cache/cache_key.dart';
import '../storage/storage_manager.dart';
import '../exceptions/cache_exceptions.dart';

/// 内存缓存
final class MemoryCache {
  final Map<String, CacheEntry<dynamic>> _cache = {};

  /// 设置缓存
  void set<T>(String key, T data, {Duration? expiry}) {
    final entry = expiry != null
        ? CacheEntry.withExpiry(data, expiry: expiry)
        : CacheEntry(data: data);
    _cache[key] = entry;
    Log.i('内存缓存设置: $key');
  }

  /// 获取缓存
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) {
      Log.w('内存缓存未找到: $key');
      return null;
    }

    if (entry.isExpired) {
      Log.w('内存缓存已过期: $key');
      _cache.remove(key);
      return null;
    }

    Log.i('内存缓存命中: $key');
    return entry.data as T;
  }

  /// 删除缓存
  void remove(String key) {
    _cache.remove(key);
    Log.i('内存缓存删除: $key');
  }

  /// 清空所有缓存
  void clear() {
    _cache.clear();
    Log.i('内存缓存已清空');
  }

  /// 检查缓存是否存在
  bool containsKey(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// 获取所有键
  Set<String> get keys => _cache.keys.toSet();
}

/// 缓存管理器
///
/// 提供内存缓存和持久化缓存的统一管理
final class CacheManager {
  final MemoryCache _memoryCache = MemoryCache();
  final StorageManager _storageManager = StorageManager();

  /// 内存缓存实例
  MemoryCache get memory => _memoryCache;

  /// 存储管理器实例
  StorageManager get storage => _storageManager;

  /// 设置缓存（内存）
  void setMemory<T>(String key, T data, {Duration? expiry}) {
    _memoryCache.set(key, data, expiry: expiry);
  }

  /// 获取缓存（内存）
  T? getMemory<T>(String key) {
    return _memoryCache.get<T>(key);
  }

  /// 设置缓存（持久化）
  Future<void> setStorage<T>(String key, T data) async {
    try {
      if (data is String) {
        await _storageManager.setString(key, data);
      } else if (data is int) {
        await _storageManager.setInt(key, data);
      } else if (data is bool) {
        await _storageManager.setBool(key, data);
      } else if (data is double) {
        await _storageManager.setDouble(key, data);
      } else if (data is List<String>) {
        await _storageManager.setStringList(key, data);
      } else if (data is Map<String, dynamic>) {
        await _storageManager.setJson(key, data);
      } else {
        // 其他类型序列化为 JSON
        final jsonString = jsonEncode(data);
        await _storageManager.setString(key, jsonString);
      }
      Log.i('持久化缓存设置: $key');
    } catch (e) {
      Log.e('持久化缓存设置失败: $key', error: e);
      rethrow;
    }
  }

  /// 获取缓存（持久化）
  Future<T?> getStorage<T>(String key) async {
    try {
      Object? value;
      if (T == String) {
        value = await _storageManager.getString(key);
      } else if (T == int) {
        value = await _storageManager.getInt(key);
      } else if (T == bool) {
        value = await _storageManager.getBool(key);
      } else if (T == double) {
        value = await _storageManager.getDouble(key);
      } else if (T == List<String>) {
        value = await _storageManager.getStringList(key);
      } else if (T == Map<String, dynamic>) {
        value = await _storageManager.getJson(key);
      } else {
        // 尝试作为 JSON 解析
        final jsonString = await _storageManager.getString(key);
        if (jsonString != null) {
          value = jsonDecode(jsonString);
        }
      }
      Log.i('持久化缓存获取: $key');
      return value as T?;
    } catch (e) {
      Log.e('持久化缓存获取失败: $key', error: e);
      return null;
    }
  }

  /// 删除缓存（内存和持久化）
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _storageManager.remove(key);
    Log.i('缓存删除: $key');
  }

  /// 清空所有缓存（内存和持久化）
  Future<void> clear() async {
    _memoryCache.clear();
    await _storageManager.clear();
    Log.i('所有缓存已清空');
  }

  /// 检查缓存是否存在（内存或持久化）
  Future<bool> containsKey(String key) async {
    final inMemory = _memoryCache.containsKey(key);
    if (inMemory) return true;
    return await _storageManager.containsKey(key);
  }

  /// 使用 CacheKey 设置缓存（类型安全）
  Future<void> set<T>(CacheKey<T> key, T value, {bool persist = true}) async {
    if (persist) {
      await setStorage(key.key, value);
    } else {
      setMemory(key.key, value);
    }
  }

  /// 使用 CacheKey 获取缓存（类型安全）
  Future<T?> get<T>(CacheKey<T> key, {bool persist = true}) async {
    if (persist) {
      return await getStorage<T>(key.key);
    } else {
      return getMemory<T>(key.key);
    }
  }

  /// 使用 CacheKey 获取缓存，带默认值
  Future<T> getOrElse<T>(CacheKey<T> key, {bool persist = true}) async {
    final value = await get<T>(key, persist: persist);
    if (value != null) return value;
    if (key.defaultValue != null) return key.defaultValue as T;
    throw CacheNotFoundException(
      message: '缓存不存在: ${key.key}',
    );
  }

  /// 删除指定键的缓存
  Future<void> delete(String key) async {
    await remove(key);
  }

  /// 批量删除缓存
  Future<void> removeBatch(List<String> keys) async {
    for (final key in keys) {
      await remove(key);
    }
    Log.i('批量删除缓存: ${keys.length} 个');
  }
}
