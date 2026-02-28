import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import '../models/user.dart';
import '../models/user_profile.dart';
import '../models/relation.dart';
import '../repositories/user_repository.dart';

/// 用户服务
///
/// 提供用户相关的业务逻辑
final class UserService {
  final UserRepository _repository;
  final ApiClient _apiClient;

  UserService({
    required UserRepository repository,
    required ApiClient apiClient,
  })  : _repository = repository,
        _apiClient = apiClient;

  // ==================== 用户信息管理 ====================

  /// 获取当前用户
  Future<Result<User?>> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }

  /// 获取用户资料
  Future<Result<User>> getUserProfile(String userId) async {
    return await _repository.getUserById(userId);
  }

  /// 批量获取用户信息
  Future<Result<List<User>>> getUsersByIds(List<String> userIds) async {
    try {
      Log.i('批量获取用户信息: ${userIds.length} 个用户');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/users/batch',
        body: {'userIds': userIds},
      );

      if (response.data != null && response.data!['success'] == true) {
        final usersData = response.data!['data'] as List;
        final users = usersData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        Log.i('批量获取用户信息成功');
        return Result.success(users);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量获取用户信息失败'),
      );
    } catch (e) {
      Log.e('批量获取用户信息失败', error: e);
      return Result.failure(Exception('批量获取用户信息失败: $e'));
    }
  }

  /// 更新用户信息
  Future<Result<User>> updateUserInfo({
    required String userId,
    String? nickname,
    String? avatar,
    String? email,
    String? gender,
    DateTime? birthday,
  }) async {
    final currentUserResult = await _repository.getUserById(userId);
    if (currentUserResult.isFailure) {
      return currentUserResult;
    }

    final currentUser = currentUserResult.valueOrThrow;
    final updatedUser = currentUser.copyWith(
      nickname: nickname,
      avatar: avatar,
      email: email,
      gender: gender,
      birthday: birthday,
    );

    return await _repository.updateUser(updatedUser);
  }

  /// 更新用户资料
  Future<Result<UserProfile>> updateUserProfile({
    required String userId,
    String? realName,
    String? idCard,
    String? address,
    String? company,
    String? position,
    String? bio,
    String? website,
    String? wechat,
    String? qq,
  }) async {
    final profile = UserProfile(
      userId: userId,
      realName: realName,
      idCard: idCard,
      address: address,
      company: company,
      position: position,
      bio: bio,
      website: website,
      wechat: wechat,
      qq: qq,
    );

    return await _repository.updateProfile(profile);
  }

  /// 上传头像
  Future<Result<String>> uploadAvatar(String filePath) async {
    return await _repository.uploadAvatar(filePath);
  }

  /// 登出
  Future<void> logout() async {
    await _repository.clearCache();
  }

  // ==================== 用户搜索 ====================

  /// 搜索用户
  ///
  /// 支持多种搜索方式：
  /// - 按用户ID精确搜索
  /// - 按手机号搜索
  /// - 按昵称模糊搜索
  /// - 按用户名模糊搜索
  Future<Result<PagedResult<User>>> searchUsers({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Log.i('搜索用户: $keyword (第$page页)');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/search',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final usersData = data['items'] as List;
        final users = usersData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('搜索用户成功: 找到 ${users.length} 个用户');
        return Result.success(
          PagedResult(
            data: users,
            pagination: Pagination(
              page: page,
              pageSize: pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '搜索用户失败'),
      );
    } catch (e) {
      Log.e('搜索用户失败', error: e);
      return Result.failure(Exception('搜索用户失败: $e'));
    }
  }

  // ==================== 关注系统 ====================

  /// 关注用户
  Future<Result<void>> followUser(String targetUserId) async {
    try {
      Log.i('关注用户: $targetUserId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/users/follow',
        body: {'targetUserId': targetUserId},
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('关注用户成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '关注用户失败'),
      );
    } catch (e) {
      Log.e('关注用户失败', error: e);
      return Result.failure(Exception('关注用户失败: $e'));
    }
  }

  /// 取关用户
  Future<Result<void>> unfollowUser(String targetUserId) async {
    try {
      Log.i('取关用户: $targetUserId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/users/unfollow',
        body: {'targetUserId': targetUserId},
      );

      if (response.data != null && response.data!['success'] == true) {
        Log.i('取关用户成功');
        return Result.success(null);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '取关用户失败'),
      );
    } catch (e) {
      Log.e('取关用户失败', error: e);
      return Result.failure(Exception('取关用户失败: $e'));
    }
  }

  /// 批量关注用户
  Future<Result<BatchRelationResult>> batchFollowUsers(
    List<String> targetUserIds,
  ) async {
    try {
      Log.i('批量关注用户: ${targetUserIds.length} 个用户');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/users/follow/batch',
        body: {'targetUserIds': targetUserIds},
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final result = BatchRelationResult(
          successCount: data['successCount'] as int? ?? 0,
          failureCount: data['failureCount'] as int? ?? 0,
          failedUserIds: (data['failedUserIds'] as List<dynamic>?)
                  ?.cast<String>() ??
              [],
          errors: (data['errors'] as List<dynamic>?)?.cast<String>() ?? [],
        );

        Log.i('批量关注成功: ${result.successCount}/${result.totalCount}');
        return Result.success(result);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '批量关注失败'),
      );
    } catch (e) {
      Log.e('批量关注失败', error: e);
      return Result.failure(Exception('批量关注失败: $e'));
    }
  }

  /// 获取关注列表（分页）
  Future<Result<PagedResult<User>>> getFollowingList({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Log.i('获取关注列表: $userId (第$page页)');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/$userId/following',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final usersData = data['items'] as List;
        final users = usersData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取关注列表成功: ${users.length} 个用户');
        return Result.success(
          PagedResult(
            data: users,
            pagination: Pagination(
              page: page,
              pageSize: pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取关注列表失败'),
      );
    } catch (e) {
      Log.e('获取关注列表失败', error: e);
      return Result.failure(Exception('获取关注列表失败: $e'));
    }
  }

  /// 获取粉丝列表（分页）
  Future<Result<PagedResult<User>>> getFollowersList({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Log.i('获取粉丝列表: $userId (第$page页)');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/$userId/followers',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final usersData = data['items'] as List;
        final users = usersData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取粉丝列表成功: ${users.length} 个用户');
        return Result.success(
          PagedResult(
            data: users,
            pagination: Pagination(
              page: page,
              pageSize: pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取粉丝列表失败'),
      );
    } catch (e) {
      Log.e('获取粉丝列表失败', error: e);
      return Result.failure(Exception('获取粉丝列表失败: $e'));
    }
  }

  /// 检查关注状态
  ///
  /// 返回当前用户是否关注了目标用户
  Future<Result<bool>> isFollowing(String targetUserId) async {
    try {
      Log.i('检查关注状态: $targetUserId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/following/check/$targetUserId',
      );

      if (response.data != null && response.data!['success'] == true) {
        final isFollowing = response.data!['data']['isFollowing'] as bool? ?? false;
        return Result.success(isFollowing);
      }

      return Result.success(false);
    } catch (e) {
      Log.e('检查关注状态失败', error: e);
      return Result.success(false); // 失败默认返回 false
    }
  }

  /// 获取互关列表（相互关注）
  Future<Result<List<User>>> getMutualFollowers({
    required String userId,
  }) async {
    try {
      Log.i('获取互关列表: $userId');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/$userId/mutual-followers',
      );

      if (response.data != null && response.data!['success'] == true) {
        final usersData = response.data!['data'] as List;
        final users = usersData
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        Log.i('获取互关列表成功: ${users.length} 个用户');
        return Result.success(users);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取互关列表失败'),
      );
    } catch (e) {
      Log.e('获取互关列表失败', error: e);
      return Result.failure(Exception('获取互关列表失败: $e'));
    }
  }
}
