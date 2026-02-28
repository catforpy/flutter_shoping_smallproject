import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:core_cache/core_cache.dart';

void main() {
  // 初始化 Flutter 测试绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  // 设置 SharedPreferences 的模拟值
  const MethodChannel('plugins.flutter.io/shared_preferences')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{};
    }
    return null;
  });
  group('CacheKey', () {
    test('should create cache key with name only', () {
      const key = CacheKey<String>('test_key');
      expect(key.key, 'test_key');
      expect(key.defaultValue, null);
    });

    test('should create cache key with default value', () {
      const key = CacheKey<int>('count', defaultValue: 0);
      expect(key.key, 'count');
      expect(key.defaultValue, 0);
    });
  });

  group('CacheKeys', () {
    test('should have correct constants', () {
      expect(CacheKeys.accessToken, 'access_token');
      expect(CacheKeys.refreshToken, 'refresh_token');
      expect(CacheKeys.themeMode, 'theme_mode');
      expect(CacheKeys.language, 'language');
    });
  });

  group('CacheEntry', () {
    test('should create entry without expiry', () {
      final entry = CacheEntry<int>(data: 123);
      expect(entry.data, 123);
      expect(entry.expireTimeMs, null);
      expect(entry.isExpired, false);
      expect(entry.remainingTimeMs, null);
    });

    test('should create entry with expiry', () {
      final expiry = const Duration(minutes: 5);
      final entry = CacheEntry.withExpiry('data', expiry: expiry);
      expect(entry.data, 'data');
      expect(entry.expireTimeMs, isNotNull);
      expect(entry.isExpired, false);
    });

    test('should detect expired entry', () {
      final past = DateTime.now().subtract(const Duration(seconds: 1));
      final expiredTime = past.millisecondsSinceEpoch;
      final entry = CacheEntry(
        data: 'expired',
        expireTimeMs: expiredTime,
      );
      expect(entry.isExpired, true);
    });

    test('should calculate remaining time', () {
      final future = DateTime.now().add(const Duration(minutes: 5));
      final expireTime = future.millisecondsSinceEpoch;
      final entry = CacheEntry(
        data: 'data',
        expireTimeMs: expireTime,
      );
      expect(entry.remainingTimeMs, greaterThan(0));
      expect(entry.remainingTimeSeconds, greaterThan(0));
      expect(entry.remainingTimeSeconds, lessThanOrEqualTo(300));
    });

    test('should copy entry with new values', () {
      final entry = CacheEntry<int>(data: 123);
      final copied = entry.copyWith(data: 456);
      expect(copied.data, 456);
      expect(entry.data, 123); // Original unchanged
    });
  });

  group('MemoryCache', () {
    test('should set and get data', () {
      final cache = MemoryCache();
      cache.set('key1', 'value1');
      expect(cache.get('key1'), 'value1');
    });

    test('should return null for non-existent key', () {
      final cache = MemoryCache();
      expect(cache.get('non_existent'), null);
    });

    test('should remove data', () {
      final cache = MemoryCache();
      cache.set('key1', 'value1');
      cache.remove('key1');
      expect(cache.get('key1'), null);
    });

    test('should clear all data', () {
      final cache = MemoryCache();
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.clear();
      expect(cache.get('key1'), null);
      expect(cache.get('key2'), null);
    });

    test('should check if key exists', () {
      final cache = MemoryCache();
      cache.set('key1', 'value1');
      expect(cache.containsKey('key1'), true);
      expect(cache.containsKey('key2'), false);
    });

    test('should return all keys', () {
      final cache = MemoryCache();
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      expect(cache.keys.length, 2);
      expect(cache.keys, contains('key1'));
      expect(cache.keys, contains('key2'));
    });
  });

  group('CacheManager', () {
    test('should create cache manager', () {
      final manager = CacheManager();
      expect(manager.memory, isNotNull);
      expect(manager.storage, isNotNull);
    });

    test('should set and get memory cache', () {
      final manager = CacheManager();
      manager.setMemory('key1', 'value1');
      expect(manager.getMemory('key1'), 'value1');
    });

    test('should remove from memory', () async {
      final manager = CacheManager();
      manager.setMemory('key1', 'value1');
      manager.memory.remove('key1');
      expect(manager.getMemory('key1'), null);
    });

    test('should clear all memory caches', () async {
      final manager = CacheManager();
      manager.setMemory('key1', 'value1');
      manager.setMemory('key2', 'value2');
      manager.memory.clear();
      expect(manager.getMemory('key1'), null);
      expect(manager.getMemory('key2'), null);
    });

    test('should check if key exists in memory', () async {
      final manager = CacheManager();
      manager.setMemory('key1', 'value1');
      expect(manager.memory.containsKey('key1'), true);
      expect(manager.memory.containsKey('key2'), false);
    });

    test('should use CacheKey for type-safe operations', () async {
      final manager = CacheManager();
      const userTokenKey = CacheKey<String>('user_token');

      manager.setMemory(userTokenKey.key, 'abc123');
      expect(manager.getMemory(userTokenKey.key), 'abc123');
    });

    test('should delete cache from memory', () async {
      final manager = CacheManager();
      manager.setMemory('key1', 'value1');
      manager.memory.remove('key1');
      expect(manager.getMemory('key1'), null);
    });

    test('should batch remove caches from memory', () async {
      final manager = CacheManager();
      manager.setMemory('key1', 'value1');
      manager.setMemory('key2', 'value2');
      manager.setMemory('key3', 'value3');
      manager.memory.remove('key1');
      manager.memory.remove('key2');
      expect(manager.getMemory('key1'), null);
      expect(manager.getMemory('key2'), null);
      expect(manager.getMemory('key3'), 'value3');
    });
  });

  group('CacheEntry toString', () {
    test('should format string correctly', () {
      final entry = CacheEntry<int>(data: 123);
      final str = entry.toString();
      expect(str, contains('123'));
      expect(str, contains('isExpired: false'));
    });
  });
}
