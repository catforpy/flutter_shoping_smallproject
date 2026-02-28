library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core_base/core_base.dart';
import 'package:core_logging/core_logging.dart';
import '../models/user.dart';
import '../services/user_service.dart';

/// 用户状态
final class UserState {
  /// 当前用户
  final User? user;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? error;

  /// 是否已登录
  bool get isLoggedIn => user != null;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// 初始状态
  const UserState.initial() : user = null, isLoading = false, error = null;

  /// 创建副本
  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() =>
      'UserState(user: ${user?.username}, isLoading: $isLoading, error: $error)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserState &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(user, isLoading, error);
}

/// 用户状态管理器
///
/// 负责管理当前用户的登录状态和信息
/// 使用 Riverpod 进行状态管理
///
/// 使用示例：
/// ```dart
/// // 在 Widget 中使用
/// final userState = ref.watch(userProvider);
/// final userNotifier = ref.read(userProvider.notifier);
///
/// // 获取当前用户
/// await userNotifier.getCurrentUser();
///
/// // 登出
/// await userNotifier.logout();
/// ```
final class UserProvider extends StateNotifier<UserState> {
  final UserService _userService;

  UserProvider(this._userService) : super(const UserState.initial()) {
    _init();
  }

  /// 初始化 - 自动获取当前用户
  Future<void> _init() async {
    try {
      final result = await _userService.getCurrentUser();
      if (result.isSuccess && result.valueOrThrow != null) {
        state = UserState(user: result.valueOrThrow);
      }
    } catch (e) {
      Log.e('初始化用户状态失败', error: e);
    }
  }

  /// 获取当前用户
  ///
  /// 使用场景：
  /// - 应用启动时加载用户信息
  /// - 刷新用户信息
  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _userService.getCurrentUser();

    if (result.isSuccess) {
      state = UserState(user: result.valueOrThrow);
    } else {
      state = UserState(
        error: result.error?.toString() ?? '获取用户信息失败',
      );
    }
  }

  /// 刷新当前用户信息
  Future<void> refreshUser() async {
    await getCurrentUser();
  }

  /// 获取用户资料
  Future<Result<User>> getUserProfile(String userId) async {
    return await _userService.getUserProfile(userId);
  }

  /// 更新用户信息
  ///
  /// 使用场景：
  /// - 修改昵称
  /// - 修改头像
  /// - 修改个人信息
  Future<void> updateUserInfo({
    required String userId,
    String? nickname,
    String? avatar,
    String? email,
    String? gender,
    DateTime? birthday,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await _userService.updateUserInfo(
      userId: userId,
      nickname: nickname,
      avatar: avatar,
      email: email,
      gender: gender,
      birthday: birthday,
    );

    if (result.isSuccess) {
      // 更新当前用户
      final updatedUser = result.valueOrThrow;
      state = UserState(user: updatedUser);
    } else {
      state = UserState(
        error: result.error?.toString() ?? '更新用户信息失败',
      );
    }
  }

  /// 更新用户资料
  ///
  /// 使用场景：
  /// - 修改真实姓名
  /// - 修改身份证信息
  /// - 修改地址等
  Future<void> updateUserProfile({
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
    state = state.copyWith(isLoading: true);

    final result = await _userService.updateUserProfile(
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

    if (result.isFailure) {
      state = state.copyWith(
        error: result.error?.toString() ?? '更新用户资料失败',
      );
      return;
    }

    // 更新成功后刷新用户信息
    await refreshUser();
  }

  /// 上传头像
  Future<void> uploadAvatar(String filePath) async {
    if (state.user == null) {
      state = state.copyWith(error: '未登录');
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await _userService.uploadAvatar(filePath);

    if (result.isSuccess) {
      // 上传成功后更新用户头像
      await updateUserInfo(
        userId: state.user!.id,
        avatar: result.valueOrThrow,
      );
    } else {
      state = state.copyWith(
        error: result.error?.toString() ?? '上传头像失败',
      );
    }
  }

  /// 登出
  ///
  /// 使用场景：
  /// - 用户主动登出
  /// - Token 过期自动登出
  Future<void> logout() async {
    try {
      await _userService.logout();
      state = const UserState.initial();
      Log.i('用户登出成功');
    } catch (e) {
      Log.e('登出失败', error: e);
      state = const UserState.initial();
    }
  }

  /// 搜索用户
  Future<Result<PagedResult<User>>> searchUsers({
    required String keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _userService.searchUsers(
      keyword: keyword,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 关注用户
  Future<Result<void>> followUser(String targetUserId) async {
    return await _userService.followUser(targetUserId);
  }

  /// 取关用户
  Future<Result<void>> unfollowUser(String targetUserId) async {
    return await _userService.unfollowUser(targetUserId);
  }

  /// 检查是否关注了某用户
  Future<Result<bool>> isFollowing(String targetUserId) async {
    return await _userService.isFollowing(targetUserId);
  }

  /// 获取关注列表
  Future<Result<PagedResult<User>>> getFollowingList({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _userService.getFollowingList(
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 获取粉丝列表
  Future<Result<PagedResult<User>>> getFollowersList({
    required String userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _userService.getFollowersList(
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}
