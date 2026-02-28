import 'package:flutter_test/flutter_test.dart';
import 'package:service_commerce/service_commerce.dart';

void main() {
  group('Product Tests', () {
    test('Product should create correctly', () {
      final product = Product(
        id: 'product123',
        sellerId: 'seller123',
        type: ProductType.physical,
        name: '测试商品',
        price: 9900,
        stock: 100,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(product.id, 'product123');
      expect(product.inStock, true);
    });

    test('Product discount calculation should work', () {
      final product = Product(
        id: 'product123',
        sellerId: 'seller123',
        type: ProductType.physical,
        name: '测试商品',
        price: 8000,
        originalPrice: 10000,
        stock: 100,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(product.hasDiscount, true);
      expect(product.discountRate, closeTo(0.2, 0.001));
    });
  });
}
