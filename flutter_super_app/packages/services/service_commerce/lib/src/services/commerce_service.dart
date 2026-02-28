library;

import 'package:core_base/core_base.dart';
import 'package:core_network/core_network.dart';
import 'package:core_logging/core_logging.dart';
import 'package:service_interaction/service_interaction.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../repositories/commerce_repository.dart';

/// 商城服务 - 高度可扩展的电商系统
///
/// 核心功能：
/// 1. 商品管理 - 商品查询、搜索、分类
/// 2. 购物车 - 添加、修改、删除
/// 3. 订单管理 - 创建、查询、取消
///
/// 扩展性：
/// - 通过 Product.metadata 存储自定义商品属性
/// - 通过 ProductType.custom 实现自定义商品类型
/// - 支持虚拟商品、服务、会员等多种类型
final class CommerceService {
  final CommerceRepository _repository;
  final ApiClient _apiClient;
  final InteractionService? _interactionService;

  CommerceService({
    required CommerceRepository repository,
    required ApiClient apiClient,
    InteractionService? interactionService,
  })  : _repository = repository,
        _apiClient = apiClient,
        _interactionService = interactionService;

  // ==================== 商品管理 ====================

  /// 获取商品详情
  Future<Result<Product>> getProduct(String productId) async {
    return await _repository.getProduct(productId);
  }

  /// 获取商品列表
  ///
  /// 使用示例：
  /// ```dart
  /// // 获取最新商品
  /// final result = await service.getProducts(
  ///   ProductQuery(sortType: ProductSortType.latest),
  /// );
  ///
  /// // 按价格筛选
  /// final result = await service.getProducts(
  ///   ProductQuery(
  ///     minPrice: 1000,
  ///     maxPrice: 5000,
  ///     sortType: ProductSortType.priceAsc,
  ///   ),
  /// );
  ///
  /// // 搜索商品
  /// final result = await service.getProducts(
  ///   ProductQuery(keyword: '手机'),
  /// );
  /// ```
  Future<Result<PagedResult<Product>>> getProducts(ProductQuery query) async {
    try {
      Log.i('获取商品列表');

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products',
        queryParameters: query.toQueryParams(),
      );

      if (response.data != null && response.data!['success'] == true) {
        final data = response.data!['data'] as Map<String, dynamic>;
        final productsData = data['items'] as List;
        final products = productsData
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        final total = data['total'] as int? ?? 0;

        Log.i('获取商品列表成功: ${products.length} 件');
        return Result.success(
          PagedResult(
            data: products,
            pagination: Pagination(
              page: query.page,
              pageSize: query.pageSize,
              total: total,
            ),
          ),
        );
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '获取商品列表失败'),
      );
    } catch (e) {
      Log.e('获取商品列表失败', error: e);
      return Result.failure(Exception('获取商品列表失败: $e'));
    }
  }

  // ==================== 购物车管理 ====================

  /// 获取购物车
  Future<Result<List<CartItem>>> getCart(String userId) async {
    return await _repository.getCart(userId);
  }

  /// 添加到购物车
  Future<Result<CartItem>> addToCart({
    required String userId,
    required String productId,
    String? skuId,
    required int quantity,
  }) async {
    try {
      Log.i('添加到购物车: $productId');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/cart/add',
        body: {
          'userId': userId,
          'productId': productId,
          if (skuId != null) 'skuId': skuId,
          'quantity': quantity,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final cartData = response.data!['data'] as Map<String, dynamic>;
        final cartItem = CartItem.fromJson(cartData);

        Log.i('添加到购物车成功');
        return Result.success(cartItem);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '添加到购物车失败'),
      );
    } catch (e) {
      Log.e('添加到购物车失败', error: e);
      return Result.failure(Exception('添加到购物车失败: $e'));
    }
  }

  /// 更新购物车项数量
  Future<Result<CartItem>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    return await _repository.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  /// 从购物车移除
  Future<Result<void>> removeFromCart(String cartItemId) async {
    return await _repository.removeFromCart(cartItemId);
  }

  /// 清空购物车
  Future<Result<void>> clearCart(String userId) async {
    return await _repository.clearCart(userId);
  }

  // ==================== 订单管理 ====================

  /// 创建订单
  ///
  /// 使用示例：
  /// ```dart
  /// final address = ShippingAddress(
  ///   name: '张三',
  ///   phone: '13800138000',
  ///   province: '北京市',
  ///   city: '北京市',
  ///   district: '朝阳区',
  ///   detail: 'xxx街道xxx号',
  /// );
  ///
  /// await service.createOrder(
  ///   userId: 'user123',
  ///   cartItemIds: ['cart1', 'cart2'],
  ///   shippingAddress: address,
  ///   remark: '请尽快发货',
  /// );
  /// ```
  Future<Result<Order>> createOrder({
    required String userId,
    required List<String> cartItemIds,
    ShippingAddress? shippingAddress,
    String? remark,
  }) async {
    try {
      Log.i('创建订单');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/orders',
        body: {
          'userId': userId,
          'cartItemIds': cartItemIds,
          if (shippingAddress != null) 'shippingAddress': shippingAddress.toJson(),
          if (remark != null) 'remark': remark,
        },
      );

      if (response.data != null && response.data!['success'] == true) {
        final orderData = response.data!['data'] as Map<String, dynamic>;
        final order = Order.fromJson(orderData);

        Log.i('创建订单成功: ${order.id}');
        return Result.success(order);
      }

      return Result.failure(
        Exception(response.data?['message'] ?? '创建订单失败'),
      );
    } catch (e) {
      Log.e('创建订单失败', error: e);
      return Result.failure(Exception('创建订单失败: $e'));
    }
  }

  /// 获取订单详情
  Future<Result<Order>> getOrder(String orderId) async {
    return await _repository.getOrder(orderId);
  }

  /// 获取用户订单列表
  Future<Result<PagedResult<Order>>> getUserOrders({
    required String userId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    return await _repository.getUserOrders(
      userId: userId,
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 取消订单
  Future<Result<void>> cancelOrder(String orderId) async {
    return await _repository.cancelOrder(orderId);
  }

  /// 确认收货
  Future<Result<void>> confirmOrder(String orderId) async {
    return await _repository.confirmOrder(orderId);
  }

  // ==================== 交互功能（可选） ====================

  /// 点赞商品
  Future<Result<void>> likeProduct({
    required String userId,
    required String productId,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.like(
      userId: userId,
      target: TargetRef.product(productId),
    );
  }

  /// 收藏商品
  Future<Result<void>> favoriteProduct({
    required String userId,
    required String productId,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.favorite(
      userId: userId,
      target: TargetRef.product(productId),
    );
  }

  /// 分享商品
  Future<Result<void>> shareProduct({
    required String userId,
    required String productId,
    required String channel,
    String? platform,
    String? customMessage,
  }) async {
    if (_interactionService == null) {
      return Result.failure(Exception('InteractionService 未初始化'));
    }
    return await _interactionService!.share(
      userId: userId,
      target: TargetRef.product(productId),
      channel: channel,
      platform: platform,
      customMessage: customMessage,
    );
  }
}
