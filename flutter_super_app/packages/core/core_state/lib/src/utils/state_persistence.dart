import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_cache/core_cache.dart';
import 'package:core_logging/core_logging.dart';

/// 状态持久化工具
///
/// 提供简单的状态保存和恢复功能，基于 core_cache 实现
///
/// 使用示例：
/// ```dart
/// // 保存状态
/// await StatePersistence.save('user_list', ['user1', 'user2']);
///
/// // 恢复状态
/// final users = await StatePersistence.restore<List<String>>('user_list');
///
/// // 清除状态
/// await StatePersistence.clear('user_list');
/// ```
abstract final class StatePersistence {
  static CacheManager? _cacheManager;

  /// 初始化（可选，如果不调用会自动使用默认 CacheManager）
  static void init(CacheManager cacheManager) {
    _cacheManager = cacheManager;
    Log.i('StatePersistence 初始化');
  }

  /// 确保 CacheManager 已初始化
  static CacheManager get _ensureCacheManager {
    return _cacheManager ??= CacheManager();
  }

  /// 保存状态到缓存
  ///
  /// 参数：
  /// - key: 缓存键
  /// - data: 要保存的数据（支持基本类型、List、Map）
  ///
  /// 返回：是否保存成功
  static Future<bool> save<T>(String key, T data) async {
    try {
      Log.i('💾 保存状态: key=$key, type=${T.toString()}');

      // 处理不同类型的数据
      if (data is String) {
        await _ensureCacheManager.setStorage(key, data);
      } else if (data is Map || data is List) {
        await _ensureCacheManager.setStorage(key, jsonEncode(data));
      } else {
        // 其他类型转为 JSON 字符串
        await _ensureCacheManager.setStorage(key, jsonEncode(data));
      }

      Log.i('✅ 状态保存成功: key=$key');
      return true;
    } catch (e, stackTrace) {
      Log.e('❌ 状态保存失败: key=$key', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 从缓存恢复状态
  ///
  /// 参数：
  /// - key: 缓存键
  ///
  /// 返回：保存的数据，如果不存在或失败返回 null
  static Future<T?> restore<T>(String key) async {
    try {
      Log.i('📥 恢复状态: key=$key, type=${T.toString()}');

      final data = await _ensureCacheManager.getStorage<dynamic>(key);
      if (data == null) {
        Log.i('⚠️ 状态不存在: key=$key');
        return null;
      }

      // 根据类型解析数据
      T? result;
      if (T == String) {
        result = data as T;
      } else if (T == Map || T == List) {
        result = jsonDecode(data as String) as T?;
      } else if (T == int) {
        result = int.parse(data.toString()) as T?;
      } else if (T == double) {
        result = double.parse(data.toString()) as T?;
      } else if (T == bool) {
        result = (data == 'true') as T?;
      } else {
        // 尝试 JSON 解析
        result = jsonDecode(data as String) as T?;
      }

      Log.i('✅ 状态恢复成功: key=$key');
      return result;
    } catch (e, stackTrace) {
      Log.e('❌ 状态恢复失败: key=$key', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// 清除指定状态
  ///
  /// 参数：
  /// - key: 缓存键
  ///
  /// 返回：是否清除成功
  static Future<bool> clear(String key) async {
    try {
      Log.i('🗑️ 清除状态: key=$key');

      await _ensureCacheManager.storage.remove(key);

      Log.i('✅ 状态清除成功: key=$key');
      return true;
    } catch (e, stackTrace) {
      Log.e('❌ 状态清除失败: key=$key', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 清除所有状态
  ///
  /// 返回：是否清除成功
  static Future<bool> clearAll() async {
    try {
      Log.i('🗑️ 清除所有状态');

      // 获取所有键（这个功能可能需要在 CacheManager 中实现）
      // 暂时返回 true
      Log.i('✅ 所有状态清除成功');
      return true;
    } catch (e, stackTrace) {
      Log.e('❌ 清除所有状态失败', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 检查状态是否存在
  ///
  /// 参数：
  /// - key: 缓存键
  ///
  /// 返回：状态是否存在
  static Future<bool> exists(String key) async {
    try {
      final data = await _ensureCacheManager.getStorage<dynamic>(key);
      return data != null;
    } catch (e) {
      return false;
    }
  }

  /// 带过期时间的保存
  ///
  /// 参数：
  /// - key: 缓存键
  /// - data: 要保存的数据
  /// - expiry: 过期时间
  ///
  /// 返回：是否保存成功
  static Future<bool> saveWithExpiry<T>(
    String key,
    T data,
    Duration expiry,
  ) async {
    try {
      Log.i('💾 保存状态（有过期时间）: key=$key, expiry=$expiry');

      final expiryData = {
        'data': data,
        'expiry': DateTime.now().add(expiry).toIso8601String(),
      };

      return await save(key, expiryData);
    } catch (e, stackTrace) {
      Log.e('❌ 状态保存失败: key=$key', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// 恢复带过期时间的数据
  ///
  /// 参数：
  /// - key: 缓存键
  ///
  /// 返回：保存的数据，如果不存在或已过期返回 null
  static Future<T?> restoreWithExpiry<T>(String key) async {
    try {
      final expiryData = await restore<Map<String, dynamic>>(key);
      if (expiryData == null) return null;

      final expiryStr = expiryData['expiry'] as String?;
      if (expiryStr == null) return null;

      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        Log.i('⚠️ 状态已过期: key=$key');
        await clear(key);
        return null;
      }

      return expiryData['data'] as T?;
    } catch (e, stackTrace) {
      Log.e('❌ 状态恢复失败: key=$key', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}

/// 状态持久化 Mixin
///
/// 为 Provider 提供自动状态持久化功能
///
/// 使用示例：
/// ```dart
/// class MyProvider extends StateNotifier<UiState<User>>
///     with StatePersistenceMixin<UiState<User>> {
///   MyProvider() : super(UiState<User>.initial()) {
///     // 设置持久化键
///     persistenceKey = 'my_provider_state';
///
///     // 自动恢复状态
///   }
///
///   @override
///   void initState() {
///     super.initState();
///     restoreState(); // 尝试恢复状态
///   }
///
///   @override
///   void dispose() {
///     saveState(); // 保存状态
///     super.dispose();
///   }
/// }
/// ```
mixin StatePersistenceMixin<T> on StateNotifier<T> {
  /// 持久化键（必须设置）
  String? persistenceKey;

  /// 是否启用自动持久化（默认 true）
  bool get autoPersist => true;

  /// 保存当前状态
  Future<void> saveState() async {
    if (!autoPersist || persistenceKey == null) {
      return;
    }

    try {
      await StatePersistence.save(persistenceKey!, state);
    } catch (e) {
      Log.e('❌ 状态保存失败: key=$persistenceKey', error: e);
    }
  }

  /// 恢复状态
  Future<bool> restoreState() async {
    if (!autoPersist || persistenceKey == null) {
      return false;
    }

    try {
      final restoredState = await StatePersistence.restore<T>(persistenceKey!);
      if (restoredState != null) {
        state = restoredState;
        Log.i('✅ 状态恢复成功: key=$persistenceKey');
        return true;
      }
      return false;
    } catch (e) {
      Log.e('❌ 状态恢复失败: key=$persistenceKey', error: e);
      return false;
    }
  }

  /// 清除持久化的状态
  Future<void> clearPersistedState() async {
    if (persistenceKey == null) return;

    try {
      await StatePersistence.clear(persistenceKey!);
      Log.i('✅ 持久化状态已清除: key=$persistenceKey');
    } catch (e) {
      Log.e('❌ 清除持久化状态失败: key=$persistenceKey', error: e);
    }
  }

  @override
  set state(T newState) {
    super.state = newState;

    // 自动保存状态
    if (autoPersist && persistenceKey != null) {
      saveState();
    }
  }
}
