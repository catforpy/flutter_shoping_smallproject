import 'package:flutter_test/flutter_test.dart';
import 'package:service_payment/service_payment.dart';

void main() {
  group('PaymentMethod Tests', () {
    test('PaymentMethod should have correct values', () {
      expect(PaymentMethod.wechat.value, 'wechat');
      expect(PaymentMethod.alipay.value, 'alipay');
    });
  });

  group('Transaction Tests', () {
    test('Transaction should create correctly', () {
      final transaction = Transaction(
        id: 'transaction123',
        userId: 'user123',
        type: TransactionType.recharge,
        amount: 10000,
        balanceBefore: 5000,
        balanceAfter: 15000,
        status: TransactionStatus.success,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(transaction.isSuccess, true);
    });
  });
}
