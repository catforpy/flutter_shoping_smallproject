import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_cache/core_cache.dart';
import 'package:core_logging/core_logging.dart';
import 'package:service_user/service_user.dart';
import '../models/auth_token.dart';
import '../models/auth_result.dart';

/// 认证服务接口
abstract base class AuthService {
  /// 密码登录
  Future<AuthResult> loginWithPassword({
    required String phone,
    required String password,
  });

  /// 验证码登录
  Future<AuthResult> loginWithVerifyCode({
    required String phone,
    required String code,
  });

  /// 微信授权登录
  Future<AuthResult> loginWithWechat({
    required String authCode,
  });

  /// 游客模式登录
  Future<AuthResult> loginAsGuest({
    required String deviceId,
  });

  /// 注册
  Future<AuthResult> register({
    required String phone,
    required String password,
    required String verifyCode,
  });

  /// 发送验证码
  Future<Result<void>> sendVerifyCode(String phone);

  /// 刷新 Token
  Future<Result<AuthToken>> refreshToken(String refreshToken);

  /// 登出
  Future<void> logout();

  /// 检查登录状态
  Future<bool> isLoggedIn();

  /// 获取当前 Token
  Future<AuthToken?> getCurrentToken();
}

/// 认证服务实现
final class AuthServiceImpl implements AuthService {
  final ApiClient _apiClient;
  final CacheManager _cacheManager;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthServiceImpl({
    required ApiClient apiClient,
    required CacheManager cacheManager,
  })  : _apiClient = apiClient,
      _cacheManager = cacheManager;

  @override
  Future<AuthResult> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    try {
      Log.i('用户登录: $phone');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        body: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final token = AuthToken.fromJson(data['token'] as Map<String, dynamic>);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        // 保存 Token 和用户信息
        await _saveToken(token);
        await _cacheManager.setStorage(_userKey, user.toJson());

        Log.i('登录成功');
        return AuthResult.success(user: user, token: token.accessToken);
      }

      return AuthResult.failure(response.data?['message'] ?? '登录失败');
    } catch (e) {
      Log.e('登录失败', error: e);
      return AuthResult.failure('登录失败: $e');
    }
  }

  @override
  Future<AuthResult> loginWithVerifyCode({
    required String phone,
    required String code,
  }) async {
    try {
      Log.i('验证码登录: $phone');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login/verify-code',
        body: {
          'phone': phone,
          'code': code,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final token = AuthToken.fromJson(data['token'] as Map<String, dynamic>);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _saveToken(token);
        await _cacheManager.setStorage(_userKey, user.toJson());

        Log.i('验证码登录成功');
        return AuthResult.success(user: user, token: token.accessToken);
      }

      return AuthResult.failure(response.data?['message'] ?? '验证码登录失败');
    } catch (e) {
      Log.e('验证码登录失败', error: e);
      return AuthResult.failure('验证码登录失败: $e');
    }
  }

  @override
  Future<AuthResult> loginWithWechat({
    required String authCode,
  }) async {
    try {
      Log.i('微信授权登录');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login/wechat',
        body: {
          'authCode': authCode,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final token = AuthToken.fromJson(data['token'] as Map<String, dynamic>);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _saveToken(token);
        await _cacheManager.setStorage(_userKey, user.toJson());

        Log.i('微信授权登录成功');
        return AuthResult.success(user: user, token: token.accessToken);
      }

      return AuthResult.failure(response.data?['message'] ?? '微信授权登录失败');
    } catch (e) {
      Log.e('微信授权登录失败', error: e);
      return AuthResult.failure('微信授权登录失败: $e');
    }
  }

  @override
  Future<AuthResult> loginAsGuest({
    required String deviceId,
  }) async {
    try {
      Log.i('游客模式登录: $deviceId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login/guest',
        body: {
          'deviceId': deviceId,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final token = AuthToken.fromJson(data['token'] as Map<String, dynamic>);

        await _saveToken(token);
        // 游客模式不需要保存用户信息
        await _cacheManager.storage.remove(_userKey);

        Log.i('游客模式登录成功');
        return AuthResult.success(
          user: null, // 游客没有用户信息
          token: token.accessToken,
        );
      }

      return AuthResult.failure(response.data?['message'] ?? '游客登录失败');
    } catch (e) {
      Log.e('游客登录失败', error: e);
      return AuthResult.failure('游客登录失败: $e');
    }
  }

  @override
  Future<AuthResult> register({
    required String phone,
    required String password,
    required String verifyCode,
  }) async {
    try {
      Log.i('用户注册: $phone');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        body: {
          'phone': phone,
          'password': password,
          'verifyCode': verifyCode,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final token = AuthToken.fromJson(data['token'] as Map<String, dynamic>);
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        await _saveToken(token);
        await _cacheManager.setStorage(_userKey, user.toJson());

        Log.i('注册成功');
        return AuthResult.success(user: user, token: token.accessToken);
      }

      return AuthResult.failure(response.data?['message'] ?? '注册失败');
    } catch (e) {
      Log.e('注册失败', error: e);
      return AuthResult.failure('注册失败: $e');
    }
  }

  @override
  Future<Result<void>> sendVerifyCode(String phone) async {
    try {
      Log.i('发送验证码: $phone');

      await _apiClient.post(
        '/auth/send-code',
        body: {'phone': phone},
      );

      Log.i('验证码发送成功');
      return Result.success(null);
    } catch (e) {
      Log.e('发送验证码失败', error: e);
      return Result.failure(
        Exception('发送验证码失败: $e'),
      );
    }
  }

  @override
  Future<Result<AuthToken>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      if (response.data != null) {
        final token = AuthToken.fromJson(
          response.data!['token'] as Map<String, dynamic>,
        );
        await _saveToken(token);
        return Result.success(token);
      }

      return Result.failure(
        Exception('刷新 Token 失败'),
      );
    } catch (e) {
      return Result.failure(
        Exception('刷新 Token 失败: $e'),
      );
    }
  }

  @override
  Future<void> logout() async {
    Log.i('用户登出');
    await _cacheManager.storage.remove(_tokenKey);
    await _cacheManager.storage.remove(_userKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getCurrentToken();
    return token != null && !token.isExpired;
  }

  @override
  Future<AuthToken?> getCurrentToken() async {
    final json = await _cacheManager.getStorage<Map<String, dynamic>>(
      _tokenKey,
    );
    if (json != null) {
      return AuthToken.fromJson(json);
    }
    return null;
  }

  /// 保存 Token
  Future<void> _saveToken(AuthToken token) async {
    await _cacheManager.setStorage(_tokenKey, token.toJson());
  }
}
