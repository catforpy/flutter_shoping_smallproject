library;

/// 购物车项
final class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String? productImage;
  final String? skuId;
  final String? skuName;
  final int quantity;
  final int price;
  final int? originalPrice;
  final int stock;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    this.productImage,
    this.skuId,
    this.skuName,
    required this.quantity,
    required this.price,
    this.originalPrice,
    this.stock = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      skuId: json['skuId'] as String?,
      skuName: json['skuName'] as String?,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
      originalPrice: json['originalPrice'] as int?,
      stock: json['stock'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'skuId': skuId,
      'skuName': skuName,
      'quantity': quantity,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 小计价格（分）
  int get subtotal => price * quantity;

  /// 是否有库存
  bool get inStock => stock >= quantity;

  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? productImage,
    String? skuId,
    String? skuName,
    int? quantity,
    int? price,
    int? originalPrice,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      skuId: skuId ?? this.skuId,
      skuName: skuName ?? this.skuName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'CartItem(id: $id, productId: $productId, quantity: $quantity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
