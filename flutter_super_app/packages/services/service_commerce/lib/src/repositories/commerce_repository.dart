library;

import 'package:core_base/core_base.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/order.dart';

/// 商城仓库接口
abstract class CommerceRepository {
  // ==================== 商品 ====================
  Future<Result<Product>> getProduct(String productId);
  Future<Result<PagedResult<Product>>> getProducts(ProductQuery query);
  
  // ==================== 购物车 ====================
  Future<Result<List<CartItem>>> getCart(String userId);
  Future<Result<CartItem>> addToCart({
    required String userId,
    required String productId,
    String? skuId,
    required int quantity,
  });
  Future<Result<CartItem>> updateCartItem({
    required String cartItemId,
    required int quantity,
  });
  Future<Result<void>> removeFromCart(String cartItemId);
  Future<Result<void>> clearCart(String userId);
  
  // ==================== 订单 ====================
  Future<Result<Order>> createOrder({
    required String userId,
    required List<String> cartItemIds,
    ShippingAddress? shippingAddress,
    String? remark,
  });
  Future<Result<Order>> getOrder(String orderId);
  Future<Result<PagedResult<Order>>> getUserOrders({
    required String userId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  });
  Future<Result<void>> cancelOrder(String orderId);
  Future<Result<void>> confirmOrder(String orderId);
  
  /// 清除缓存
  Future<void> clearCache();
}
