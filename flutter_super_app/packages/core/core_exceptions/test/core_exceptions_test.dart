import 'package:flutter_test/flutter_test.dart';

import 'package:core_exceptions/core_exceptions.dart';

void main() {
  group('AppException', () {
    test('should create exception with code and message', () {
      final exception = TestException(
        code: 'TEST_ERROR',
        message: 'Test error message',
      );

      expect(exception.code, 'TEST_ERROR');
      expect(exception.message, 'Test error message');
      expect(exception.toString(), contains('TEST_ERROR'));
    });

    test('should provide user message', () {
      final exception = TestException(
        code: 'TEST',
        message: 'User friendly message',
      );

      expect(exception.getUserMessage(), 'User friendly message');
    });
  });

  group('NetworkException', () {
    test('should create HTTP exception', () {
      final exception = const HttpException(
        statusCode: 404,
        message: 'Not Found',
      );

      expect(exception.statusCode, 404);
      expect(exception.getUserMessage(), contains('404'));
    });

    test('should create exception from status code', () {
      final exception = NetworkException.fromStatusCode(401, 'Unauthorized');
      expect(exception, isA<UnauthorizedException>());
    });

    test('should create BadRequest exception', () {
      final exception = const BadRequestException();
      expect(exception.code, 'BAD_REQUEST');
    });

    test('should create Unauthorized exception', () {
      final exception = const UnauthorizedException();
      expect(exception.code, 'UNAUTHORIZED');
    });
  });

  group('AuthException', () {
    test('should create TokenExpired exception', () {
      final exception = const TokenExpiredException();
      expect(exception.code, 'TOKEN_EXPIRED');
      expect(exception.message, contains('过期'));
    });

    test('should create NotLogin exception', () {
      final exception = const NotLoginException();
      expect(exception.code, 'NOT_LOGIN');
    });

    test('should create UsernamePassword exception', () {
      final exception = const UsernamePasswordException();
      expect(exception.code, 'USERNAME_PASSWORD_ERROR');
    });
  });

  group('DataException', () {
    test('should create DataNotFound exception', () {
      final exception = const DataNotFoundException();
      expect(exception.code, 'DATA_NOT_FOUND');
    });

    test('should create DataSave exception', () {
      final exception = const DataSaveException();
      expect(exception.code, 'DATA_SAVE_FAILED');
    });

    test('should create Database exception', () {
      final exception = const DatabaseException();
      expect(exception.code, 'DATABASE_ERROR');
    });
  });

  group('ValidationException', () {
    test('should create validation exception with errors', () {
      final errors = {'email': 'Invalid email', 'phone': 'Invalid phone'};
      final exception = ValidationException(errors: errors);

      expect(exception.errors, errors);
      expect(exception.firstError, 'Invalid email');
      expect(exception.getErrorFor('phone'), 'Invalid phone');
    });

    test('should create NullParam exception', () {
      final exception = const NullParamException(paramName: 'userId');
      expect(exception.code, 'NULL_PARAM');
      expect(exception.paramName, 'userId');
    });

    test('should create FileSizeLimit exception', () {
      final exception = const FileSizeLimitException(
        maxSize: 10,
        actualSize: 15,
      );

      expect(exception.code, 'FILE_SIZE_LIMIT');
      expect(exception.maxSize, 10);
      expect(exception.actualSize, 15);
    });
  });
}

// Test exception class
final class TestException extends AppException {
  const TestException({
    required super.code,
    required super.message,
  });
}
