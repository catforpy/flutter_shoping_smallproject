import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core_logging/core_logging.dart';
import 'package:core_utils/core_utils.dart';
import '../exceptions/cache_exceptions.dart';

/// 存储管理器
///
/// 基于 SharedPreferences 的持久化存储
final class StorageManager {
  SharedPreferences? _prefs;

  /// 获取 SharedPreferences 实例
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setString(key, value);
      Log.i('保存字符串: $key');
      return result;
    } catch (e) {
      Log.e('保存字符串失败: $key', error: e);
      throw CacheWriteException(
        message: '保存字符串失败: $key',
        originalException: e,
      );
    }
  }

  /// 获取字符串
  Future<String?> getString(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getString(key);
      Log.i('获取字符串: $key, value: ${value.isNullOrEmpty ? '空' : '有值'}');
      return value;
    } catch (e) {
      Log.e('获取字符串失败: $key', error: e);
      throw CacheReadException(
        message: '获取字符串失败: $key',
        originalException: e,
      );
    }
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setInt(key, value);
      Log.i('保存整数: $key = $value');
      return result;
    } catch (e) {
      Log.e('保存整数失败: $key', error: e);
      throw CacheWriteException(
        message: '保存整数失败: $key',
        originalException: e,
      );
    }
  }

  /// 获取整数
  Future<int?> getInt(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getInt(key);
      Log.i('获取整数: $key = $value');
      return value;
    } catch (e) {
      Log.e('获取整数失败: $key', error: e);
      throw CacheReadException(
        message: '获取整数失败: $key',
        originalException: e,
      );
    }
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setBool(key, value);
      Log.i('保存布尔值: $key = $value');
      return result;
    } catch (e) {
      Log.e('保存布尔值失败: $key', error: e);
      throw CacheWriteException(
        message: '保存布尔值失败: $key',
        originalException: e,
      );
    }
  }

  /// 获取布尔值
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getBool(key);
      Log.i('获取布尔值: $key = $value');
      return value;
    } catch (e) {
      Log.e('获取布尔值失败: $key', error: e);
      throw CacheReadException(
        message: '获取布尔值失败: $key',
        originalException: e,
      );
    }
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setDouble(key, value);
      Log.i('保存双精度浮点数: $key = $value');
      return result;
    } catch (e) {
      Log.e('保存双精度浮点数失败: $key', error: e);
      throw CacheWriteException(
        message: '保存双精度浮点数失败: $key',
        originalException: e,
      );
    }
  }

  /// 获取双精度浮点数
  Future<double?> getDouble(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getDouble(key);
      Log.i('获取双精度浮点数: $key = $value');
      return value;
    } catch (e) {
      Log.e('获取双精度浮点数失败: $key', error: e);
      throw CacheReadException(
        message: '获取双精度浮点数失败: $key',
        originalException: e,
      );
    }
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.setStringList(key, value);
      Log.i('保存字符串列表: $key, length: ${value.length}');
      return result;
    } catch (e) {
      Log.e('保存字符串列表失败: $key', error: e);
      throw CacheWriteException(
        message: '保存字符串列表失败: $key',
        originalException: e,
      );
    }
  }

  /// 获取字符串列表
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _preferences;
      final value = prefs.getStringList(key);
      Log.i('获取字符串列表: $key, length: ${value?.length ?? 0}');
      return value;
    } catch (e) {
      Log.e('获取字符串列表失败: $key', error: e);
      throw CacheReadException(
        message: '获取字符串列表失败: $key',
        originalException: e,
      );
    }
  }

  /// 保存 JSON 对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      Log.e('保存 JSON 失败: $key', error: e);
      throw CacheWriteException(
        message: '保存 JSON 失败: $key',
        originalException: e,
      );
    }
  }

  /// 获取 JSON 对象
  Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString.isNullOrEmpty) return null;
      final json = jsonDecode(jsonString!) as Map<String, dynamic>;
      Log.i('获取 JSON: $key');
      return json;
    } catch (e) {
      Log.e('获取 JSON 失败: $key', error: e);
      throw CacheReadException(
        message: '获取 JSON 失败: $key',
        originalException: e,
      );
    }
  }

  /// 删除指定键
  Future<bool> remove(String key) async {
    try {
      final prefs = await _preferences;
      final result = await prefs.remove(key);
      Log.i('删除缓存: $key');
      return result;
    } catch (e) {
      Log.e('删除缓存失败: $key', error: e);
      throw CacheDeleteException(
        message: '删除缓存失败: $key',
        originalException: e,
      );
    }
  }

  /// 清空所有缓存
  Future<bool> clear() async {
    try {
      final prefs = await _preferences;
      final result = await prefs.clear();
      Log.i('清空所有缓存');
      return result;
    } catch (e) {
      Log.e('清空缓存失败', error: e);
      throw CacheDeleteException(
        message: '清空缓存失败',
        originalException: e,
      );
    }
  }

  /// 检查键是否存在
  Future<bool> containsKey(String key) async {
    try {
      final prefs = await _preferences;
      final exists = prefs.containsKey(key);
      Log.i('检查键存在: $key = $exists');
      return exists;
    } catch (e) {
      Log.e('检查键存在失败: $key', error: e);
      return false;
    }
  }

  /// 获取所有键
  Future<Set<String>> getKeys() async {
    try {
      final prefs = await _preferences;
      final keys = prefs.getKeys();
      Log.i('获取所有键, count: ${keys.length}');
      return keys;
    } catch (e) {
      Log.e('获取所有键失败', error: e);
      throw CacheReadException(
        message: '获取所有键失败',
        originalException: e,
      );
    }
  }
}
