import 'package:flutter_test/flutter_test.dart';

import 'package:core_utils/core_utils.dart';

void main() {
  group('StringExtensions', () {
    test('should validate phone number', () {
      expect('13812345678'.isPhoneNumber, true);
      expect('12345678901'.isPhoneNumber, false);
      expect(null.isPhoneNumber, false);
    });

    test('should validate email', () {
      expect('test@example.com'.isEmail, true);
      expect('invalid-email'.isEmail, false);
    });

    test('should check isNullOrEmpty', () {
      expect(''.isNullOrEmpty, true);
      expect(null.isNullOrEmpty, true);
      expect('test'.isNullOrEmpty, false);
    });

    test('should hide phone number', () {
      expect('13812345678'.hidePhoneNumber, '138****5678');
    });
  });

  group('DateTimeExtensions', () {
    test('should check if is today', () {
      final now = DateTime.now();
      expect(now.isToday, true);
      expect(now.subtract(const Duration(days: 1)).isToday, false);
    });

    test('should format date time', () {
      final date = DateTime(2026, 2, 24, 12, 30, 45);
      expect(date.format('yyyy-MM-dd'), '2026-02-24');
    });

    test('should get relative time', () {
      final now = DateTime.now();
      expect(now.toRelativeTime, '刚刚');
    });
  });

  group('NumExtensions', () {
    test('should check isPositive', () {
      expect(5.isPositive, true);
      expect(0.isPositive, false);
      expect((-5).isPositive, false);
      expect(null.isPositive, false);
    });

    test('should format to file size', () {
      expect(1024.toFileSize, '1.00 KB');
      expect(1048576.toFileSize, '1.00 MB');
    });

    test('should format to currency', () {
      expect(1234.56.toCurrency(), '¥1234.56');
    });
  });

  group('Validator', () {
    test('should validate phone number', () {
      expect(Validator.isPhoneNumber('13812345678'), true);
      expect(Validator.isPhoneNumber('123456'), false);
    });

    test('should validate email', () {
      expect(Validator.isEmail('test@example.com'), true);
      expect(Validator.isEmail('invalid'), false);
    });

    test('should validate password', () {
      expect(Validator.isPassword('abc12345'), true);
      expect(Validator.isPassword('123'), false);
    });
  });

  group('Formatter', () {
    test('should format phone number', () {
      expect(Formatter.formatPhone('13812345678'), '138****5678');
    });

    test('should format money', () {
      expect(Formatter.formatMoney(123456.78), '¥123,456.78');
    });

    test('should format duration', () {
      expect(Formatter.formatDuration(3665), '01:01:05');
      expect(Formatter.formatDuration(65), '01:05');
    });
  });
}
