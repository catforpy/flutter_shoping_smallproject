import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_user/service_user.dart';
import '../models/auth_token.dart';
import '../models/auth_result.dart';
import '../models/auth_type.dart';
import '../services/auth_service.dart';

/// 认证状态
final class AuthState {
  final User? user;
  final AuthToken? token;
  final bool isAuthenticated;
  final bool isLoading;
  final AuthType authType;

  const AuthState({
    this.user,
    this.token,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.authType = AuthType.guest,
  });

  /// 未认证状态
  factory AuthState.unauthenticated() => const AuthState(
        authType: AuthType.guest,
      );

  /// 认证中状态
  factory AuthState.loading() => const AuthState(
        isLoading: true,
        authType: AuthType.guest,
      );

  /// 已认证状态
  factory AuthState.authenticated({
    required User? user,
    required AuthToken token,
  }) {
    return AuthState(
      user: user,
      token: token,
      isAuthenticated: true,
      authType: token.authType,
    );
  }

  /// 是否为游客模式
  bool get isGuest => authType == AuthType.guest;

  /// 是否需要实名认证才能使用核心功能
  bool get requiresRealNameForCoreFeatures => authType.requiresRealNameForCoreFeatures;

  /// 是否可以使用微信支付
  bool get canUseWeChatPay => authType.canUseWeChatPay;

  /// 是否允许浏览内容
  bool get canBrowse => authType.canBrowse;

  /// 是否允许互动（点赞、评论、收藏等）
  bool get canInteract => authType.canInteract;

  AuthState copyWith({
    User? user,
    AuthToken? token,
    bool? isAuthenticated,
    bool? isLoading,
    AuthType? authType,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      authType: authType ?? this.authType,
    );
  }
}

/// 认证 Provider
final class AuthProvider extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthProvider(this._authService) : super(AuthState.unauthenticated());

  /// 当前用户
  User? get user => state.user;

  /// Token
  AuthToken? get token => state.token;

  /// 是否已登录
  bool get isLoggedIn => state.isAuthenticated;

  /// 是否正在加载
  bool get isLoading => state.isLoading;

  /// 初始化认证状态
  Future<void> initialize() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        state = AuthState(
          user: null, // 用户信息需要从其他地方加载
          token: token,
          isAuthenticated: true,
          authType: token.authType,
        );
      }
    }
  }

  /// 密码登录
  Future<AuthResult> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    state = AuthState.loading();

    final result = await _authService.loginWithPassword(
      phone: phone,
      password: password,
    );

    if (result.isSuccess) {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        state = AuthState.authenticated(
          user: result.user,
          token: token,
        );
      }
    } else {
      state = AuthState.unauthenticated();
    }

    return result;
  }

  /// 验证码登录
  Future<AuthResult> loginWithVerifyCode({
    required String phone,
    required String code,
  }) async {
    state = AuthState.loading();

    final result = await _authService.loginWithVerifyCode(
      phone: phone,
      code: code,
    );

    if (result.isSuccess) {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        state = AuthState.authenticated(
          user: result.user,
          token: token,
        );
      }
    } else {
      state = AuthState.unauthenticated();
    }

    return result;
  }

  /// 微信授权登录
  Future<AuthResult> loginWithWechat({
    required String authCode,
  }) async {
    state = AuthState.loading();

    final result = await _authService.loginWithWechat(
      authCode: authCode,
    );

    if (result.isSuccess) {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        state = AuthState.authenticated(
          user: result.user,
          token: token,
        );
      }
    } else {
      state = AuthState.unauthenticated();
    }

    return result;
  }

  /// 游客模式登录
  Future<AuthResult> loginAsGuest({
    required String deviceId,
  }) async {
    state = AuthState.loading();

    final result = await _authService.loginAsGuest(
      deviceId: deviceId,
    );

    if (result.isSuccess) {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        state = AuthState.authenticated(
          user: null, // 游客没有用户信息
          token: token,
        );
      }
    } else {
      state = AuthState.unauthenticated();
    }

    return result;
  }

  /// 注册
  Future<AuthResult> register({
    required String phone,
    required String password,
    required String verifyCode,
  }) async {
    state = AuthState.loading();

    final result = await _authService.register(
      phone: phone,
      password: password,
      verifyCode: verifyCode,
    );

    if (result.isSuccess) {
      final token = await _authService.getCurrentToken();
      if (token != null) {
        state = AuthState.authenticated(
          user: result.user,
          token: token,
        );
      }
    } else {
      state = AuthState.unauthenticated();
    }

    return result;
  }

  /// 登出
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }

  /// 刷新 Token
  Future<void> refreshToken() async {
    final currentToken = state.token;
    if (currentToken?.refreshToken == null || currentToken?.isGuest != false) {
      await logout();
      return;
    }

    final result = await _authService.refreshToken(currentToken!.refreshToken!);
    if (result.isSuccess) {
      state = state.copyWith(
        token: result.valueOrThrow,
      );
    } else {
      await logout();
    }
  }
}

/// 认证服务 Provider
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('AuthService must be provided');
});

/// 认证状态 Provider
final authStateProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthProvider(authService);
});
