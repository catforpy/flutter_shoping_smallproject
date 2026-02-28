library;


/// 商品类型枚举 - 完全可扩展
enum ProductType {
  /// 实体商品
  physical('physical'),

  /// 虚拟商品
  virtual('virtual'),

  /// 服务
  service('service'),

  /// 会员
  membership('membership'),

  /// 礼物
  gift('gift'),

  /// 自定义
  custom('custom');

  const ProductType(this.value);
  final String value;

  static ProductType fromString(String value) {
    return ProductType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ProductType.custom,
    );
  }
}

/// 商品状态
enum ProductStatus {
  /// 上架
  onSale('on_sale'),

  /// 下架
  offSale('off_sale'),

  /// 售罄
  outOfStock('out_of_stock'),

  /// 已删除
  deleted('deleted');

  const ProductStatus(this.value);
  final String value;
}

/// 商品实体 - 高度可扩展
final class Product {
  final String id;
  final String sellerId;
  final String? sellerName;
  final String? sellerAvatar;

  final ProductType type;
  final String name;
  final String? description;
  final String? coverImage;
  final List<String>? images;

  /// 价格（分为单位）
  final int price;

  /// 原价（用于显示折扣）
  final int? originalPrice;

  /// 库存
  final int stock;

  /// 已售数量
  final int soldCount;

  /// SKU列表
  final List<ProductSku>? skus;

  /// 规格选项（如：颜色、尺寸）
  final Map<String, List<String>>? specifications;

  /// 分类ID
  final String? categoryId;

  /// 分类路径
  final List<String>? categoryPath;

  /// 自定义元数据
  final Map<String, dynamic>? metadata;

  /// 统计数据
  final int viewCount;
  final int likeCount;
  final int commentCount;

  /// 当前用户状态
  final bool isLiked;

  final ProductStatus status;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.sellerId,
    this.sellerName,
    this.sellerAvatar,
    required this.type,
    required this.name,
    this.description,
    this.coverImage,
    this.images,
    required this.price,
    this.originalPrice,
    this.stock = 0,
    this.soldCount = 0,
    this.skus,
    this.specifications,
    this.categoryId,
    this.categoryPath,
    this.metadata,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.status = ProductStatus.onSale,
    required this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String?,
      sellerAvatar: json['sellerAvatar'] as String?,
      type: ProductType.fromString(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImage: json['coverImage'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      price: json['price'] as int,
      originalPrice: json['originalPrice'] as int?,
      stock: json['stock'] as int? ?? 0,
      soldCount: json['soldCount'] as int? ?? 0,
      skus: (json['skus'] as List<dynamic>?)
          ?.map((e) => ProductSku.fromJson(e as Map<String, dynamic>))
          .toList(),
      specifications: json['specifications'] != null
          ? Map<String, List<String>>.from(
              json['specifications'] as Map<String, dynamic>,
            ).map((k, v) => MapEntry(
                  k,
                  (v as List<dynamic>).cast<String>(),
                ))
          : null,
      categoryId: json['categoryId'] as String?,
      categoryPath: (json['categoryPath'] as List<dynamic>?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      status: json['status'] != null
          ? ProductStatus.values.firstWhere(
              (s) => s.value == json['status'],
              orElse: () => ProductStatus.onSale,
            )
          : ProductStatus.onSale,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'type': type.value,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'images': images,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'soldCount': soldCount,
      'skus': skus?.map((e) => e.toJson()).toList(),
      'specifications': specifications,
      'categoryId': categoryId,
      'categoryPath': categoryPath,
      if (metadata != null) 'metadata': metadata,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  T? getMetadata<T>(String key) {
    final value = metadata?[key];
    if (value == null) return null;
    return value as T;
  }

  /// 是否有折扣
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 折扣率（0-1）
  double get discountRate {
    if (!hasDiscount) return 0;
    return 1 - (price / originalPrice!);
  }

  /// 是否有库存
  bool get inStock => stock > 0;

  Product copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    ProductType? type,
    String? name,
    String? description,
    String? coverImage,
    List<String>? images,
    int? price,
    int? originalPrice,
    int? stock,
    int? soldCount,
    List<ProductSku>? skus,
    Map<String, List<String>>? specifications,
    String? categoryId,
    List<String>? categoryPath,
    Map<String, dynamic>? metadata,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      stock: stock ?? this.stock,
      soldCount: soldCount ?? this.soldCount,
      skus: skus ?? this.skus,
      specifications: specifications ?? this.specifications,
      categoryId: categoryId ?? this.categoryId,
      categoryPath: categoryPath ?? this.categoryPath,
      metadata: metadata ?? this.metadata,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 商品SKU（库存单位）
final class ProductSku {
  final String id;
  final String name;
  final Map<String, String> attributes; // {'颜色': '红色', '尺寸': 'L'}
  final int price;
  final int stock;
  final String? image;

  const ProductSku({
    required this.id,
    required this.name,
    required this.attributes,
    required this.price,
    required this.stock,
    this.image,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      id: json['id'] as String,
      name: json['name'] as String,
      attributes: Map<String, String>.from(
        json['attributes'] as Map<String, dynamic>,
      ),
      price: json['price'] as int,
      stock: json['stock'] as int,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'attributes': attributes,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }

  bool get inStock => stock > 0;
}

/// 商品查询条件
final class ProductQuery {
  final String? sellerId;
  final ProductType? type;
  final String? categoryId;
  final String? keyword;
  final ProductSortType sortType;
  final ProductStatus? status;
  final int? minPrice;
  final int? maxPrice;
  final int page;
  final int pageSize;

  const ProductQuery({
    this.sellerId,
    this.type,
    this.categoryId,
    this.keyword,
    this.sortType = ProductSortType.latest,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (sellerId != null) 'sellerId': sellerId,
      if (type != null) 'type': type!.value,
      if (categoryId != null) 'categoryId': categoryId,
      if (keyword != null) 'keyword': keyword,
      'sortType': sortType.value,
      if (status != null) 'status': status!.value,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      'page': page,
      'pageSize': pageSize,
    };
  }

  ProductQuery copyWith({
    String? sellerId,
    ProductType? type,
    String? categoryId,
    String? keyword,
    ProductSortType? sortType,
    ProductStatus? status,
    int? minPrice,
    int? maxPrice,
    int? page,
    int? pageSize,
  }) {
    return ProductQuery(
      sellerId: sellerId ?? this.sellerId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      keyword: keyword ?? this.keyword,
      sortType: sortType ?? this.sortType,
      status: status ?? this.status,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

/// 商品排序类型
enum ProductSortType {
  /// 最新
  latest('latest'),

  /// 热门
  hot('hot'),

  /// 价格升序
  priceAsc('price_asc'),

  /// 价格降序
  priceDesc('price_desc'),

  /// 销量
  sales('sales');

  const ProductSortType(this.value);
  final String value;
}
