library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_cache/core_cache.dart';
import '../models/user.dart';
import '../models/user_profile.dart';

/// 用户仓储接口
abstract base class UserRepository {
  /// 获取当前用户
  Future<Result<User?>> getCurrentUser();

  /// 根据 ID 获取用户
  Future<Result<User>> getUserById(String id);

  /// 更新用户信息
  Future<Result<User>> updateUser(User user);

  /// 更新用户资料
  Future<Result<UserProfile>> updateProfile(UserProfile profile);

  /// 上传头像
  Future<Result<String>> uploadAvatar(String filePath);

  /// 保存当前用户到缓存
  Future<void> cacheCurrentUser(User user);

  /// 从缓存获取当前用户
  Future<User?> getCachedUser();

  /// 清除用户缓存
  Future<void> clearCache();
}

/// 用户仓储实现
final class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;
  final CacheManager _cacheManager;

  UserRepositoryImpl({
    required ApiClient apiClient,
    required CacheManager cacheManager,
  })  : _apiClient = apiClient,
      _cacheManager = cacheManager;

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      // 先从缓存获取
      final cached = await getCachedUser();
      if (cached != null) {
        return Result.success(cached);
      }

      // 从 API 获取
      final response = await _apiClient.get<User>(
        '/user/current',
        dataParser: (data) => User.fromJson(data as Map<String, dynamic>),
      );

      if (response.data != null) {
        await cacheCurrentUser(response.data!);
        return Result.success(response.data!);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Exception('获取当前用户失败: $e'),
      );
    }
  }

  @override
  Future<Result<User>> getUserById(String id) async {
    try {
      final response = await _apiClient.get<User>(
        '/user/$id',
        dataParser: (data) => User.fromJson(data as Map<String, dynamic>),
      );

      if (response.data != null) {
        return Result.success(response.data!);
      }

      return Result.failure(
        Exception('用户不存在: $id'),
      );
    } catch (e) {
      return Result.failure(
        Exception('获取用户失败: $e'),
      );
    }
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    try {
      final response = await _apiClient.put<User>(
        '/user/${user.id}',
        body: user.toJson(),
        dataParser: (data) => User.fromJson(data as Map<String, dynamic>),
      );

      if (response.data != null) {
        await cacheCurrentUser(response.data!);
        return Result.success(response.data!);
      }

      return Result.failure(
        Exception('更新用户失败'),
      );
    } catch (e) {
      return Result.failure(
        Exception('更新用户失败: $e'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final response = await _apiClient.put<UserProfile>(
        '/user/profile',
        body: profile.toJson(),
        dataParser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
      );

      if (response.data != null) {
        return Result.success(response.data!);
      }

      return Result.failure(
        Exception('更新资料失败'),
      );
    } catch (e) {
      return Result.failure(
        Exception('更新资料失败: $e'),
      );
    }
  }

  @override
  Future<Result<String>> uploadAvatar(String filePath) async {
    // TODO: 实现文件上传
    return Result.failure(
      Exception('文件上传功能待实现'),
    );
  }

  @override
  Future<void> cacheCurrentUser(User user) async {
    await _cacheManager.setStorage(
      'current_user',
      user.toJson(),
    );
  }

  @override
  Future<User?> getCachedUser() async {
    final json = await _cacheManager.getStorage<Map<String, dynamic>>(
      'current_user',
    );
    if (json != null) {
      return User.fromJson(json);
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await _cacheManager.storage.remove('current_user');
  }
}
