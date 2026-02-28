library;

/// 订单状态
enum OrderStatus {
  /// 待付款
  pending('pending'),

  /// 已付款
  paid('paid'),

  /// 已发货
  shipped('shipped'),

  /// 已完成
  completed('completed'),

  /// 已取消
  cancelled('cancelled'),

  /// 已退款
  refunded('refunded');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// 订单项
final class OrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final String? skuId;
  final String? skuName;
  final int quantity;
  final int price;

  const OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    this.skuId,
    this.skuName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      skuId: json['skuId'] as String?,
      skuName: json['skuName'] as String?,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'skuId': skuId,
      'skuName': skuName,
      'quantity': quantity,
      'price': price,
    };
  }

  int get subtotal => price * quantity;
}

/// 收货地址
final class ShippingAddress {
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final String? postalCode;

  const ShippingAddress({
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] as String,
      phone: json['phone'] as String,
      province: json['province'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      detail: json['detail'] as String,
      postalCode: json['postalCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'province': province,
      'city': city,
      'district': district,
      'detail': detail,
      'postalCode': postalCode,
    };
  }

  @override
  String toString() => '$province $city $district $detail';
}

/// 订单实体
final class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final OrderStatus status;
  final int totalAmount;
  final int? discountAmount;
  final int? shippingFee;
  final int finalAmount;
  final ShippingAddress? shippingAddress;
  final String? remark;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.status,
    required this.totalAmount,
    this.discountAmount,
    this.shippingFee,
    required this.finalAmount,
    this.shippingAddress,
    this.remark,
    required this.createdAt,
    this.paidAt,
    this.shippedAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.fromString(json['status'] as String),
      totalAmount: json['totalAmount'] as int,
      discountAmount: json['discountAmount'] as int?,
      shippingFee: json['shippingFee'] as int?,
      finalAmount: json['finalAmount'] as int,
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(
              json['shippingAddress'] as Map<String, dynamic>,
            )
          : null,
      remark: json['remark'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.parse(json['shippedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'status': status.value,
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'shippingFee': shippingFee,
      'finalAmount': finalAmount,
      'shippingAddress': shippingAddress?.toJson(),
      'remark': remark,
      'createdAt': createdAt.toIso8601String(),
      if (paidAt != null) 'paidAt': paidAt?.toIso8601String(),
      if (shippedAt != null) 'shippedAt': shippedAt?.toIso8601String(),
      if (completedAt != null) 'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// 商品总数
  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// 是否待付款
  bool get isPending => status == OrderStatus.pending;

  /// 是否已付款
  bool get isPaid => status.index >= OrderStatus.paid.index;

  /// 是否已完成
  bool get isCompleted => status == OrderStatus.completed;

  /// 是否已取消
  bool get isCancelled => status == OrderStatus.cancelled;

  Order copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    OrderStatus? status,
    int? totalAmount,
    int? discountAmount,
    int? shippingFee,
    int? finalAmount,
    ShippingAddress? shippingAddress,
    String? remark,
    DateTime? createdAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingFee: shippingFee ?? this.shippingFee,
      finalAmount: finalAmount ?? this.finalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() => 'Order(id: $id, status: ${status.value})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
