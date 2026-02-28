import 'package:flutter_test/flutter_test.dart';

import 'package:core_constants/core_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct app name', () {
      expect(AppConstants.appName, 'Flutter Super App');
    });

    test('should have correct version', () {
      expect(AppConstants.appVersion, '1.0.0');
    });

    test('should have correct default page size', () {
      expect(AppConstants.defaultPageSize, 20);
    });
  });

  group('ApiConstants', () {
    test('should have correct base URLs', () {
      expect(ApiConstants.baseUrlDev, 'https://dev-api.example.com');
      expect(ApiConstants.baseUrlProd, 'https://api.example.com');
    });

    test('should have correct endpoints', () {
      expect(ApiConstants.endpoints.login, '/auth/login');
      expect(ApiConstants.endpoints.register, '/auth/register');
      expect(ApiConstants.endpoints.userInfo, '/user/info');
    });
  });

  group('StatusCodes', () {
    test('should have correct status codes', () {
      expect(StatusCodes.ok, 200);
      expect(StatusCodes.unauthorized, 401);
      expect(StatusCodes.forbidden, 403);
      expect(StatusCodes.notFound, 404);
      expect(StatusCodes.internalServerError, 500);
    });
  });

  group('StorageKeys', () {
    test('should have correct storage keys', () {
      expect(StorageKeys.currentUser, 'current_user');
      expect(StorageKeys.accessToken, 'access_token');
      expect(StorageKeys.language, 'language');
    });
  });

  group('RegexConstants', () {
    test('should have correct regex patterns', () {
      expect(RegexConstants.phone, r'^1[3-9]\d{9}$');
      expect(RegexConstants.email, contains('@'));
      expect(RegexConstants.idCard, r'^\d{17}[\dXx]$');
    });
  });

  group('DateFormatConstants', () {
    test('should have correct date formats', () {
      expect(DateFormatConstants.fullDateTime, 'yyyy-MM-dd HH:mm:ss');
      expect(DateFormatConstants.date, 'yyyy-MM-dd');
      expect(DateFormatConstants.time, 'HH:mm:ss');
    });
  });
}
