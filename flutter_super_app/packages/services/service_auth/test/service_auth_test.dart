import 'package:flutter_test/flutter_test.dart';
import 'package:service_auth/service_auth.dart';
import 'package:service_user/service_user.dart';

void main() {
  group('AuthToken', () {
    test('should create token with required fields', () {
      final now = DateTime.now();
      final token = AuthToken(
        accessToken: 'abc123',
        acquiredAt: now,
      );
      expect(token.accessToken, 'abc123');
      expect(token.tokenType, 'Bearer');
      expect(token.isExpired, false);
    });

    test('should create token with all fields', () {
      final now = DateTime.now();
      final token = AuthToken(
        accessToken: 'abc123',
        refreshToken: 'refresh123',
        tokenType: 'Bearer',
        expiresIn: 3600,
        acquiredAt: now,
      );
      expect(token.refreshToken, 'refresh123');
      expect(token.expiresIn, 3600);
    });

    test('should detect expired token', () {
      final past = DateTime.now().subtract(Duration(hours: 2));
      final token = AuthToken(
        accessToken: 'abc123',
        expiresIn: 3600,
        acquiredAt: past,
      );
      expect(token.isExpired, true);
    });

    test('should calculate remaining time', () {
      final now = DateTime.now();
      final token = AuthToken(
        accessToken: 'abc123',
        expiresIn: 7200,
        acquiredAt: now,
      );
      expect(token.remainingSeconds, greaterThan(0));
      expect(token.remainingSeconds, lessThanOrEqualTo(7200));
    });

    test('should create token from json', () {
      final json = {
        'accessToken': 'abc123',
        'refreshToken': 'refresh123',
        'tokenType': 'Bearer',
        'expiresIn': 3600,
        'acquiredAt': DateTime.now().toIso8601String(),
      };
      final token = AuthToken.fromJson(json);
      expect(token.accessToken, 'abc123');
    });

    test('should convert token to json', () {
      final token = AuthToken(
        accessToken: 'abc123',
        acquiredAt: DateTime.now(),
      );
      final json = token.toJson();
      expect(json['accessToken'], 'abc123');
    });
  });

  group('AuthResult', () {
    test('should create success result', () {
      final result = AuthResult.success(
        user: const User(id: '123', username: 'test'),
        token: 'abc123',
      );
      expect(result.isSuccess, true);
      expect(result.user?.id, '123');
      expect(result.token, 'abc123');
    });

    test('should create failure result', () {
      final result = AuthResult.failure('登录失败');
      expect(result.isSuccess, false);
      expect(result.errorMessage, '登录失败');
      expect(result.user, null);
      expect(result.token, null);
    });
  });

  group('AuthState', () {
    test('should create unauthenticated state', () {
      final state = AuthState.unauthenticated();
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.token, null);
    });

    test('should create loading state', () {
      final state = AuthState.loading();
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('should create authenticated state', () {
      final now = DateTime.now();
      final user = const User(id: '123', username: 'test');
      final token = AuthToken(
        accessToken: 'abc123',
        acquiredAt: now,
      );
      final state = AuthState.authenticated(user: user, token: token);
      expect(state.isAuthenticated, true);
      expect(state.user?.id, '123');
      expect(state.token?.accessToken, 'abc123');
    });

    test('should copy state with new values', () {
      final state = AuthState.unauthenticated();
      final copied = state.copyWith(isLoading: true);
      expect(copied.isLoading, true);
      expect(copied.isAuthenticated, false);
    });
  });
}
